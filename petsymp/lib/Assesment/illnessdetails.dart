import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:petsymp/barchart/anotherbarchart.dart';
import '../userdata.dart';
import 'package:provider/provider.dart';
import '../illnessdescriptions.dart'; // Contains your illnessInformation map.
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/akar_icons.dart';

class IllnessdetailsScreen extends StatefulWidget {
  final String illnessName; // The selected illness name.
  const IllnessdetailsScreen({super.key, required this.illnessName});

  @override
  IllnessdetailsScreenState createState() => IllnessdetailsScreenState();
}

class IllnessdetailsScreenState extends State<IllnessdetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    // Retrieve complete illness details from the map using the passed illnessName.
    final Map<String, dynamic>? details =
        illnessInformation[widget.illnessName];
    // Define the keys in the order you wish to display them.
    final List<String> infoKeys = [
      "Description",
      "Severity",
      "Treatment",
      "Causes",
      "Transmission",
      "Diagnosis",
      "What To Do",
      "Recovery Time",
      "Risk Factors",
      "Prevention",
      "Contagious",
    ];

    // Assume userData.diagnosisResults is already sorted by highest confidence.

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

    // Get diagnosis data for this illness
    final diagnosis =
        Provider.of<UserData>(context).diagnosisResults.firstWhere(
              (d) => d['illness'] == widget.illnessName,
              orElse: () => {},
            );

    final List<Map<String, dynamic>> allDiagnoses =
        Provider.of<UserData>(context).diagnosisResults;

