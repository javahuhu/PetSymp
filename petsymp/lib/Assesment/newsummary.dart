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

class NewSummaryScreen extends StatefulWidget {
  const NewSummaryScreen({super.key});

  @override
  NewSummaryScreenState createState() => NewSummaryScreenState();
}

class NewSummaryScreenState extends State<NewSummaryScreen>
    with SingleTickerProviderStateMixin {
  List<DateTime> dateRange = [];
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userData = Provider.of<UserData>(context, listen: false);
      await userData.fetchDiagnosis();
      await _generateSymptomDetails(userData);
    });
  }

  @override
  void dispose() {
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
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 8,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Color(0xFFF5F9FA),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Medical icon at the top
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF52AAA4).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.health_and_safety,
                    color: Color(0xFF52AAA4),
                    size: 40,
                  ),
                ),
                SizedBox(height: 16),

                // Title with medical styling
                Text(
                  "Medical Disclaimer",
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                    color: const Color(0xFF2D4059),
                    letterSpacing: 0.5,
                  ),
                ),

                const Divider(
                  color: Color(0xFF52AAA4),
                  thickness: 1.5,
                  indent: 50,
                  endIndent: 50,
                ),
                SizedBox(height: 16),

                // Content in a scroll view with better formatting
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildDisclaimerSection(
                          icon: Icons.pets,
                          title: "Purpose",
                          content:
                              "PetSymp is designed to help you better understand your pet's health by guiding you through symptoms and showing possible conditions your pet might be experiencing.",
                        ),
                        _buildDisclaimerSection(
                          icon: Icons.warning_amber,
                          title: "Not a Replacement",
                          content:
                              "This app does not replace a visit to the veterinarian. The results and suggestions provided are for guidance only and not meant to be a final diagnosis.",
                        ),
                        _buildDisclaimerSection(
                          icon: Icons.medical_services,
                          title: "Seek Professional Care",
                          content:
                              "If your pet seems unwell, in pain, or if you're unsure about what to do, please consult a licensed veterinarian immediately.",
                        ),
                        _buildDisclaimerSection(
                          icon: Icons.gavel,
                          title: "Liability",
                          content:
                              "By using PetSymp, you agree that we are not responsible for any decisions you make based on the app's results.",
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Action buttons with better styling
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      label: "DECLINE",
                      onPressed: () => Navigator.pop(context, false),
                      backgroundColor: Colors.white,
                      textColor: Colors.redAccent,
                      borderColor: Colors.redAccent,
                    ),
                    _buildActionButton(
                      label: "I UNDERSTAND",
                      onPressed: () async {
                        // ✅ Capture safe references BEFORE any async or pop
                        final navigator = Navigator.of(context);
                        final scaffold = ScaffoldMessenger.of(context);
                        final userDataProvider =
                            Provider.of<UserData>(context, listen: false);

                        // Close disclaimer dialog
                        navigator.pop();

                        // Show loading dialog with medical styling
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => Dialog(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            child: Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF52AAA4)),
                                    strokeWidth: 3,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    "Processing Health Data...",
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      color: Color(0xFF2D4059),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
                                .where('petName',
                                    isEqualTo: userDataProvider.userName)
                                .where('petType',
                                    isEqualTo: userDataProvider.selectedPetType)
                                .limit(1)
                                .get();

                            final softmaxList = List<double>.generate(
                              3,
                              (i) => (diagnoses.length > i &&
                                      diagnoses[i]
                                          .containsKey('confidence_softmax'))
                                  ? (diagnoses[i]['confidence_softmax'] as num)
                                      .toDouble()
                                  : 0.0,
                            );

                            final metricsWithCm =
                                <String, Map<String, dynamic>>{};
                            for (var d in diagnoses) {
                              final illness = d['illness'] as String;
                              try {
                                final url = Uri.parse(
                                    AppConfig.getMetricsWithCmURL(
                                        userDataProvider.selectedPetType,
                                        illness));
                                final resp = await http.get(url);
                                if (resp.statusCode == 200) {
                                  final data = jsonDecode(resp.body)
                                      as Map<String, dynamic>;
                                  final cmRaw = data['confusion_matrix']
                                      as Map<String, dynamic>;
                                  final confMatrix = {
                                    'TP': cmRaw['TP'] as int,
                                    'FP': cmRaw['FP'] as int,
                                    'FN': cmRaw['FN'] as int,
                                    'TN': cmRaw['TN'] as int,
                                  };
                                  final mRaw =
                                      data['metrics'] as Map<String, dynamic>;
                                  final metrics = {
                                    'accuracy':
                                        (mRaw['Accuracy'] as num).toDouble(),
                                    'precision':
                                        (mRaw['Precision'] as num).toDouble(),
                                    'recall':
                                        (mRaw['Recall'] as num).toDouble(),
                                    'specificity':
                                        (mRaw['Specificity'] as num).toDouble(),
                                    'f1Score':
                                        (mRaw['F1 Score'] as num).toDouble(),
                                  };
                                  metricsWithCm[illness] = {
                                    'metrics': metrics,
                                    'confusion_matrix': confMatrix,
                                  };
                                }
                              } catch (e) {
                                print(
                                    "⚠️ Failed to fetch metrics+CM for $illness: $e");
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
                                'assessments':
                                    FieldValue.arrayUnion([assessmentEntry]),
                                'date': Timestamp.now(),
                              });
                            } else {
                              await historyCol.add({
                                'date': Timestamp.now(),
                                'petType': userDataProvider.selectedPetType,
                                'petName': userDataProvider.userName,
                                'petDetails': petDetails,
                                'petImage': userDataProvider.petImage ??
                                    'assets/noimagepet.jpg',
                                'assessments': [assessmentEntry],
                                'AllIllnesses': diagnoses.length,
                              });
                            }

                            userDataProvider.clearData();
                          }

                          navigator.pop(); // close loading
                          navigator.pushReplacement(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const HomePageScreen(showSuccessDialog: true),
                            ),
                          );
                        } catch (e) {
                          navigator.pop(); // close loading
                          scaffold.showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.redAccent,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        }
                      },
                      backgroundColor: Color(0xFF52AAA4),
                      textColor: Colors.white,
                      borderColor: Color(0xFF52AAA4),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// Helper widget for disclaimer sections
  Widget _buildDisclaimerSection({
    required IconData icon,
    required String title,
    required String content,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Color(0xFF52AAA4),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                  color: Color(0xFF2D4059),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 28.0, top: 6.0),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 16.sp,
                fontFamily: 'Inter',
                color: const Color(0xFF505D68),
                height: 1.4,
              ),
            ),
          ),
          if (!isLast)
            const Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: Divider(
                color: Color(0xFFE0E0E0),
                thickness: 1,
              ),
            ),
        ],
      ),
    );
  }

