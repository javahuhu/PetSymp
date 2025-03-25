import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:petsymp/barchart/barchart.dart';
import 'dart:math' as math;
import 'userdata.dart';
import 'package:provider/provider.dart';
import 'symptomsdescriptions.dart'; // Contains your illnessInformation map.
 
class IllnessdetailsScreen extends StatefulWidget {
  final String illnessName; // The selected illness name.
  const IllnessdetailsScreen({super.key, required this.illnessName});
 
  @override
  IllnessdetailsScreenState createState() => IllnessdetailsScreenState();
}
 
class IllnessdetailsScreenState extends State<IllnessdetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
 
    final userData = Provider.of<UserData>(context);
    final String allSymptoms = userData.petSymptoms.join(" + ");
    // Assume userData.diagnosisResults is already sorted by highest confidence.
    final List<Map<String, dynamic>> diagnoses = userData.diagnosisResults;
    List<Map<String, dynamic>> topDiagnoses = [];
    if (diagnoses.isNotEmpty) {
      topDiagnoses = diagnoses.length >= 3
          ? diagnoses.sublist(0, 3)
          : List<Map<String, dynamic>>.from(diagnoses);
    }
 
    // Prepare data for the bar chart
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
 
    // Retrieve complete illness details from the map using the passed illnessName.
    final Map<String, dynamic>? details = illnessInformation[widget.illnessName];
    // Define the keys in the order you wish to display them.
    final List<String> infoKeys = [
      "Description",
      "Severity",
      "Treatment",
      "Causes",
      "Transmission",
      "Diagnosis",
      "WhatToDo",
      "RecoveryTime",
      "RiskFactors",
      "Prevention",
      "Contagious",
    ];
 
    // Helper function to convert a detail value to a displayable string.
    String detailToString(dynamic value) {
      if (value is List) {
        return value.join("\n\n");
      } else if (value is bool) {
        return value ? "Yes" : "No";
      } else if (value != null) {
        return value.toString();
      }
      return "No information available.";
    }
 
    return Scaffold(
      backgroundColor: Colors.transparent, // remove the flat color
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(29, 29, 44, 1.0),
              Color.fromRGBO(29, 29, 44, 1.0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Stack(
            children: [
              // Top bar with back button and title
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 20,
                  left: 8,
                  right: 8,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_sharp,
                        size: 40,
                        color: Color(0xFFE8F2F5),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    SizedBox(width: screenWidth * 0.05),
                    Text(
                      "Illness Information",
                      style: TextStyle(
                        fontSize: 27.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                        color: const Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                  ],
                ),
              ),
 
              // Graph section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 100.h),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 19, 19, 44),
                    borderRadius: BorderRadius.circular(0),
                  ),
                  height: 250.h,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Consumer<UserData>(
                      builder: (_, userData, __) {
                        final diagnoses = List<Map<String, dynamic>>.from(userData.diagnosisResults)
                          ..sort((a, b) => (b['confidence_ab'] as num).compareTo((a['confidence_ab'] as num)));
                        final top10 = diagnoses.take(10).toList();
                        // Fill up to 10 with empty placeholders
                        while (top10.length < 10) {
                          top10.add({
                            'illness': '',
                            'confidence_fc': 0.0,
                            'confidence_gb': 0.0,
                            'confidence_ab': 0.0
                          });
                        }
 
                        final labels = top10.map((d) => d['illness'] as String).toList();
                        final fc = top10.map((d) => (d['confidence_fc'] as num).toDouble()).toList();
                        final gb = top10.map((d) => (d['confidence_gb'] as num).toDouble()).toList();
                        final ab = top10.map((d) => (d['confidence_ab'] as num).toDouble()).toList();
 
                        final double groupWidth = 20.w;
                        final double gapWidth = 90.w;
                        final double totalRequiredWidth =
                            (groupWidth * labels.length) + (gapWidth * (labels.length - 1));
                        final double screenWidth = MediaQuery.of(context).size.width - 20.w;
                        final double chartWidth =
                            totalRequiredWidth < screenWidth ? screenWidth : totalRequiredWidth;
 
                        return SizedBox(
                          width: chartWidth,
                          child: BarChartSample2(
                            illnessLabels: labels,
                            fcScores: fc,
                            gbScores: gb,
                            abScores: ab,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
 
              // Table section (top 2 illnesses, 4 rows)
              Padding(
                padding: EdgeInsets.only(top: 370.h),
                child: Center(
                  child: Container(
                    color: const Color.fromARGB(255, 19, 19, 44),
                    height: 300.h,
                    width: 360.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            "Illness Comparison",
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFE8F2F5),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 40.h,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Row(
                              children: [
                                _legendDot(Colors.blue, "Confidence Score"),
                                SizedBox(width: 24.w),
                                _legendDot(Colors.green, "Weighted Symptoms Matches"),
                                SizedBox(width: 24.w),
                                _legendDot(Colors.orange, "ML Score Adjustment"),
                                SizedBox(width: 24.w),
                                _legendDot(Colors.purple, "Subtype Coverage Score"),
                              ],
                            ),
                          ),
                        ),
 
                        // Build a dynamic table for top 2 illnesses
                        SizedBox(
                          width: 400.w,
                          child: Builder(
                            builder: (context) {
                              if (topDiagnoses.length < 2) {
                                // If fewer than 2 diagnoses, show a placeholder
                                return Padding(
                                  padding: EdgeInsets.all(10.w),
                                  child: Text(
                                    "Not enough illnesses to compare (need at least 2).",
                                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                                  ),
                                );
                              }
 
                              final ill1 = topDiagnoses[0];
                              final ill2 = topDiagnoses[1];
 
                              // Confidence Score (ab)
                              final double confAb1 = (ill1['confidence_ab'] as num?)?.toDouble() ?? 0.0;
                              final double confAb2 = (ill2['confidence_ab'] as num?)?.toDouble() ?? 0.0;
 
                              // Weighted Symptom Matches (fc)
                              final double confFc1 = (ill1['confidence_fc'] as num?)?.toDouble() ?? 0.0;
                              final double confFc2 = (ill2['confidence_fc'] as num?)?.toDouble() ?? 0.0;
 
                              // ML Score Adjustment = (confidence_ab - confidence_fc)
                              final double mlScore1 = confAb1 - confFc1;
                              final double mlScore2 = confAb2 - confFc2;
 
                              // Placeholder for Subtype Coverage Score
                              // (If you have a real function, compute it here.)
                              final double coverage1 = 75.00;
                              final double coverage2 = 37.50;
 
                              return Table(
                                border: TableBorder(
                             
                                  verticalInside: BorderSide(color: Colors.grey.shade700, width: 1),
                                ),
                                children: [
                                  // 1st Row: Confidence Score
                                  TableRow(
                                    children: [
                                      _smallCell(
                                        ill1['illness'],
                                        confAb1.toStringAsFixed(2),
                                        Colors.blue,
                                      ),
                                      _smallCell(
                                        ill2['illness'],
                                        confAb2.toStringAsFixed(2),
                                        Colors.blue,
                                      ),
                                    ],
                                  ),
                                  // 2nd Row: Weighted Symptom Matches
                                  TableRow(
                                    children: [
                                      _smallCell(
                                        ill1['illness'],
                                        confFc1.toStringAsFixed(2),
                                        Colors.green,
                                      ),
                                      _smallCell(
                                        ill2['illness'],
                                        confFc2.toStringAsFixed(2),
                                        Colors.green,
                                      ),
                                    ],
                                  ),
                                  // 3rd Row: ML Score Adjustment
                                  TableRow(
                                    children: [
                                      _smallCell(
                                        ill1['illness'],
                                        mlScore1.toStringAsFixed(2),
                                        Colors.orange,
                                      ),
                                      _smallCell(
                                        ill2['illness'],
                                        mlScore2.toStringAsFixed(2),
                                        Colors.orange,
                                      ),
                                    ],
                                  ),
                                  // 4th Row: Subtype Coverage Score
                                  TableRow(
                                    children: [
                                      _smallCell(
                                        ill1['illness'],
                                        coverage1.toStringAsFixed(2),
                                        Colors.purple,
                                      ),
                                      _smallCell(
                                        ill2['illness'],
                                        coverage2.toStringAsFixed(2),
                                        Colors.purple,
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
 
                        SizedBox(height: screenHeight * 0.02),
                        // (Other text content can remain if needed)
                      ],
                    ),
                  ),
                ),
              ),
 
              // Main content: complete illness details from illnessInformation
              Padding(
                padding: EdgeInsets.only(top: 700.h),
                child: Column(
                  children: [
                    SizedBox(height: 20.h),
                    // Dynamically build expansion cards for each info key.
                    Column(
                      children: infoKeys.map((key) {
                        return _buildExpansionCard(
                          title: key,
                          description: details != null && details.containsKey(key)
                              ? detailToString(details[key])
                              : "No information available.",
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 50.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
 
  Widget _smallCell(String illness, String score, Color textColor) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.1.h, horizontal: 15.w),
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
          style: TextStyle(fontSize: 14.sp, color: Colors.white),
        ),
      ],
    );
  }
 
  Widget _buildExpansionCard({
    required String title,
    required String description,
  }) {
    return Center(
      child: SizedBox(
        width: 350.w,
        child: Card(
          color: const Color(0xFFE8F2F5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 3,
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.symmetric(horizontal: 16.w),
              childrenPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              title: Text(
                title,
                style: TextStyle(
                  fontSize: 17.sp,
                  color: const Color.fromRGBO(29, 29, 44, 1.0),
                ),
              ),
              children: [
                Text(
                  description,
                  softWrap: true,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    fontSize: 18.sp,
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: 12.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