// Extract the SoftMax confidence, default to 0.0 if not found
    final double softmaxProb =
        (diagnosis['confidence_softmax'] as num?)?.toDouble() ?? 0.0;
    final int totalIllnesses = allDiagnoses.length;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(29, 29, 44, 1.0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top bar with back button (placed last to ensure it's on top)
            Padding(
              padding: EdgeInsets.only(
                top: 30.h,
                left: 8.w,
                right: 8.w,
              ),
              child: Center(
                  child: Text(
                "Illness Information",
                style: TextStyle(
                  fontSize: 25.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Oswald',
                  color: const Color.fromARGB(255, 255, 255, 255),
                ),
              )),
            ),

            Padding(
              padding: EdgeInsets.only(right: 23.w, top: 25.h, bottom: 25.h),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(0, 19, 19, 44),
                  borderRadius: BorderRadius.circular(0),
                ),
                height: 370.h,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  child: Consumer<UserData>(
                    builder: (_, userData, __) {
                      final diagnosis = userData.diagnosisResults.firstWhere(
                        (d) => d['illness'] == widget.illnessName,
                        orElse: () => {
                          'illness': widget.illnessName,
                          'confidence_fc': 0.0,
                          'confidence_gb': 0.0,
                          'confidence_ab': 0.0,
                          'subtype_coverage': 0.0,
                        },
                      );
                      final labels = [diagnosis['illness'] as String];
                      final fc = [
                        (diagnosis['confidence_fc'] as num).toDouble()
                      ];
                      final gb = [
                        (diagnosis['confidence_gb'] as num).toDouble()
                      ];
                      final ab = [
                        (diagnosis['confidence_ab'] as num).toDouble()
                      ];

                      final double chartWidth =
                          MediaQuery.of(context).size.width - 25.w;

                      return Center(
                        child: SizedBox(
                          width: chartWidth,
                          child: BarChartSample3(
                            illnessLabels: labels,
                            fcScores: fc,
                            gbScores: gb,
                            abScores: ab,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.only(top: 0.h, left: 24.w, right: 2.w),
              child: Text.rich(
                TextSpan(
                  style: TextStyle(
                    color: const Color.fromARGB(255, 127, 127, 127),
                    fontSize: 15.sp,
                  ),
                  children: const [
                    TextSpan(
                        text:
                            "Note: The graph above illustrates the results of different algorithms used in illness analysis. "),
                    TextSpan(
                        text: "Forward Chaining (FC)",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: " provides the initial diagnosis, "),
                    TextSpan(
                        text: "Gradient Boosting (GB)",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: " refines the ranking, and "),
                    TextSpan(
                        text: "AdaBoost (AB)",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: " delivers the final result."),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 50.h),
              child: Column(children: [
                GestureDetector(
                  onTap: () {
                    final List<Map<String, dynamic>> allDiagnoses =
                        Provider.of<UserData>(context, listen: false)
                            .diagnosisResults;

                    final List<Map<String, dynamic>> filteredDiagnoses =
                        allDiagnoses
                            .where((d) =>
                                ((d['confidence_softmax'] as num?)
                                        ?.toDouble() ??
                                    0.0) >=
                                0.02)
                            .toList();

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text(
                            'Possible Illnesses',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          content: SizedBox(
                            width: double.maxFinite,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: filteredDiagnoses.length,
                              itemBuilder: (context, index) {
                                final diagnosis = filteredDiagnoses[index];
                                final illnessName =
                                    diagnosis['illness'] ?? 'Unknown Illness';
                                final probability =
                                    (diagnosis['confidence_softmax'] as num?)
                                            ?.toDouble() ??
                                        0.0;

                                return Container(
                                  margin: EdgeInsets.only(bottom: 10.h),
                                  padding: EdgeInsets.all(12.h),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5.r),
                                    boxShadow:const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        illnessName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.sp,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        "Probability: ${(probability * 100).toStringAsFixed(2)}%",
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: const Color.fromARGB(
                                              191, 41, 168, 210),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Container(
                    height: 60.h,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 255, 255, 255)
                              .withAlpha(25),
                          blurRadius: 12,
                          spreadRadius: 2,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lightbulb_circle_outlined,
                              color: const Color.fromARGB(255, 203, 211, 219),
                              size: 24.0.sp,
                            ),
                            SizedBox(width: 10.w),
                            Text.rich(
                              TextSpan(
                                style: TextStyle(
                                  color:
                                      const Color.fromARGB(255, 203, 211, 219),
                                  fontSize: 15.sp,
                                ),
                                children: const [
                                  TextSpan(
                                    text: "Most Probable Diagnosis",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30.h,
                ),
                GestureDetector(
                  onTap: () {
                    final List<Map<String, dynamic>> allDiagnoses =
                        Provider.of<UserData>(context, listen: false)
                            .diagnosisResults;

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text(
                            'All Diagnosed Illnesses',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          content: SizedBox(
                            width: double.maxFinite,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: allDiagnoses.length,
                              itemBuilder: (context, index) {
                                final diagnosis = allDiagnoses[index];
                                final illnessName =
                                    diagnosis['illness'] ?? 'Unknown Illness';
                                final probability =
                                    (diagnosis['confidence_softmax'] as num?)
                                            ?.toDouble() ??
                                        0.0;

                                return Container(
                                  margin: EdgeInsets.only(bottom: 10.h),
                                  padding: EdgeInsets.all(12.h),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5.r),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        illnessName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.sp,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        "Probability: ${(probability * 100).toStringAsFixed(2)}%",
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: const Color.fromARGB(
                                              191, 41, 168, 210),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Container(
                    height: 60.h,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 255, 255, 255)
                              .withAlpha(25),
                          blurRadius: 12,
                          spreadRadius: 2,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Iconify(
                              AkarIcons.statistic_up,
                              size: 24.0.sp,
                              color: const Color.fromARGB(255, 203, 211, 219),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Baseline(
                                baseline: 25.sp,
                                baselineType: TextBaseline.alphabetic,
                                child: Text.rich(
                                  TextSpan(
                                    style: TextStyle(
                                      color: const Color.fromARGB(
                                          255, 203, 211, 219),
                                      fontSize: 15.sp,
                                    ),
                                    children: [
                                      TextSpan(
                                        text:
                                            "Probability: ${(softmaxProb * 100).toStringAsFixed(2)}%",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(
                                        text:
                                            " ( Top Ranked out of $totalIllnesses Illnesses )",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ]),
            ),

            Padding(
              padding: EdgeInsets.only(top: 10.h),
              child: Column(
                children: [
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
    );
  }

  Widget _buildExpansionCard(
      {required String title, required String description}) {
    return Container(
      width: double.infinity, // full available width
      margin:
          EdgeInsets.symmetric(horizontal: 0.w), // optional horizontal margin
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 2.0), // bottom border
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w),
          childrenPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 17.sp,
              color: const Color(0xFFE8F2F5),
            ),
          ),
          children: [
            Text(
              description,
              softWrap: true,
              style: TextStyle(
                color: const Color.fromARGB(255, 97, 195, 188),
                fontSize: 18.sp,
                fontFamily: 'Inter',
              ),
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }
}