// Helper widget for action buttons
  Widget _buildActionButton({
    required String label,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color textColor,
    required Color borderColor,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: textColor,
        backgroundColor: backgroundColor,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(color: borderColor, width: 1.5),
        ),
        elevation: 0,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
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
        backgroundColor: const Color.fromARGB(255, 219, 230, 233),
        body: Stack(
          children: [
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
                            width: 400.w,
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
                        EdgeInsets.symmetric(vertical: 15.h, horizontal: 20.w),
                    child: Center(
                      child: SizedBox(
                        width: 380.w,
                        child:  Container(
                          decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 248, 248, 248),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 5,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                            child: topDiagnoses.isEmpty
                                ? Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 30.h),
                                    child: Text(
                                      "No available diagnosis.",
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : Column(
                                    children: [
                                      if (topDiagnoses.isNotEmpty &&
                                          (topDiagnoses[0]['illness'] ?? '')
                                              .isNotEmpty) ...[
                                        Padding(
                                          padding: EdgeInsets.only(top: 20.h),
                                          child: _buildDiagnosisCard(
                                              context,
                                              topDiagnoses[0],
                                              "1",
                                              ageLabel0,
                                              sizeLabel0),
                                        ),
                                        _buildSeeMoreButton(context,
                                            topDiagnoses[0]['illness']),
                                        Divider(
                                          color: Colors.black.withOpacity(0.1),
                                          thickness: 1.5,
                                          indent: 20.w,
                                          endIndent: 20.w,
                                        ),
                                      ],
                                      if (topDiagnoses.length > 1 &&
                                          (topDiagnoses[1]['illness'] ?? '')
                                              .isNotEmpty) ...[
                                        Padding(
                                          padding: EdgeInsets.only(top: 15.h),
                                          child: _buildDiagnosisCard(
                                              context,
                                              topDiagnoses[1],
                                              "2",
                                              ageLabel1,
                                              sizeLabel1),
                                        ),
                                        _buildSeeMoreButton(context,
                                            topDiagnoses[1]['illness']),
                                        Divider(
                                          color: Colors.black.withOpacity(0.1),
                                          thickness: 1.5,
                                          indent: 20.w,
                                          endIndent: 20.w,
                                        ),
                                      ],
                                      if (topDiagnoses.length > 2 &&
                                          (topDiagnoses[2]['illness'] ?? '')
                                              .isNotEmpty) ...[
                                        Padding(
                                          padding: EdgeInsets.only(top: 15.h),
                                          child: _buildDiagnosisCard(
                                              context,
                                              topDiagnoses[2],
                                              "3",
                                              ageLabel2,
                                              sizeLabel2),
                                        ),
                                        _buildSeeMoreButton(context,
                                            topDiagnoses[2]['illness']),
                                      ],
                                      SizedBox(height: 15.h),
                                    ],
                                  ),
                          ),
                        
                      ),
                    ),
                  ),

                  SizedBox(height: 15.h),

                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Container(
                          decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                          child: Theme(
                              data: Theme.of(context).copyWith(
                                dividerColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                              ),
                              child: ExpansionTile(
                                tilePadding: const EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 0.0),
                                childrenPadding: EdgeInsets.all(12.0),
                                title: Text(
                                  "Top 10 Diagnoses (Chart View)",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                    fontFamily: 'Oswald',
                                    color: const Color.fromARGB(255, 0, 0, 0),
                                  ),
                                ),
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 15.h),
                                    child: SizedBox(
                                      height: 400.h,
                                      child: Consumer<UserData>(
                                        builder: (_, __, ___) {
                                          final top10 =
                                              diagnoses.take(10).toList();
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
                                              final name =
                                                  d['illness'] as String;
                                              final fc =
                                                  (d['confidence_fc'] as num)
                                                      .toDouble();
                                              final gb =
                                                  (d['confidence_gb'] as num)
                                                      .toDouble();
                                              final ab =
                                                  (d['confidence_ab'] as num)
                                                      .toDouble();

                                              return Card(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.r)),
                                                elevation: 7,
                                                child: Padding(
                                                  padding: EdgeInsets.all(6.w),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 23.w),
                                                        child: Text(
                                                          name,
                                                          style: TextStyle(
                                                            fontSize: 16.sp,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
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
                                                        padding:
                                                            EdgeInsets.only(
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
                  Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 20.h),
                      child: Container(
                          decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                          child: Theme(
                              data: Theme.of(context).copyWith(
                                dividerColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                              ),
                              child: ExpansionTile(
                                  tilePadding: const EdgeInsets.symmetric(
                                      horizontal: 20.0, vertical: 0.0),
                                  childrenPadding: const EdgeInsets.all(12.0),
                                  title: Text(
                                    "Top 1 and Top 2 Comparison",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.sp,
                                      fontFamily: 'Oswald',
                                      color: const Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  ),
                                  children: [
                                    Card(
                                      elevation: 6,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.r)),
                                      child: Padding(
                                        padding: EdgeInsets.all(15.w),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text("Illness Comparison",
                                                style: TextStyle(
                                                    fontSize: 18.sp,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            SizedBox(height: 10.h),
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                children: [
                                                  _legendDot(Colors.red,
                                                      "Confidence Score"),
                                                  SizedBox(width: 15.w),
                                                  _legendDot(Colors.blue,
                                                      "Weighted Symptoms"),
                                                  SizedBox(width: 15.w),
                                                  _legendDot(Colors.green,
                                                      "ML Adjustment"),
                                                  SizedBox(width: 15.w),
                                                  _legendDot(Colors.orange,
                                                      "Subtype Coverage"),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 15.h),
                                            Builder(builder: (context) {
                                              if (diagnoses.isEmpty) {
                                                return Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 20.h),
                                                  child: Center(
                                                    child: Text(
                                                        'No results to compare',
                                                        style: TextStyle(
                                                            fontSize: 16.sp)),
                                                  ),
                                                );
                                              }
                                              final ill1 = topDiagnoses[0];
                                              final ill2 =
                                                  topDiagnoses.length > 1
                                                      ? topDiagnoses[1]
                                                      : null;
                                              final confAb1 =
                                                  (ill1['confidence_ab'] as num)
                                                      .toDouble();
                                              final confFc1 =
                                                  (ill1['confidence_fc'] as num)
                                                      .toDouble();
                                              final mlScore1 =
                                                  confAb1 - confFc1;
                                              final coverage1 =
                                                  (ill1['subtype_coverage']
                                                          as num)
                                                      .toDouble();
                                              final confAb2 =
                                                  (ill2?['confidence_ab']
                                                              as num? ??
                                                          0.0)
                                                      .toDouble();
                                              final confFc2 =
                                                  (ill2?['confidence_fc']
                                                              as num? ??
                                                          0.0)
                                                      .toDouble();
                                              final mlScore2 =
                                                  confAb2 - confFc2;
                                              final coverage2 =
                                                  (ill2?['subtype_coverage']
                                                              as num? ??
                                                          0.0)
                                                      .toDouble();

                                              return Column(
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color:
                                                          const Color.fromRGBO(
                                                              82,
                                                              170,
                                                              164,
                                                              0.1),
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                              top: Radius
                                                                  .circular(
                                                                      10.r)),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        SizedBox(width: 15.w),
                                                        Expanded(
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    10.w),
                                                            child: const Text(
                                                                "Metrics",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold)),
                                                          ),
                                                        ),
                                                        SizedBox(width: 26.w),
                                                        Container(
                                                            width: 1,
                                                            height: 40.h,
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.3)),
                                                        Expanded(
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    5.w),
                                                            child: Text(
                                                              "${ill1['illness']}",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                              maxLines: 1,
                                                              softWrap: true,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                            width: 1,
                                                            height: 40.h,
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.3)),
                                                        Expanded(
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    5.w),
                                                            child: Text(
                                                              "${ill2?['illness'] ?? '—'}",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                              maxLines: 1,
                                                              softWrap: true,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  _buildComparisonRow(
                                                      "Confidence Score",
                                                      confAb1
                                                          .toStringAsFixed(2),
                                                      confAb2
                                                          .toStringAsFixed(2),
                                                      Colors.red.shade100),
                                                  _buildComparisonRow(
                                                      "Weighted Symptoms",
                                                      confFc1
                                                          .toStringAsFixed(2),
                                                      confFc2
                                                          .toStringAsFixed(2),
                                                      Colors.blue.shade100),
                                                  _buildComparisonRow(
                                                      "ML Adjustment",
                                                      mlScore1
                                                          .toStringAsFixed(2),
                                                      mlScore2
                                                          .toStringAsFixed(2),
                                                      Colors.green.shade100),
                                                  _buildComparisonRow(
                                                      "Subtype Coverage",
                                                      coverage1
                                                          .toStringAsFixed(2),
                                                      coverage2
                                                          .toStringAsFixed(2),
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

  Widget _buildDiagnosisCard(
      BuildContext context,
      Map<String, dynamic> diagnosis,
      String rank,
      String ageLabel,
      String sizeLabel) {
    return SizedBox(
      width: 350.w,
      child: Column(
        children: [
          // Main row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 70.w,
                      height: 70.w,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        backgroundColor: Colors.grey.shade200,
                        color: const Color(0xFF52AAA4),
                        strokeWidth: 10.w,
                      ),
                    ),
                    Container(
                      height: 50.w,
                      width: 50.w,
                      alignment: Alignment.center,
                      child: Text(
                        rank,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF52AAA4),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 15.w),
                    child: Text(
                      diagnosis['illness'] ?? '',
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tags
          Padding(
            padding: EdgeInsets.only(top: 0.h, left: 65.w),
            child: Wrap(
              spacing: 2.w,
              runSpacing: 7.h,
              children: [
                if (diagnosis['age_specificity'] != null) _buildTag(ageLabel),
                if (diagnosis['size_specificity'] != null) _buildTag(sizeLabel),
                if (diagnosis['type'] != null) _buildTag(diagnosis['type']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      width: 170.w,
      height: 30.h,
      margin: EdgeInsets.only(right: 10.w),
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF52AAA4),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(10.r),
        color: const Color.fromARGB(255, 255, 255, 255),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13.sp,
            color: const Color(0xFF52AAA4),
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildSeeMoreButton(BuildContext context, String illnessName) {
    return Padding(
      padding: EdgeInsets.only(top: 40.h, left: 190.w),
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => IllnessdetailsScreen(illnessName: illnessName),
            ),
          );
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          backgroundColor: Colors.transparent,
        ).copyWith(
          overlayColor: MaterialStateProperty.all(Colors.transparent),
          shadowColor: MaterialStateProperty.all(Colors.transparent),
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
            SizedBox(width: 10.w),
            Icon(Icons.arrow_forward_ios,
                size: 16.sp, color: const Color(0xFF52AAA4)),
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
