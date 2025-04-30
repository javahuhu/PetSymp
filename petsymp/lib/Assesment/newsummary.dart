import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'illnessdetails.dart';
import 'package:petsymp/HomePage/homepage.dart';
import 'package:provider/provider.dart';
import '../userdata.dart';
import '../barchart/barchart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petsymp/SymptomsCatalog/symptomscatalog.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:petsymp/Connection/dynamicconnections.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'dart:ui';

class NewSummaryScreen extends StatefulWidget {
  const NewSummaryScreen({super.key});

  @override
  NewSummaryScreenState createState() => NewSummaryScreenState();
}

class NewSummaryScreenState extends State<NewSummaryScreen>
    with SingleTickerProviderStateMixin {
  List<DateTime> dateRange = [];
  bool _isNavigating = false;
  late AnimationController _bubblesController;
  late List<Bubble> _bubbles;

  @override
  void initState() {
    super.initState();
    // Initialize bubble animation
    _bubblesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 50),
    )..repeat();
    _bubbles = List.generate(50, (_) => Bubble());

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userData = Provider.of<UserData>(context, listen: false);
      await userData.fetchDiagnosis();
      await _generateSymptomDetails(userData);
    });
  }

  @override
  void dispose() {
    _bubblesController.dispose();
    super.dispose();
  }

  Future<void> _generateSymptomDetails(UserData userData) async {
    final topIllnesses =
        userData.diagnosisResults.map((d) => d['illness'].toString()).toList();
    final inputSymptoms =
        userData.petSymptoms.map((s) => s.toLowerCase()).toList();

    Map<String, List<Map<String, dynamic>>> allDetails = {};

    for (String illness in topIllnesses) {
      try {
        final petType = userData.selectedPetType.toLowerCase();
        final url =
            Uri.parse(AppConfig.getKnowledgeDetailsURL(petType, illness));
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final knowledgeList = data["knowledge"] as List<dynamic>;

          final filtered = knowledgeList.where((entry) =>
              inputSymptoms.contains(entry['name'].toString().toLowerCase()));

          allDetails[illness] = filtered.map((entry) {
            return {
              "name": entry["name"],
              "base_weight": entry["base_weight"],
              "severity": entry["severity"],
              "priority": entry["priority"],
              "fc_weight": entry["fc_weight"],
              "gb_adjustment": entry["gb_adjustment"],
              "gb_weight": entry["gb_weight"],
              "ab_factor": entry["ab_factor"],
              "ab_weight": entry["ab_weight"],
            };
          }).toList();
        }
      } catch (e) {
        print("⚠️ Failed to fetch knowledge for $illness: $e");
      }
    }

    userData.setSymptomDetails(allDetails);
  }
