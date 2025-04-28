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

class NewSummaryScreenState extends State<NewSummaryScreen> {
  bool _isNavigating = false;
  List<DateTime> dateRange = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userData = Provider.of<UserData>(context, listen: false);
      await userData.fetchDiagnosis();
      await _generateSymptomDetails(userData);
    });
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

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFE8F2F5),
        body: Stack(
          children: [
            // Main scrollable content
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
                                  : Image.asset('assets/sampleimage.jpg',
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
                        width: 325.w,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.r),
                          ),
                          elevation: 3,
                          child: Column(
                            children: [
                              // Top 1
                              if (topDiagnoses.isNotEmpty)
                                Padding(
                                  padding:
                                      EdgeInsets.only(top: 20.h, left: 5.w),
                                  child: SizedBox(
                                    width: 350.w,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 110.w,
                                          height: 110.w,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              SizedBox(
                                                width: 90.w,
                                                height: 90.w,
                                                child:
                                                    CircularProgressIndicator(
                                                  value: 1.0,
                                                  backgroundColor: Colors.grey,
                                                  color:
                                                      const Color(0xFF52AAA4),
                                                  strokeWidth: 8.w,
                                                ),
                                              ),
                                              Container(
                                                height: 50.w,
                                                width: 50.w,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50.r),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: const Color(
                                                              0xFF52AAA4)
                                                          .withOpacity(0.25),
                                                      blurRadius: 10,
                                                      spreadRadius: 5,
                                                    ),
                                                  ],
                                                ),
                                                child: Text(
                                                  "1",
                                                  style: TextStyle(
                                                    fontSize: 15.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: 10.w, top: 15.h),
                                                child: Text(
                                                  topDiagnoses[0]['illness'] ??
                                                      '',
                                                  maxLines: 4,
                                                  overflow:
                                                      TextOverflow.visible,
                                                  style: TextStyle(
                                                    fontSize: 22.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(left: 10.w, top: 10.h),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .center, // ✅ Important!
                                                  children: [
                                                    Text(
                                                      "Top 1",
                                                      style: TextStyle(
                                                        fontSize: 15.sp,
                                                        color: const Color(
                                                            0xFFA9A9A9),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        width: 10
                                                            .w), // ✅ Add spacing between "Top 1" and type
                                                    if (topDiagnoses[0]
                                                            ['type'] !=
                                                        null)
                                                      Container(
                                                        width: 100.w,
                                                        height: 25
                                                            .h, // ❗ Make height smaller so text fits nicely
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    10.w),
                                                        decoration:
                                                            BoxDecoration(
                                                          
                                                          border: Border.all(
                                                            color: const Color(
                                                              0xFF52AAA4)
                                                          .withOpacity(0.25),
                                                            width: 1,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      50.r),
                                                          color:const Color.fromARGB(126, 82, 170, 164)
                                                        
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            topDiagnoses[0]
                                                                ['type'],
                                                            style: TextStyle(
                                                              fontSize: 13
                                                                  .sp, // ❗ Slightly smaller text
                                                              color: const Color.fromARGB(255, 0, 0, 0),
                                                            ),
                                                            overflow:
                                                                TextOverflow
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
                                      ],
                                    ),
                                  ),
                                ),
                              Padding(
                                padding: EdgeInsets.only(top: 0.h, left: 190.w),
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => IllnessdetailsScreen(
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
                                  child: Text(
                                    'See More',
                                    style: TextStyle(
                                      color: const Color(0xFF1D1D2C),
                                      fontSize: 18.sp,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(
                                color: Colors.black.withOpacity(0.2),
                                thickness: 2,
                                indent: 20.w,
                                endIndent: 20.w,
                              ),

                              // Top 2
                              if (topDiagnoses.length > 1)
                                Padding(
                                  padding:
                                      EdgeInsets.only(top: 15.h, left: 5.w),
                                  child: SizedBox(
                                    width: 350.w,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 110.w,
                                          height: 110.w,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              SizedBox(
                                                width: 90.w,
                                                height: 90.w,
                                                child:
                                                    CircularProgressIndicator(
                                                  value: 1.0,
                                                  backgroundColor: Colors.grey,
                                                  color:
                                                      const Color(0xFF52AAA4),
                                                  strokeWidth: 8.w,
                                                ),
                                              ),
                                              Container(
                                                height: 50.w,
                                                width: 50.w,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50.r),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: const Color(
                                                              0xFF52AAA4)
                                                          .withOpacity(0.25),
                                                      blurRadius: 10,
                                                      spreadRadius: 5,
                                                    ),
                                                  ],
                                                ),
                                                child: Text(
                                                  "2",
                                                  style: TextStyle(
                                                    fontSize: 15.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: 10.w, top: 15.h),
                                                child: Text(
                                                  topDiagnoses[1]['illness'] ??
                                                      '',
                                                  maxLines: 4,
                                                  overflow:
                                                      TextOverflow.visible,
                                                  style: TextStyle(
                                                    fontSize: 22.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(left: 10.w, top: 10.h),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .center, // ✅ Important!
                                                  children: [
                                                    Text(
                                                      "Top 2",
                                                      style: TextStyle(
                                                        fontSize: 15.sp,
                                                        color: const Color(
                                                            0xFFA9A9A9),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        width: 10
                                                            .w), // 
                                                    if (topDiagnoses[1]
                                                            ['type'] !=
                                                        null)
                                                      Container(
                                                        width: 100.w,
                                                        height: 25.h,
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    10.w),
                                                        decoration:
                                                              BoxDecoration(
                                                          
                                                          border: Border.all(
                                                            color: const Color(
                                                              0xFF52AAA4)
                                                          .withOpacity(0.25),
                                                            width: 1,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      50.r),
                                                          color:const Color.fromARGB(126, 82, 170, 164)
                                                        
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            topDiagnoses[1]
                                                                ['type'],
                                                            style: TextStyle(
                                                              fontSize: 13
                                                                  .sp, // ❗ Slightly smaller text
                                                              color: const Color.fromARGB(255, 0, 0, 0),
                                                            ),
                                                            overflow:
                                                                TextOverflow
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
                                      ],
                                    ),
                                  ),
                                ),
                              Padding(
                                padding: EdgeInsets.only(top: 0.h, left: 190.w),
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => IllnessdetailsScreen(
                                            illnessName: topDiagnoses[1]
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
                                  child: Text(
                                    'See More',
                                    style: TextStyle(
                                      color: const Color(0xFF1D1D2C),
                                      fontSize: 18.sp,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(
                                color: Colors.black.withOpacity(0.2),
                                thickness: 2,
                                indent: 20.w,
                                endIndent: 20.w,
                              ),

                              // Top 3
                              if (topDiagnoses.length > 2)
                                Padding(
                                  padding:
                                      EdgeInsets.only(top: 15.h, left: 5.w),
                                  child: SizedBox(
                                    width: 350.w,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 110.w,
                                          height: 110.w,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              SizedBox(
                                                width: 90.w,
                                                height: 90.w,
                                                child:
                                                    CircularProgressIndicator(
                                                  value: 1.0,
                                                  backgroundColor: Colors.grey,
                                                  color:
                                                      const Color(0xFF52AAA4),
                                                  strokeWidth: 8.w,
                                                ),
                                              ),
                                              Container(
                                                height: 50.w,
                                                width: 50.w,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50.r),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: const Color(
                                                              0xFF52AAA4)
                                                          .withOpacity(0.25),
                                                      blurRadius: 10,
                                                      spreadRadius: 5,
                                                    ),
                                                  ],
                                                ),
                                                child: Text(
                                                  "3",
                                                  style: TextStyle(
                                                    fontSize: 15.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: 10.w, top: 15.h),
                                                child: Text(
                                                  topDiagnoses[2]['illness'] ??
                                                      '',
                                                  maxLines: 4,
                                                  overflow:
                                                      TextOverflow.visible,
                                                  style: TextStyle(
                                                    fontSize: 22.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(left: 10.w, top: 10.h),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .center, // ✅ Important!
                                                  children: [
                                                    Text(
                                                      "Top 3",
                                                      style: TextStyle(
                                                        fontSize: 15.sp,
                                                        color: const Color(
                                                            0xFFA9A9A9),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        width: 10
                                                            .w), 
                                                    if (topDiagnoses[2]
                                                            ['type'] !=
                                                        null)
                                                      Container(
                                                        width: 100.w,
                                                        height: 25
                                                            .h, // ❗ Make height smaller so text fits nicely
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    10.w),
                                                        decoration:
                                                              BoxDecoration(
                                                          
                                                          border: Border.all(
                                                            color: const Color(
                                                              0xFF52AAA4)
                                                          .withOpacity(0.25),
                                                            width: 1,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      50.r),
                                                          color:const Color.fromARGB(126, 82, 170, 164)
                                                        
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            topDiagnoses[2]
                                                                ['type'],
                                                            style: TextStyle(
                                                              fontSize: 13
                                                                  .sp, 
                                                              color: const Color.fromARGB(255, 0, 0, 0),
                                                            ),
                                                            overflow:
                                                                TextOverflow
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
                                      ],
                                    ),
                                  ),
                                ),
                              Padding(
                                padding: EdgeInsets.only(top: 0.h, left: 190.w),
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => IllnessdetailsScreen(
                                            illnessName: topDiagnoses[2]
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
                                  child: Text(
                                    'See More',
                                    style: TextStyle(
                                      color: const Color(0xFF1D1D2C),
                                      fontSize: 18.sp,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 15.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Swiper section - now placed after the top 3 illness card
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
                            viewportFraction: 0.8,
                            scale: 0.9,
                            pagination: SwiperPagination(
                              builder: DotSwiperPaginationBuilder(
                                color: Colors.black.withOpacity(0.2),
                                activeColor: Colors.purple,
                              ),
                            ),
                            itemBuilder: (_, idx) {
                              final d = top10[idx];
                              final name = d['illness'] as String;
                              final fc = (d['confidence_fc'] as num).toDouble();
                              final gb = (d['confidence_gb'] as num).toDouble();
                              final ab = (d['confidence_ab'] as num).toDouble();
                              return Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.r)),
                                elevation: 4,
                                child: Padding(
                                  padding: EdgeInsets.all(6.w),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(name,
                                          style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis),
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
                                      Text("Top ${idx + 1}",
                                          style: TextStyle(fontSize: 12.sp)),
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

                  // Illness comparison section - now moved after the swiper
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    child: Card(
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
                  ),

                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 130.w,
                        child: ElevatedButton(
                          onPressed: () async {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => const Center(
                                  child: CircularProgressIndicator()),
                            );
                            try {
                              final uid =
                                  FirebaseAuth.instance.currentUser?.uid;
                              await _generateSymptomDetails(userData);
                              if (uid != null) {
                                final historyCol = FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(uid)
                                    .collection('History');
                                final existing = await historyCol
                                    .where('petName',
                                        isEqualTo: userData.userName)
                                    .where('petType',
                                        isEqualTo: userData.selectedPetType)
                                    .limit(1)
                                    .get();
                                final softmaxList = List<double>.generate(
                                    3,
                                    (i) => (diagnoses.length > i &&
                                            diagnoses[i].containsKey(
                                                'confidence_softmax'))
                                        ? (diagnoses[i]['confidence_softmax']
                                                as num)
                                            .toDouble()
                                        : 0.0);
                                final metricsWithCm =
                                    <String, Map<String, dynamic>>{};
                                for (var d in diagnoses) {
                                  final illness = d['illness'] as String;
                                  try {
                                    final url = Uri.parse(
                                        AppConfig.getMetricsWithCmURL(
                                            userData.selectedPetType, illness));
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
                                      final mRaw = data['metrics']
                                          as Map<String, dynamic>;
                                      final metrics = {
                                        'accuracy': (mRaw['Accuracy'] as num)
                                            .toDouble(),
                                        'precision': (mRaw['Precision'] as num)
                                            .toDouble(),
                                        'recall':
                                            (mRaw['Recall'] as num).toDouble(),
                                        'specificity':
                                            (mRaw['Specificity'] as num)
                                                .toDouble(),
                                        'f1Score': (mRaw['F1 Score'] as num)
                                            .toDouble(),
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
                                  'symptomDetails': userData.symptomDetails,
                                  'Metrics/Confusion': metricsWithCm,
                                  'softmax': softmaxList,
                                };
                                if (existing.docs.isNotEmpty) {
                                  await existing.docs.first.reference.update({
                                    'assessments': FieldValue.arrayUnion(
                                        [assessmentEntry]),
                                    'date': Timestamp.now(),
                                  });
                                } else {
                                  await historyCol.add({
                                    'date': Timestamp.now(),
                                    'petType': userData.selectedPetType,
                                    'petName': userData.userName,
                                    'petDetails': petDetails,
                                    'petImage': userData.petImage ??
                                        'assets/sampleimage.jpg',
                                    'assessments': [assessmentEntry],
                                    'AllIllnesses': diagnoses.length,
                                  });
                                }
                                Provider.of<UserData>(context, listen: false)
                                    .clearData();
                              }
                              Navigator.pop(context);
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const HomePageScreen(
                                          showSuccessDialog: true)));
                            } catch (e) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')));
                            }
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
