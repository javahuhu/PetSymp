import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'illnessdetails.dart';
import 'package:petsymp/HomePage/homepage.dart';
import 'package:provider/provider.dart';
import '../userdata.dart';
import 'package:url_launcher/url_launcher.dart';
import '../barchart/barchart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petsymp/SymptomsCatalog/symptomscatalog.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:petsymp/Connection/dynamicconnections.dart';
import 'package:card_swiper/card_swiper.dart';
class NewSummaryScreen extends StatefulWidget {
  const NewSummaryScreen({super.key});

  @override
  NewSummaryScreenState createState() => NewSummaryScreenState();
}

class NewSummaryScreenState extends State<NewSummaryScreen> {
   bool _isNavigating = false;
 
 @override
void initState() {
  super.initState();
  // once the first frame is up, call fetchDiagnosis()
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Provider.of<UserData>(context, listen: false).fetchDiagnosis();
  });
}

  


  Future<void> _generateSymptomDetails(UserData userData) async {
  final List<String> topIllnesses = userData.diagnosisResults.map((d) => d['illness'].toString()).toList();
  final List<String> inputSymptoms = userData.petSymptoms.map((s) => s.toLowerCase()).toList();

  Map<String, List<Map<String, dynamic>>> allDetails = {};

  for (String illness in topIllnesses) {
    try {
      final url = Uri.parse(AppConfig.getKnowledgeDetailsURL(illness));
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> knowledgeList = data["knowledge"];

        // Filter only symptoms that match user input
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
    final List<Color> containerColors =
        List.filled(10, const Color.fromRGBO(29, 29, 44, 1.0));

    // Deduplicate by using a Set, so each symptom only appears once
    final userData = Provider.of<UserData>(context);
    final String allSymptoms = userData.petSymptoms.join(" + ");


    final List<Map<String, String>> petDetails = [
      {"icon": "🎂", "label": "Pet", "value": userData.selectedPetType.toString()},
      {"icon": "🎂", "label": "Pet Name", "value": userData.userName.toString()},
      {"icon": "🎂", "label": "Age", "value": userData.age.toString()},
      {"icon": "📏", "label": "Size", "value": userData.size.toString()},
      {"icon": "🐶", "label": "Breed", "value": userData.breed},
      {"icon": "☣️", "label": "Symptoms", "value": allSymptoms},
    ];

    // Assume userData.diagnosisResults is already sorted by highest confidence.
    final List<Map<String, dynamic>> diagnoses = userData.diagnosisResults;
    List<Map<String, dynamic>> topDiagnoses = [];
    if (diagnoses.isNotEmpty) {
      topDiagnoses = diagnoses.length >= 3
          ? diagnoses.sublist(0, 3)
          : List<Map<String, dynamic>>.from(diagnoses);
    }


    // Extract illness names and confidence scores
    final List<String> illnessLabels = [];
    final List<double> fcScores = [];
    final List<double> gbScores = [];
    final List<double> abScores = [];

    for (var item in diagnoses.take(10)) {
      illnessLabels.add(item['illness']);
      fcScores.add((item['confidence_fc'] as num).toDouble());
      gbScores.add((item['confidence_gb'] as num).toDouble());
      abScores.add((item['confidence_ab'] as num).toDouble());
    }


      void navigateToSymptomCatalog() {
  if (_isNavigating) return;

  _isNavigating = true;
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const SymptomscatalogScreen()),
  ).then((_) {
    _isNavigating = false;
  });
}

    
    return PopScope(
    canPop: false, 
    child: Scaffold(
      backgroundColor: const Color(0xFFE8F2F5),
      body: 
      Stack(children: [
      SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            
            SizedBox(height: 30.h),
             Padding(
              padding:  EdgeInsets.only(left: 20.w),
              child: Text(
                "March, 2025",
                style: TextStyle(
                  fontSize: 22.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // **Horizontal Date List**
            Padding(
              padding: EdgeInsets.only(top: 15.h),
              child: SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: containerColors.length,
                  itemBuilder: (context, index) {
                    Border borderstyle = index == 2
                        ? Border.all(
                            color: const Color.fromARGB(255, 255, 0, 0),
                            width: 4,
                          )
                        : Border.all(color: const Color.fromARGB(255, 0, 0, 0));
                    return Container(
                      width: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: containerColors[index],
                        borderRadius: BorderRadius.circular(100),
                        border: borderstyle,
                      ),
                      child: Center(
                        child: Text(
                          "${index + 1}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 0.h),

            // **Wrap Stack Inside a SizedBox**
            SizedBox(
              height: 450.h, // 🔥 Ensure Stack has a fixed height
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // **Circular Image**
                   Positioned(
                    left: 10.w,
                    top: 100.h,
                    child: Container(
                      height: 250.w,
                      width: 250.w,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromARGB(255, 255, 0, 0),
                          width: 5,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: userData.petImage != null && userData.petImage!.isNotEmpty
                      ? (userData.petImage!.startsWith("http")
                          // a real network URL:
                          ? Image.network(userData.petImage!, fit: BoxFit.cover)
                          // otherwise assume it's an asset path:
                          : Image.asset(userData.petImage!, fit: BoxFit.cover))
                      // fallback if petImage is null/empty:
                      : Image.asset("assets/sampleimage.jpg", fit: BoxFit.cover),
                      ),
                    ),
                  ),

                  // **Top Right Progress Indicator (Blue)**
                  if (topDiagnoses.isNotEmpty)
                    Positioned(
                      right: 15.w,
                      top: 58.h,
                      child: SizedBox(
                        width: 150.w, // Controls the outer size
                        height: 150.w,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 70.w, // Explicitly set width & height
                              height: 70.w,
                              child: CircularProgressIndicator(
                                value: topDiagnoses[0]['confidence_ab'] ?? 0.0,
                                backgroundColor: Colors.grey,
                                color: const Color.fromARGB(255, 239, 0, 0),
                                strokeWidth: 7.w,
                              ),
                            ),
                            Text(
                              "${((topDiagnoses[0]['confidence_ab'] ?? 0.0) * 100).round()}%",
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // **Middle Right Progress Indicator (Green)**
                  if (topDiagnoses.length > 1)
                    Positioned(
                      right: -15.w,
                      top: 145.h,
                      child: SizedBox(
                        width: 150.w,
                        height: 150.w,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 70.w,
                              height: 70.w,
                              child: CircularProgressIndicator(
                                value: topDiagnoses[1]['confidence_ab'] ?? 0.0,
                                backgroundColor: Colors.grey,
                                color: const Color.fromARGB(255, 13, 253, 0),
                                strokeWidth: 7.w,
                              ),
                            ),
                            Text(
                              "${((topDiagnoses[1]['confidence_ab'] ?? 0.0) * 100).round()}%",
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // **Bottom Right Progress Indicator (Red)**
                  if (topDiagnoses.length > 2)
                    Positioned(
                      right: 15.w,
                      top: 232.h,
                      child: SizedBox(
                        width: 150.w,
                        height: 150.w,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 70.w,
                              height: 70.w,
                              child: CircularProgressIndicator(
                                value: topDiagnoses[2]['confidence_ab'] ?? 0.0,
                                backgroundColor: Colors.grey,
                                color: const Color.fromARGB(255, 232, 135, 44),
                                strokeWidth: 7.w,
                              ),
                            ),
                            Text(
                              "${((topDiagnoses[2]['confidence_ab'] ?? 0.0) * 100).round()}%",
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 🔹 Pet Details Section (Scrollable List)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 0.h),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 🔥 Lottie Background Animation (Fixed)
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

                  // 🔹 Foreground Content (Pet Details)
                  Container(
                    padding: EdgeInsets.all(10.w),
                    width: double.infinity,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: petDetails.map((detail) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30.w),
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
                                      color: const Color.fromRGBO(29, 29, 44, 1.0),
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
  padding: EdgeInsets.symmetric(vertical: 15.h),
  child: Center(
    child: SizedBox(
      width: 1.sw,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.h),
        child: SizedBox(
          height: 400.h,
          child: Consumer<UserData>(
            builder: (_, userData, __) {
              final diagnoses = List<Map<String, dynamic>>.from(userData.diagnosisResults)
                ..sort((a, b) => (b['confidence_ab'] as num)
                                  .compareTo(a['confidence_ab'] as num));
              final top10 = diagnoses.take(10).toList();
              while (top10.length < 10) {
                top10.add({
                  'illness': '',
                  'confidence_fc': 0.0,
                  'confidence_gb': 0.0,
                  'confidence_ab': 0.0,
                  'subtype_coverage': 0.0,
                });
              }

              return Swiper(
                itemCount: top10.length,
                viewportFraction: 0.8,  // each card takes 80% of width
                scale: 0.9,             // cards behind are 90% size
                 pagination: SwiperPagination(
                    alignment: Alignment.bottomCenter,
                    builder: DotSwiperPaginationBuilder(
                      color: const Color.fromARGB(255, 69, 19, 78).withOpacity(0.2), // inactive dots
                      activeColor: Colors.purple,             // the “filled” dot
                      size: 8.0,        
                      activeSize: 10.0, 
                      space: 4.0,       
                    ),
                  ),
  
                   
                itemBuilder: (context, index) {
                  final d    = top10[index];
                  final name = d['illness'] as String;
                  final fc   = (d['confidence_fc'] as num).toDouble();
                  final gb   = (d['confidence_gb'] as num).toDouble();
                  final ab   = (d['confidence_ab'] as num).toDouble();

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Illness name
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8.h),

                          // One-item bar chart
                          Expanded(
                            child: BarChartSample2(
                              illnessLabels: [name],
                              fcScores:        [fc],
                              gbScores:        [gb],
                              abScores:        [ab],
                            ),
                          ),

                          SizedBox(height: 8.h),
                          // Top N label
                          Text(
                            "Top ${index + 1}",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
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
    ),
  ),
),


         
           Padding(
  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
  child: Card(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.r),
    ),
    child: Padding(
      padding: EdgeInsets.all(15.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Illness Comparison",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color.fromRGBO(29, 29, 44, 1.0),
            ),
          ),
          SizedBox(height: 10.h),

          // Legend Row
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

          // Comparison Table (guarded)
          Builder(
            builder: (context) {
              final topDiagnoses = Provider.of<UserData>(context, listen: false).diagnosisResults;
              
              // No results
              if (topDiagnoses.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: Center(
                    child: Text(
                      'No results to compare',
                      style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                    ),
                  ),
                );
              }

              // Prepare two columns
              final ill1 = topDiagnoses[0];
              final ill2 = topDiagnoses.length > 1 ? topDiagnoses[1] : null;

              final double confAb1 = (ill1['confidence_ab'] as num).toDouble();
              final double confFc1 = (ill1['confidence_fc'] as num).toDouble();
              final double mlScore1 = confAb1 - confFc1;
              final double coverage1 = (ill1['subtype_coverage'] as num).toDouble();

              final String name2 = ill2?['illness'] as String? ?? '—';
              final double confAb2 = (ill2?['confidence_ab'] as num?)?.toDouble() ?? 0.0;
              final double confFc2 = (ill2?['confidence_fc'] as num?)?.toDouble() ?? 0.0;
              final double mlScore2 = confAb2 - confFc2;
              final double coverage2 = (ill2?['subtype_coverage'] as num?)?.toDouble() ?? 0.0;

              return Column(
                children: [
                  // Header
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(82, 170, 164, 0.1),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.r),
                        topRight: Radius.circular(10.r),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(10.w),
                            child: Text(
                              "Top 1: ${ill1['illness']}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Container(width: 1, height: 40.h, color: Colors.grey.withOpacity(0.3)),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(10.w),
                            child: Text(
                              "Top 2: $name2",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Rows
                  _buildComparisonRow(
                    "Confidence Score",
                    confAb1.toStringAsFixed(2),
                    confAb2.toStringAsFixed(2),
                    Colors.red.shade100,
                  ),
                  _buildComparisonRow(
                    "Weighted Symptoms",
                    confFc1.toStringAsFixed(2),
                    confFc2.toStringAsFixed(2),
                    Colors.blue.shade100,
                  ),
                  _buildComparisonRow(
                    "ML Adjustment",
                    mlScore1.toStringAsFixed(2),
                    mlScore2.toStringAsFixed(2),
                    Colors.green.shade100,
                  ),
                  _buildComparisonRow(
                    "Subtype Coverage",
                    coverage1.toStringAsFixed(2),
                    coverage2.toStringAsFixed(2),
                    Colors.orange.shade100,
                    isLast: true,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    ),
  ),
),

    SizedBox(height: 0.h,),

             Positioned(
              top: 0.h,
              child: Center( child: 
              SizedBox(
              width: 325.w, 
              height: 590.h,
              child: Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(25.0), 
                    side: BorderSide.none,
                  ),
                  elevation: 3,
                  child:  Column(
                  children: [
                                        //progress indicator 1
                        if (topDiagnoses.isNotEmpty)         
                          Padding(
                          padding: EdgeInsets.only(top: 20.h,left: 5.w),
                          child: SizedBox(
                            width: 350.w,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Progress Indicator
                                SizedBox(
                                  width: 110.w,
                                  height: 110.w,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        width: 90.w,
                                        height: 90.w,
                                        child: CircularProgressIndicator(
                                          value: topDiagnoses[0]['confidence_ab'] ?? 0.0,
                                          backgroundColor: Colors.grey,
                                          color: const Color.fromARGB(255, 255, 0, 0),
                                          strokeWidth: 8.w,
                                        ),
                                      ),
                                      Container (
                                        height: 50.w,
                                        width: 50.w,
                                         alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50.r),
                                        boxShadow: [
                                        BoxShadow(
                                          color: const Color.fromARGB(255, 208, 38, 38).withOpacity(0.25),  
                                          offset: const Offset(0, 0),                   
                                          blurRadius: 10,                          
                                          spreadRadius: 5,                        
                                        ),
                                      ], 
                                      ),
                                      child:
                                      Text(
                                        "${((topDiagnoses[0]['confidence_ab'] ?? 0.0) * 100).round()}%",
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      )),
                                    ],
                                  ),
                                ),
                                // Text content - now properly aligned
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start, // Ensures left alignment
                                    children: [
                                      Padding(padding: EdgeInsets.only(left: 10.w,top: 15.h),
                                      child: // Padding for left alignment
                                      Text(
                                        topDiagnoses[0]['illness'] ?? "",
                                        softWrap: true,
                                        overflow: TextOverflow.visible,
                                        maxLines: 4,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 22.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      )),
                                      SizedBox(height: 0.h),
                                      Padding(padding: EdgeInsets.only(left: 10.w),
                                      child: // Proper spacing between items
                                      Text(
                                        "Top 1",
                                        softWrap: true,
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          color: const Color.fromARGB(255, 169, 169, 169),
                                          fontWeight: FontWeight.normal,
                                          fontFamily: 'Inter',
                                        )),
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
                                                  illnessName: topDiagnoses[0]['illness']),
                                            ),
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          backgroundColor: Colors.transparent,
                                        ).copyWith(
                                          // remove splash / highlight
                                          overlayColor: WidgetStateProperty.all(Colors.transparent),
                                          // remove any shadow (TextButton normally has none, but just in case)
                                          shadowColor:  WidgetStateProperty.all(Colors.transparent),
                                          elevation:  WidgetStateProperty.all(0),
                                        ),
                                        child: Text(
                                          'See More',
                                          style: TextStyle(
                                            color: const Color.fromRGBO(29, 29, 44, 1.0),
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ),

                                ),

                                Divider(
                                  color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.2),
                                  thickness: 2,
                                  indent: 20.w,
                                  endIndent: 20.w,
                                ),
                                                  

                   if (topDiagnoses.length > 1)  
                                  
                     Padding(
                          padding: EdgeInsets.only(top: 15.h,left: 5.w),
                          child: SizedBox(
                            width: 350.w,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Progress Indicator
                                SizedBox(
                                  width: 110.w,
                                  height: 110.w,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        width: 90.w,
                                        height: 90.w,
                                        child: CircularProgressIndicator(
                                          value: topDiagnoses[1]['confidence_ab'] ?? 0.0,
                                          backgroundColor: Colors.grey,
                                          color: const Color.fromARGB(255, 255, 140, 32),
                                          strokeWidth: 8.w,
                                        ),
                                      ),
                                      Container (
                                        height: 50.w,
                                        width: 50.w,
                                         alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50.r),
                                        boxShadow: [
                                        BoxShadow(
                                          color: const Color.fromARGB(255, 225, 135, 10).withOpacity(0.25),  
                                          offset: const Offset(0, 0),                   
                                          blurRadius: 10,                          
                                          spreadRadius: 5,                        
                                        ),
                                      ], 
                                      ),
                                      child:
                                      Text(
                                        "${((topDiagnoses[1]['confidence_ab'] ?? 0.0) * 100).round()}%",
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      )),
                                    ],
                                  ),
                                ),
                                // Text content - now properly aligned
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start, // Ensures left alignment
                                    children: [
                                      Padding(padding: EdgeInsets.only(left: 10.w,top: 15.h),
                                      child: // Padding for left alignment
                                      Text(
                                        topDiagnoses[1]['illness'] ?? "",
                                        softWrap: true,
                                        overflow: TextOverflow.visible,
                                        maxLines: 4,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 22.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      )),
                                      SizedBox(height: 0.h),
                                      Padding(padding: EdgeInsets.only(left: 10.w),
                                      child: // Proper spacing between items
                                      Text(
                                        "Top 2",
                                        softWrap: true,
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          color: const Color.fromARGB(255, 169, 169, 169),
                                          fontWeight: FontWeight.normal,
                                          fontFamily: 'Inter',
                                        )),
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
                                                illnessName: topDiagnoses[1]['illness']),
                                          ),
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        backgroundColor: Colors.transparent,
                                      ).copyWith(
                                        // remove splash / highlight
                                        overlayColor:  WidgetStateProperty.all(Colors.transparent),
                                        // remove any shadow (TextButton normally has none, but just in case)
                                        shadowColor:  WidgetStateProperty.all(Colors.transparent),
                                        elevation:  WidgetStateProperty.all(0),
                                      ),
                                      child: Text(
                                        'See More',
                                        style: TextStyle(
                                          color: const Color.fromRGBO(29, 29, 44, 1.0),
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    )

                                ), 

                                 Divider(
                                  color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.2),
                                  thickness: 2,
                                  indent: 20.w,
                                  endIndent: 20.w,
                                ), 

                  //progress indicator 3
                                  
                if (topDiagnoses.length > 2)                   
                          Padding(
                          padding: EdgeInsets.only(top: 15.h,left: 5.w),
                          child: SizedBox(
                            width: 350.w,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Progress Indicator
                                SizedBox(
                                  width: 110.w,
                                  height: 110.w,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        width: 90.w,
                                        height: 90.w,
                                        child: CircularProgressIndicator(
                                          value: topDiagnoses[2]['confidence_ab'] ?? 0.0,
                                          backgroundColor: Colors.grey,
                                          color: const Color.fromARGB(255, 13, 253, 0),
                                          strokeWidth: 8.w,
                                        ),
                                      ),
                                      Container (
                                        height: 50.w,
                                        width: 50.w,
                                         alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50.r),
                                        boxShadow: [
                                        BoxShadow(
                                          color: const Color.fromARGB(255, 69, 190, 45).withOpacity(0.25),  
                                          offset: const Offset(0, 0),                   
                                          blurRadius: 10,                          
                                          spreadRadius: 5,                        
                                        ),
                                      ], 
                                      ),
                                      child:
                                      Text(
                                        "${((topDiagnoses[2]['confidence_ab'] ?? 0.0) * 100).round()}%",
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      )),
                                    ],
                                  ),
                                ),
                                // Text content - now properly aligned
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start, // Ensures left alignment
                                    children: [
                                      Padding(padding: EdgeInsets.only(left: 10.w,top: 15.h),
                                      child: // Padding for left alignment
                                      Text(
                                        topDiagnoses[2]['illness'] ?? "",
                                        softWrap: true,
                                        overflow: TextOverflow.visible,
                                        maxLines: 4,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 22.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      )),
                                      SizedBox(height: 0.h),
                                      Padding(padding: EdgeInsets.only(left: 10.w),
                                      child: // Proper spacing between items
                                      Text(
                                        "Top 3",
                                        softWrap: true,
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          color: const Color.fromARGB(255, 169, 169, 169),
                                          fontWeight: FontWeight.normal,
                                          fontFamily: 'Inter',
                                        )),
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
                                              illnessName: topDiagnoses[2]['illness']),
                                        ),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      backgroundColor: Colors.transparent,
                                    ).copyWith(
                                      // remove splash / highlight
                                      overlayColor:  WidgetStateProperty.all(Colors.transparent),
                                      // remove any shadow (TextButton normally has none, but just in case)
                                      shadowColor:  WidgetStateProperty.all(Colors.transparent),
                                      elevation:  WidgetStateProperty.all(0),
                                    ),
                                    child: Text(
                                      'See More',
                                      style: TextStyle(
                                        color: const Color.fromRGBO(29, 29, 44, 1.0),
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  )

                                ),  

                  
                  
                ],
              ))))),
            


             Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    onPressed: () async {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const Center(child: CircularProgressIndicator()),
                        );

                        try {
                          final String? userId = FirebaseAuth.instance.currentUser?.uid;
                          await _generateSymptomDetails(userData);

                          if (userId != null) {
                            final historyCol = FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(userId)
                                  .collection('History');

                              // Query for an existing document for this pet (using petName and petType)
                              final existing = await historyCol
                                  .where('petName', isEqualTo: userData.userName)
                                  .where('petType', isEqualTo: userData.selectedPetType)
                                  .limit(1)
                                  .get();




                                final Map<String, Map<String, dynamic>> metricsWithCm = {};

                                for (var d in diagnoses) {
                                  final illness = d['illness'] as String;
                                  try {
                                    final url  = Uri.parse(AppConfig.getMetricsWithCmURL(illness));
                                    final resp = await http.get(url);
                                    if (resp.statusCode == 200) {
                                      final data = jsonDecode(resp.body);

                                      // Extract confusion matrix
                                      final cmRaw = data['confusion_matrix'] as Map<String, dynamic>;
                                      final confMatrix = {
                                        'TP': cmRaw['TP'] as int,
                                        'FP': cmRaw['FP'] as int,
                                        'FN': cmRaw['FN'] as int,
                                        'TN': cmRaw['TN'] as int,
                                      };

                                      // Extract the flat metrics
                                      final mRaw = data['metrics'] as Map<String, dynamic>;
                                      final metrics = {
                                      'accuracy'   : (mRaw['Accuracy'] as num).toDouble(), 
                                      'precision'  : (mRaw['Precision'] as num).toDouble(),
                                      'recall'     : (mRaw['Recall'] as num).toDouble(),
                                      'specificity': (mRaw['Specificity'] as num).toDouble(),
                                      'f1Score'    : (mRaw['F1 Score'] as num).toDouble(),
                                    };

                                      metricsWithCm[illness] = {
                                        'metrics'          : metrics,
                                        'confusion_matrix': confMatrix,
                                      };
                                    }
                                  } catch (e) {
                                    print("⚠️ Failed to fetch metrics+CM for $illness: $e");
                                  }
                                }
                              // Build a new assessment entry
                              final assessmentEntry = {
                                'date': Timestamp.now(),
                                'diagnosisResults': diagnoses,
                                'allSymptoms': allSymptoms,
                                'symptomDetails': userData.symptomDetails,
                                'Metrics/Confusion': metricsWithCm,    
                              };

                              if (existing.docs.isNotEmpty) {

                                final docRef = existing.docs.first.reference;
                                await docRef.update({
                                  'assessments': FieldValue.arrayUnion([assessmentEntry]),
                                  'date': Timestamp.now(),
                                });
                              } else {
                                // Otherwise, create a new History document with a single-item 'assessments' array.
                                final newHistory = {
                                  'date': Timestamp.now(),
                                  'petType': userData.selectedPetType,
                                  'petName': userData.userName,
                                  'petDetails': petDetails,
                                  'petImage': (userData.petImage?.isNotEmpty == true) ? userData.petImage : "assets/sampleimage.jpg",
                                  'assessments': [assessmentEntry],
                                };
                                await historyCol.add(newHistory);
                              }


                            Provider.of<UserData>(context, listen: false).clearData();
                          }

                          Navigator.pop(context); // Close loading dialog
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePageScreen()));
                        } catch (e) {
                          Navigator.pop(context); // Close loading dialog
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Something went wrong: $e')));
                        }
                      },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.pressed)) {
                          return const Color.fromARGB(255, 0, 0, 0);
                        }
                        return Colors.transparent;
                      }),
                      foregroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.pressed)) {
                          return const Color.fromARGB(255, 255, 255, 255);
                        }
                        return const Color.fromRGBO(29, 29, 44, 1.0);
                      }),
                      shadowColor: WidgetStateProperty.all(Colors.transparent),
                      side: WidgetStateProperty.all(
                        const BorderSide(
                          color: Color.fromRGBO(82, 170, 164, 1),
                          width: 2.0,
                        ),
                      ),
                      shape: WidgetStateProperty.all(
                        const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                        ),
                      ),
                      fixedSize: WidgetStateProperty.all(
                        const Size(100, 55),
                      ),
                    ),
                    child: const Text(
                      "Finish",
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),



            SizedBox(height: 10.h),
          ],
        ),
      ),
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
            )),
      ],)
    )
    );
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}

 
  Widget _smallCell(String illness, String score, Color textColor) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 5.w),
      child: Text(
        '$illness: $score',
        style: TextStyle(color: textColor, fontSize: 15.sp),
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
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, color: const Color.fromARGB(255, 0, 0, 0)),
        ),
      ],
    );
  }

  
// Helper method for comparison rows
  Widget _buildComparisonRow(String label, String value1, String value2, Color bgColor, {bool isLast = false}) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast 
              ? BorderSide.none 
              : BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 120.w,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: bgColor.withOpacity(0.3),
              border: Border(
                right: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: const Color.fromRGBO(29, 29, 44, 0.8),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
              alignment: Alignment.center,
              child: Text(
                value1,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromRGBO(29, 29, 44, 1.0),
                ),
              ),
            ),
          ),
          Container(
            width: 1,
            height: 40.h,
            color: Colors.grey.withOpacity(0.3),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
              alignment: Alignment.center,
              child: Text(
                value2,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromRGBO(29, 29, 44, 1.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