void _showDisclaimerThenProceed(
  BuildContext context,
  UserData userData,
  List<Map<String, dynamic>> diagnoses,
  List<Map<String, dynamic>> petDetails,
  String allSymptoms,
) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Disclaimer"),
        content: SingleChildScrollView(
          child: Text(
            "PetSymp is here to help you better understand your pet's health by guiding you through symptoms and showing possible conditions your pet might be experiencing. However, this app does not replace a visit to the veterinarian.\n\n"
            "The results and suggestions provided are for guidance only. They are not meant to be a final diagnosis or a substitute for professional care.\n\n"
            "If your pet seems unwell, in pain, or if you're unsure about what to do, please consult a licensed veterinarian immediately. Always trust your instincts and put your pet’s well-being first.\n\n"
            "By using PetSymp, you agree that we are not responsible for any decisions you make based on the app’s results.",
            style: TextStyle(
              fontSize: 17.sp,
              fontFamily: 'Inter',
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () async {
              // ✅ Capture safe references BEFORE any async or pop
              final navigator = Navigator.of(context);
              final scaffold = ScaffoldMessenger.of(context);
              final userDataProvider = Provider.of<UserData>(context, listen: false);

              // Close disclaimer dialog
              navigator.pop();

              // Show loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(child: CircularProgressIndicator()),
              );

              try {
                final uid = FirebaseAuth.instance.currentUser?.uid;
                await _generateSymptomDetails(userDataProvider);

                if (uid != null) {
                  final historyCol = FirebaseFirestore.instance
                      .collection('Users')
                      .doc(uid)
                      .collection('History');

                  final existing = await historyCol
                      .where('petName', isEqualTo: userDataProvider.userName)
                      .where('petType', isEqualTo: userDataProvider.selectedPetType)
                      .limit(1)
                      .get();

                  final softmaxList = List<double>.generate(
                    3,
                    (i) => (diagnoses.length > i &&
                            diagnoses[i].containsKey('confidence_softmax'))
                        ? (diagnoses[i]['confidence_softmax'] as num).toDouble()
                        : 0.0,
                  );

                  final metricsWithCm = <String, Map<String, dynamic>>{};
                  for (var d in diagnoses) {
                    final illness = d['illness'] as String;
                    try {
                      final url = Uri.parse(AppConfig.getMetricsWithCmURL(
                          userDataProvider.selectedPetType, illness));
                      final resp = await http.get(url);
                      if (resp.statusCode == 200) {
                        final data = jsonDecode(resp.body) as Map<String, dynamic>;
                        final cmRaw = data['confusion_matrix'] as Map<String, dynamic>;
                        final confMatrix = {
                          'TP': cmRaw['TP'] as int,
                          'FP': cmRaw['FP'] as int,
                          'FN': cmRaw['FN'] as int,
                          'TN': cmRaw['TN'] as int,
                        };
                        final mRaw = data['metrics'] as Map<String, dynamic>;
                        final metrics = {
                          'accuracy': (mRaw['Accuracy'] as num).toDouble(),
                          'precision': (mRaw['Precision'] as num).toDouble(),
                          'recall': (mRaw['Recall'] as num).toDouble(),
                          'specificity': (mRaw['Specificity'] as num).toDouble(),
                          'f1Score': (mRaw['F1 Score'] as num).toDouble(),
                        };
                        metricsWithCm[illness] = {
                          'metrics': metrics,
                          'confusion_matrix': confMatrix,
                        };
                      }
                    } catch (e) {
                      print("⚠️ Failed to fetch metrics+CM for $illness: $e");
                    }
                  }

                  final assessmentEntry = {
                    'date': Timestamp.now(),
                    'diagnosisResults': diagnoses,
                    'allSymptoms': allSymptoms,
                    'symptomDetails': userDataProvider.symptomDetails,
                    'Metrics/Confusion': metricsWithCm,
                    'softmax': softmaxList,
                  };

                  if (existing.docs.isNotEmpty) {
                    await existing.docs.first.reference.update({
                      'assessments': FieldValue.arrayUnion([assessmentEntry]),
                      'date': Timestamp.now(),
                    });
                  } else {
                    await historyCol.add({
                      'date': Timestamp.now(),
                      'petType': userDataProvider.selectedPetType,
                      'petName': userDataProvider.userName,
                      'petDetails': petDetails,
                      'petImage': userDataProvider.petImage ?? 'assets/sampleimage.jpg',
                      'assessments': [assessmentEntry],
                      'AllIllnesses': diagnoses.length,
                    });
                  }

                  userDataProvider.clearData();
                }

                navigator.pop(); // close loading
                navigator.pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const HomePageScreen(showSuccessDialog: true),
                  ),
                );
              } catch (e) {
                navigator.pop(); // close loading
                scaffold.showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final month = DateFormat('MMMM').format(now);
    final year = DateFormat('y').format(now);
    dateRange = List.generate(8, (i) => now.subtract(Duration(days: 4 - i)));

    final userData = Provider.of<UserData>(context);
    final allSymptoms = userData.petSymptoms.join(" + ");
    final diagnoses = List<Map<String, dynamic>>.from(userData.diagnosisResults)
      ..sort((a, b) =>
          (b['confidence_ab'] as num).compareTo(a['confidence_ab'] as num));
    final topDiagnoses = diagnoses.take(3).toList();
    while (topDiagnoses.length < 3) {
      topDiagnoses.add({
        'illness': '',
        'confidence_fc': 0.0,
        'confidence_gb': 0.0,
        'confidence_ab': 0.0,
        'subtype_coverage': 0.0,
      });
    }

    void navigateToSymptomCatalog() {
      if (_isNavigating) return;
      _isNavigating = true;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SymptomscatalogScreen()),
      ).then((_) {
        _isNavigating = false;
      });
    }

    final petDetails = [
      {"icon": "🎂", "label": "Pet", "value": userData.selectedPetType},
      {"icon": "🎂", "label": "Pet Name", "value": userData.userName},
      {"icon": "🎂", "label": "Age", "value": userData.age.toString()},
      {"icon": "📏", "label": "Size", "value": userData.size},
      {"icon": "🐶", "label": "Breed", "value": userData.breed},
      {"icon": "☣️", "label": "Symptoms", "value": allSymptoms},
    ];

    final ageRaw0 = topDiagnoses[0]['age_specificity'] ?? 'Unknown';
    final sizeRaw0 = topDiagnoses[0]['size_specificity'] ?? 'Unknown';
    final ageRaw1 = topDiagnoses[1]['age_specificity'] ?? 'Unknown';
    final sizeRaw1 = topDiagnoses[1]['size_specificity'] ?? 'Unknown';
    final ageRaw2 = topDiagnoses[2]['age_specificity'] ?? 'Unknown';
    final sizeRaw2 = topDiagnoses[2]['size_specificity'] ?? 'Unknown';

    final ageLabel0 = ageRaw0.toLowerCase() == 'any' ? 'Any Age' : ageRaw0;
    final sizeLabel0 = sizeRaw0.toLowerCase() == 'any' ? 'Any Size' : sizeRaw0;

    final ageLabel1 = ageRaw1.toLowerCase() == 'any' ? 'Any Age' : ageRaw1;
    final sizeLabel1 = sizeRaw1.toLowerCase() == 'any' ? 'Any Size' : sizeRaw1;

    final ageLabel2 = ageRaw2.toLowerCase() == 'any' ? 'Any Age' : ageRaw2;
    final sizeLabel2 = sizeRaw2.toLowerCase() == 'any' ? 'Any Size' : sizeRaw2;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFE8F2F5),
        body: Stack(
          children: [
            AnimatedBuilder(
              animation: _bubblesController,
              builder: (context, child) {
                final screenSize = MediaQuery.of(context).size;
                return Stack(
                  children: _bubbles.map((bubble) {
                    final size = bubble.size * screenSize.width * 0.1;
                    return Positioned(
                      left: (bubble.position.dx * screenSize.width) +
                          (math.sin((_bubblesController.value * bubble.speed +
                                      bubble.offset) *
                                  math.pi *
                                  5) *
                              bubble.wobble *
                              screenSize.width *
                              0.5),
                      top: (bubble.position.dy * screenSize.height) +
                          (_bubblesController.value *
                                  bubble.speed *
                                  screenSize.height *
                                  1) %
                              screenSize.height,
                      child: Opacity(
                        opacity: 1 * bubble.opacity,
                        child: Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              colors: [
                                Color.fromRGBO(81, 190, 181, 0.8),
                                Color.fromRGBO(83, 224, 215, 0.2),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.teal.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30.h),
                  Padding(
                    padding: EdgeInsets.only(left: 20.w),
                    child: Text(
                      '$month, $year',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 15.h),
                    child: SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: dateRange.length,
                        itemBuilder: (_, idx) {
                          final date = dateRange[idx];
                          final isToday = DateFormat('yMd').format(date) ==
                              DateFormat('yMd').format(now);
                          return Container(
                            width: 50,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: isToday ? Colors.red : Colors.black,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: isToday ? Colors.white : Colors.black,
                                width: isToday ? 3 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${date.day}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 450.h,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          top: 10.h,
                          child: SizedBox(
                            height: 425.h,
                            width: 425.w,
                            child: Image.asset('assets/linebg.png'),
                          ),
                        ),
                        Positioned(
                          top: 100.h,
                          child: Container(
                            height: 250.w,
                            width: 250.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF52AAA4),
                                width: 5.w,
                              ),
                            ),
                            child: ClipOval(
                              child: userData.petImage != null &&
                                      userData.petImage!.isNotEmpty
                                  ? (userData.petImage!.startsWith("http")
                                      ? Image.network(userData.petImage!,
                                          fit: BoxFit.cover)
                                      : Image.asset(userData.petImage!,
                                          fit: BoxFit.cover))
                                  : Image.asset('assets/noimagepet.jpg',
                                      fit: BoxFit.cover),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 0.h),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 35.h,
                          child: SizedBox(
                            child: Lottie.asset(
                              'assets/wavy.json',
                              fit: BoxFit.cover,
                              repeat: true,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(10.w),
                          width: double.infinity,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: petDetails.map((detail) {
                                return Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 30.w),
                                  child: SizedBox(
                                    height: 90.h,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          detail["label"]!,
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          detail["value"]!,
                                          style: TextStyle(
                                            fontSize: 18.sp,
                                            fontFamily: 'Oswald',
                                            color: const Color.fromRGBO(
                                                29, 29, 44, 1.0),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 15.h, horizontal: 10.w),
                    child: Center(
                      child: SizedBox(
                        width: 380.w,
                        child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.teal,
                                width: 4.0,
                              ),
                              borderRadius: BorderRadius.circular(25.r),
                            ),
                            child: Card(
                              margin: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.r),
                              ),
                              elevation: 15,
                              shadowColor:
                                  const Color(0xFF52AAA4).withOpacity(0.3),
                              child: Column(
                                children: [
                                  // Top 1
                                  if (topDiagnoses.isNotEmpty)
                                    Padding(
                                      padding: EdgeInsets.only(top: 20.h),
                                      child: SizedBox(
                                        width: 350.w,
                                        child: Column(
                                          children: [
                                            // Row containing circular progress and illness name
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 20.w),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  // Circular progress indicator with number
                                                  Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 9.w),
                                                          child: SizedBox(
                                                            width: 70.w,
                                                            height: 70.w,
                                                            child:
                                                                CircularProgressIndicator(
                                                              value: 1.0,
                                                              backgroundColor:
                                                                  Colors.grey
                                                                      .shade200,
                                                              color: const Color(
                                                                  0xFF52AAA4),
                                                              strokeWidth: 10.w,
                                                            ),
                                                          )),
                                                      Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 9.w),
                                                          child: Container(
                                                            height: 50.w,
                                                            width: 50.w,
                                                            alignment: Alignment
                                                                .center,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          50.r),
                                                              gradient:
                                                                  LinearGradient(
                                                                colors: [
                                                                  const Color(
                                                                      0xFF52AAA4),
                                                                  const Color(
                                                                          0xFF52AAA4)
                                                                      .withOpacity(
                                                                          0.8),
                                                                ],
                                                                begin: Alignment
                                                                    .topLeft,
                                                                end: Alignment
                                                                    .bottomRight,
                                                              ),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: const Color(
                                                                          0xFF52AAA4)
                                                                      .withOpacity(
                                                                          0.25),
                                                                  blurRadius:
                                                                      10,
                                                                  spreadRadius:
                                                                      5,
                                                                ),
                                                              ],
                                                            ),
                                                            child: Text(
                                                              "1",
                                                              style: TextStyle(
                                                                fontSize: 15.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          )),
                                                    ],
                                                  ),

                                                  // Illness name left-aligned
                                                  Expanded(
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 15.w),
                                                      child: Text(
                                                        topDiagnoses[0]
                                                                ['illness'] ??
                                                            '',
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 20.sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          letterSpacing: 0.3,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Tags row (kept in original position)
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(top: 20.h),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  if (topDiagnoses[0]
                                                          ['age_specificity'] !=
                                                      null)
                                                    Container(
                                                      width: 90.w,
                                                      height: 25.h,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10.w),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: const Color(
                                                                  0xFF52AAA4)
                                                              .withOpacity(0.5),
                                                          width: 2,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50.r),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          ageLabel0,
                                                          style: TextStyle(
                                                            fontSize: 13.sp,
                                                            color: const Color(
                                                                0xFF52AAA4),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                  SizedBox(width: 10.w),
                                                  if (topDiagnoses[0][
                                                          'size_specificity'] !=
                                                      null)
                                                    Container(
                                                      width: 90.w,
                                                      height: 25.h,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10.w),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: const Color(
                                                                  0xFF52AAA4)
                                                              .withOpacity(0.5),
                                                          width: 2,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50.r),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          sizeLabel0,
                                                          style: TextStyle(
                                                            fontSize: 13.sp,
                                                            color: const Color(
                                                                0xFF52AAA4),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                  SizedBox(width: 10.w),
                                                  if (topDiagnoses[0]['type'] !=
                                                      null)
                                                    Container(
                                                      width: 80.w,
                                                      height: 25.h,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10.w),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: const Color(
                                                                  0xFF52AAA4)
                                                              .withOpacity(0.5),
                                                          width: 2,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50.r),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          topDiagnoses[0]
                                                              ['type'],
                                                          style: TextStyle(
                                                            fontSize: 13.sp,
                                                            color: const Color(
                                                                0xFF52AAA4),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                  // See more button
                                  Padding(
                                    padding:
                                        EdgeInsets.only(top: 50.h, left: 211.w),
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                IllnessdetailsScreen(
                                                    illnessName: topDiagnoses[0]
                                                        ['illness']),
                                          ),
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16.w, vertical: 8.h),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        backgroundColor: Colors.transparent,
                                      ).copyWith(
                                        overlayColor: MaterialStateProperty.all(
                                            Colors.transparent),
                                        shadowColor: MaterialStateProperty.all(
                                            Colors.transparent),
                                        elevation: MaterialStateProperty.all(0),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'See More',
                                            style: TextStyle(
                                              color: const Color(0xFF52AAA4),
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            size: 14.sp,
                                            color: const Color(0xFF52AAA4),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  Divider(
                                    color: Colors.black.withOpacity(0.1),
                                    thickness: 1.5,
                                    indent: 20.w,
                                    endIndent: 20.w,
                                  ),

                                  // Top 2
                                  if (topDiagnoses.length > 1)
                                    Padding(
                                      padding: EdgeInsets.only(top: 15.h),
                                      child: SizedBox(
                                        width: 350.w,
                                        child: Column(
                                          children: [
                                            // Row containing circular progress and illness name
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 20.w),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  // Circular progress indicator with number
                                                  Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 9.w),
                                                          child: SizedBox(
                                                            width: 70.w,
                                                            height: 70.w,
                                                            child:
                                                                CircularProgressIndicator(
                                                              value: 1.0,
                                                              backgroundColor:
                                                                  Colors.grey
                                                                      .shade200,
                                                              color: const Color(
                                                                  0xFF52AAA4),
                                                              strokeWidth: 10.w,
                                                            ),
                                                          )),
                                                      Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 9.w),
                                                          child: Container(
                                                            height: 50.w,
                                                            width: 50.w,
                                                            alignment: Alignment
                                                                .center,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          50.r),
                                                              gradient:
                                                                  LinearGradient(
                                                                colors: [
                                                                  const Color(
                                                                      0xFF52AAA4),
                                                                  const Color(
                                                                          0xFF52AAA4)
                                                                      .withOpacity(
                                                                          0.8),
                                                                ],
                                                                begin: Alignment
                                                                    .topLeft,
                                                                end: Alignment
                                                                    .bottomRight,
                                                              ),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: const Color(
                                                                          0xFF52AAA4)
                                                                      .withOpacity(
                                                                          0.25),
                                                                  blurRadius:
                                                                      10,
                                                                  spreadRadius:
                                                                      5,
                                                                ),
                                                              ],
                                                            ),
                                                            child: Text(
                                                              "2",
                                                              style: TextStyle(
                                                                fontSize: 15.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          )),
                                                    ],
                                                  ),

                                                  // Illness name left-aligned
                                                  Expanded(
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 15.w),
                                                      child: Text(
                                                        topDiagnoses[1]
                                                                ['illness'] ??
                                                            '',
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 20.sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          letterSpacing: 0.3,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Tags row (kept in original position)
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(top: 20.h),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  if (topDiagnoses[1]
                                                          ['age_specificity'] !=
                                                      null)
                                                    Container(
                                                      width: 90.w,
                                                      height: 25.h,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10.w),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: const Color(
                                                                  0xFF52AAA4)
                                                              .withOpacity(0.5),
                                                          width: 2,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50.r),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          ageLabel1,
                                                          style: TextStyle(
                                                            fontSize: 13.sp,
                                                            color: const Color(
                                                                0xFF52AAA4),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                  SizedBox(width: 10.w),
                                                  if (topDiagnoses[1][
                                                          'size_specificity'] !=
                                                      null)
                                                    Container(
                                                      width: 90.w,
                                                      height: 25.h,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10.w),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: const Color(
                                                                  0xFF52AAA4)
                                                              .withOpacity(0.5),
                                                          width: 2,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50.r),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          sizeLabel1,
                                                          style: TextStyle(
                                                            fontSize: 13.sp,
                                                            color: const Color(
                                                                0xFF52AAA4),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                  SizedBox(width: 10.w),
                                                  if (topDiagnoses[1]['type'] !=
                                                      null)
                                                    Container(
                                                      width: 90.w,
                                                      height: 25.h,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10.w),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: const Color(
                                                                  0xFF52AAA4)
                                                              .withOpacity(0.5),
                                                          width: 2,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50.r),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          topDiagnoses[1]
                                                              ['type'],
                                                          style: TextStyle(
                                                            fontSize: 13.sp,
                                                            color: const Color(
                                                                0xFF52AAA4),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                  // See more button
                                  if (topDiagnoses.length > 1)
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: 50.h, left: 211.w),
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  IllnessdetailsScreen(
                                                      illnessName:
                                                          topDiagnoses[1]
                                                              ['illness']),
                                            ),
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16.w, vertical: 8.h),
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          backgroundColor: Colors.transparent,
                                        ).copyWith(
                                          overlayColor:
                                              MaterialStateProperty.all(
                                                  Colors.transparent),
                                          shadowColor:
                                              MaterialStateProperty.all(
                                                  Colors.transparent),
                                          elevation:
                                              MaterialStateProperty.all(0),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'See More',
                                              style: TextStyle(
                                                color: const Color(0xFF52AAA4),
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_forward_ios,
                                              size: 14.sp,
                                              color: const Color(0xFF52AAA4),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                  if (topDiagnoses.length > 1)
                                    Divider(
                                      color: Colors.black.withOpacity(0.1),
                                      thickness: 1.5,
                                      indent: 20.w,
                                      endIndent: 20.w,
                                    ),

                                  // Top 3
                                  if (topDiagnoses.length > 2)
                                    Padding(
                                      padding: EdgeInsets.only(top: 15.h),
                                      child: SizedBox(
                                        width: 350.w,
                                        child: Column(
                                          children: [
                                            // Row containing circular progress and illness name
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 20.w),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  // Circular progress indicator with number
                                                  Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 9.w),
                                                          child: SizedBox(
                                                            width: 70.w,
                                                            height: 70.w,
                                                            child:
                                                                CircularProgressIndicator(
                                                              value: 1.0,
                                                              backgroundColor:
                                                                  Colors.grey
                                                                      .shade200,
                                                              color: const Color(
                                                                  0xFF52AAA4),
                                                              strokeWidth: 10.w,
                                                            ),
                                                          )),
                                                      Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 9.w),
                                                          child: Container(
                                                            height: 50.w,
                                                            width: 50.w,
                                                            alignment: Alignment
                                                                .center,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          50.r),
                                                              gradient:
                                                                  LinearGradient(
                                                                colors: [
                                                                  const Color(
                                                                      0xFF52AAA4),
                                                                  const Color(
                                                                          0xFF52AAA4)
                                                                      .withOpacity(
                                                                          0.8),
                                                                ],
                                                                begin: Alignment
                                                                    .topLeft,
                                                                end: Alignment
                                                                    .bottomRight,
                                                              ),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: const Color(
                                                                          0xFF52AAA4)
                                                                      .withOpacity(
                                                                          0.25),
                                                                  blurRadius:
                                                                      10,
                                                                  spreadRadius:
                                                                      5,
                                                                ),
                                                              ],
                                                            ),
                                                            child: Text(
                                                              "3",
                                                              style: TextStyle(
                                                                fontSize: 15.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          )),
                                                    ],
                                                  ),

                                                  // Illness name left-aligned
                                                  Expanded(
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 15.w),
                                                      child: Text(
                                                        topDiagnoses[2]
                                                                ['illness'] ??
                                                            '',
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 20.sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          letterSpacing: 0.3,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Tags row (kept in original position)
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(top: 20.h),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  if (topDiagnoses[2]
                                                          ['age_specificity'] !=
                                                      null)
                                                    Container(
                                                      width: 90.w,
                                                      height: 25.h,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10.w),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: const Color(
                                                                  0xFF52AAA4)
                                                              .withOpacity(0.5),
                                                          width: 2,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50.r),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          ageLabel2,
                                                          style: TextStyle(
                                                            fontSize: 13.sp,
                                                            color: const Color(
                                                                0xFF52AAA4),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                  SizedBox(width: 10.w),
                                                  if (topDiagnoses[2][
                                                          'size_specificity'] !=
                                                      null)
                                                    Container(
                                                      width: 90.w,
                                                      height: 25.h,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10.w),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: const Color(
                                                                  0xFF52AAA4)
                                                              .withOpacity(0.5),
                                                          width: 2,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50.r),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          sizeLabel2,
                                                          style: TextStyle(
                                                            fontSize: 13.sp,
                                                            color: const Color(
                                                                0xFF52AAA4),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                  SizedBox(width: 10.w),
                                                  if (topDiagnoses[2]['type'] !=
                                                      null)
                                                    Container(
                                                      width: 100.w,
                                                      height: 25.h,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10.w),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: const Color(
                                                                  0xFF52AAA4)
                                                              .withOpacity(0.5),
                                                          width: 2,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50.r),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          topDiagnoses[2]
                                                              ['type'],
                                                          style: TextStyle(
                                                            fontSize: 13.sp,
                                                            color: const Color(
                                                                0xFF52AAA4),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                  // See more button
                                  if (topDiagnoses.length > 2)
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: 50.h, left: 211.w),
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  IllnessdetailsScreen(
                                                      illnessName:
                                                          topDiagnoses[2]
                                                              ['illness']),
                                            ),
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16.w, vertical: 8.h),
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          backgroundColor: Colors.transparent,
                                        ).copyWith(
                                          overlayColor:
                                              MaterialStateProperty.all(
                                                  Colors.transparent),
                                          shadowColor:
                                              MaterialStateProperty.all(
                                                  Colors.transparent),
                                          elevation:
                                              MaterialStateProperty.all(0),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'See More',
                                              style: TextStyle(
                                                color: const Color(0xFF52AAA4),
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_forward_ios,
                                              size: 14.sp,
                                              color: const Color(0xFF52AAA4),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                  SizedBox(height: 15.h),
                                ],
                              ),
                            )),
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 20.w),
                 child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(36, 36, 55, 1), 
                        borderRadius: BorderRadius.circular(
                            12.0), // Optional rounded corners
                      ),
                      child: Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            tilePadding:const  EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 8.0),
                            childrenPadding: EdgeInsets.all(12.0),
                            title:  Text(
                              "Top 10 Diagnoses (Chart View)",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.sp,
                                fontFamily: 'Oswald',
                                color: const Color.fromARGB(255, 231, 231, 231),
                              ),
                            ),
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 15.h),
                                child: SizedBox(
                                  height: 400.h,
                                  child: Consumer<UserData>(
                                    builder: (_, __, ___) {
                                      final top10 = diagnoses.take(10).toList();
                                      while (top10.length < 10) {
                                        top10.add({
                                          'illness': '',
                                          'confidence_fc': 0.0,
                                          'confidence_gb': 0.0,
                                          'confidence_ab': 0.0,
                                        });
                                      }

                                      return Swiper(
                                        itemCount: top10.length,
                                        itemWidth: 300.w,
                                        layout: SwiperLayout.STACK,
                                        itemBuilder: (_, idx) {
                                          final d = top10[idx];
                                          final name = d['illness'] as String;
                                          final fc = (d['confidence_fc'] as num)
                                              .toDouble();
                                          final gb = (d['confidence_gb'] as num)
                                              .toDouble();
                                          final ab = (d['confidence_ab'] as num)
                                              .toDouble();

                                          return Card(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        25.r)),
                                            elevation: 4,
                                            child: Padding(
                                              padding: EdgeInsets.all(6.w),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 23.w),
                                                    child: Text(
                                                      name,
                                                      style: TextStyle(
                                                        fontSize: 16.sp,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  SizedBox(height: 8.h),
                                                  Expanded(
                                                    child: BarChartSample2(
                                                      illnessLabels: [name],
                                                      fcScores: [fc],
                                                      gbScores: [gb],
                                                      abScores: [ab],
                                                    ),
                                                  ),
                                                  SizedBox(height: 8.h),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 10.w),
                                                    child: Text(
                                                      "Top ${idx + 1}",
                                                      style: TextStyle(
                                                          fontSize: 12.sp),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          )))),


                          Padding(padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                 child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(36, 36, 55, 1), 
                        borderRadius: BorderRadius.circular(
                            10.r), // Optional rounded corners
                      ),
                      child: Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            tilePadding:const  EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 8.0),
                            childrenPadding: EdgeInsets.all(12.0),
                            title:  Text(
                              "Top 1 and Top 2 Comparison",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.sp,
                                fontFamily: 'Oswald',
                                color: const Color.fromARGB(255, 231, 231, 231),
                              ),
                            ),
                            children: [
                
                     Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r)),
                      child: Padding(
                        padding: EdgeInsets.all(15.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Illness Comparison",
                                style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(height: 10.h),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _legendDot(Colors.red, "Confidence Score"),
                                  SizedBox(width: 15.w),
                                  _legendDot(Colors.blue, "Weighted Symptoms"),
                                  SizedBox(width: 15.w),
                                  _legendDot(Colors.green, "ML Adjustment"),
                                  SizedBox(width: 15.w),
                                  _legendDot(Colors.orange, "Subtype Coverage"),
                                ],
                              ),
                            ),
                            SizedBox(height: 15.h),
                            Builder(builder: (context) {
                              if (diagnoses.isEmpty) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20.h),
                                  child: Center(
                                    child: Text('No results to compare',
                                        style: TextStyle(fontSize: 16.sp)),
                                  ),
                                );
                              }
                              final ill1 = topDiagnoses[0];
                              final ill2 = topDiagnoses.length > 1
                                  ? topDiagnoses[1]
                                  : null;
                              final confAb1 =
                                  (ill1['confidence_ab'] as num).toDouble();
                              final confFc1 =
                                  (ill1['confidence_fc'] as num).toDouble();
                              final mlScore1 = confAb1 - confFc1;
                              final coverage1 =
                                  (ill1['subtype_coverage'] as num).toDouble();
                              final confAb2 =
                                  (ill2?['confidence_ab'] as num? ?? 0.0)
                                      .toDouble();
                              final confFc2 =
                                  (ill2?['confidence_fc'] as num? ?? 0.0)
                                      .toDouble();
                              final mlScore2 = confAb2 - confFc2;
                              final coverage2 =
                                  (ill2?['subtype_coverage'] as num? ?? 0.0)
                                      .toDouble();

                              return Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color.fromRGBO(
                                          82, 170, 164, 0.1),
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(10.r)),
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(width: 15.w),
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.all(10.w),
                                            child: Text("Metrics",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                        ),
                                        SizedBox(width: 15.w),
                                        Container(
                                            width: 1,
                                            height: 40.h,
                                            color:
                                                Colors.grey.withOpacity(0.3)),
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.all(5.w),
                                            child: Text("${ill1['illness']}",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                        ),
                                        Container(
                                            width: 1,
                                            height: 40.h,
                                            color:
                                                Colors.grey.withOpacity(0.3)),
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.all(5.w),
                                            child: Text(
                                                "${ill2?['illness'] ?? '—'}",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _buildComparisonRow(
                                      "Confidence Score",
                                      confAb1.toStringAsFixed(2),
                                      confAb2.toStringAsFixed(2),
                                      Colors.red.shade100),
                                  _buildComparisonRow(
                                      "Weighted Symptoms",
                                      confFc1.toStringAsFixed(2),
                                      confFc2.toStringAsFixed(2),
                                      Colors.blue.shade100),
                                  _buildComparisonRow(
                                      "ML Adjustment",
                                      mlScore1.toStringAsFixed(2),
                                      mlScore2.toStringAsFixed(2),
                                      Colors.green.shade100),
                                  _buildComparisonRow(
                                      "Subtype Coverage",
                                      coverage1.toStringAsFixed(2),
                                      coverage2.toStringAsFixed(2),
                                      Colors.orange.shade100,
                                      isLast: true),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                ])))),

                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 130.w,
                        child: ElevatedButton(
                          onPressed: () {
                            _showDisclaimerThenProceed(context, userData,
                                diagnoses, petDetails, allSymptoms);
                          },
                          style: ButtonStyle(
                            // Dynamic background color based on button state
                            backgroundColor: WidgetStateProperty.resolveWith(
                              (states) {
                                if (states.contains(WidgetState.pressed)) {
                                  return const Color.fromARGB(255, 0, 0,
                                      0); // Background color when pressed
                                }
                                return Colors
                                    .transparent; // Default background color
                              },
                            ),
                            // Dynamic text color based on button state
                            foregroundColor: WidgetStateProperty.resolveWith(
                              (states) {
                                if (states.contains(WidgetState.pressed)) {
                                  return const Color.fromARGB(255, 255, 255,
                                      255); // Text color when pressed
                                }
                                return const Color.fromRGBO(
                                    29, 29, 44, 1.0); // Default text color
                              },
                            ),
                            shadowColor:
                                WidgetStateProperty.all(Colors.transparent),
                            side: WidgetStateProperty.all(
                              const BorderSide(
                                color: Color.fromRGBO(82, 170, 164, 1),
                                width: 2.0,
                              ),
                            ),
                            shape: WidgetStateProperty.all(
                              const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(100)),
                              ),
                            ),
                            fixedSize: WidgetStateProperty.all(
                              const Size(155, 55),
                            ),
                          ),
                          child: Text("Finish",
                              style: TextStyle(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),

            // Floating action button
            Positioned(
              bottom: 100.h,
              right: 16.w,
              child: FloatingActionButton(
                onPressed: navigateToSymptomCatalog,
                backgroundColor: const Color.fromRGBO(29, 29, 44, 1.0),
                foregroundColor: const Color(0xFFE8F2F5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.r),
                ),
                child: const Icon(Icons.menu_book_sharp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 6.w),
        Text(label, style: TextStyle(fontSize: 14.sp)),
      ],
    );
  }

  Widget _buildComparisonRow(
    String label,
    String value1,
    String value2,
    Color bgColor, {
    bool isLast = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.3))),
      ),
      child: Row(
        children: [
          Container(
            width: 120.w,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: bgColor.withOpacity(0.3),
              border: Border(
                right: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                value1,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Container(
              width: 1, height: 40.h, color: Colors.grey.withOpacity(0.3)),
          Expanded(
            child: Center(
              child: Text(
                value2,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Bubble class for background animation
class Bubble {
  Offset position;
  double size;
  double speed;
  double wobble;
  double opacity;
  double offset;

  Bubble()
      : position = Offset(
          math.Random().nextDouble(),
          math.Random().nextDouble(),
        ),
        size = 0.5 + math.Random().nextDouble() * 0.9,
        speed = 0.1 + math.Random().nextDouble() * 0.3,
        wobble = 0.5 + math.Random().nextDouble() * 1.5,
        opacity = 0.3 + math.Random().nextDouble() * 0.7,
        offset = math.Random().nextDouble();
}
