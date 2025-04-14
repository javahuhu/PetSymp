import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:petsymp/barchart/anotherbarchart.dart';
import '../symptomsdescriptions.dart'; // Contains your illnessInformation map.
 
class HistoryIllnessdetailsScreen extends StatefulWidget {
  final Map<String, dynamic> diagnosisData; // The full diagnosis record passed from the history screen.
  const HistoryIllnessdetailsScreen({Key? key, required this.diagnosisData}) : super(key: key);
 
  @override
  HistoryIllnessdetailsScreenState createState() => HistoryIllnessdetailsScreenState();
}
 
class HistoryIllnessdetailsScreenState extends State<HistoryIllnessdetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
 
    // Retrieve complete illness details using the diagnosis record.
    final Map<String, dynamic>? details = illnessInformation[widget.diagnosisData['illness']];
 
    // Define the keys in the order you wish to display additional illness information.
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
 
    // Use only the passed diagnosisData to build the graph.
    final diagnosis = widget.diagnosisData;
    final labels = [diagnosis['illness'] as String];
    final fc = [(diagnosis['confidence_fc'] as num).toDouble()];
    final gb = [(diagnosis['confidence_gb'] as num).toDouble()];
    final ab = [(diagnosis['confidence_ab'] as num).toDouble()];
 
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
      backgroundColor: const Color.fromRGBO(29, 29, 44, 1.0),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Chart container displaying only the selected diagnosis graph.
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 100.h),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(0, 19, 19, 44),
                  borderRadius: BorderRadius.circular(0),
                ),
                height: 370.h,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  child: Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 50.w,
                      child: BarChartSample3(
                        illnessLabels: labels,
                        fcScores: fc,
                        gbScores: gb,
                        abScores: ab,
                      ),
                    ),
                  ),
                ),
              ),
            ),
 
            Padding(
              padding: EdgeInsets.only(top: 420.h, left: 20.w, right: 5.w),
              child: Text.rich(
                TextSpan(
                  style: TextStyle(
                    color: const Color.fromARGB(255, 127, 127, 127),
                    fontSize: 15.sp,
                  ),
                  children: const [
                    TextSpan(text: "Note: The graph above illustrates the results of different algorithms used in illness analysis. "),
                    TextSpan(text: "Forward Chaining (FC)", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: " provides the initial diagnosis, "),
                    TextSpan(text: "Gradient Boosting (GB)", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: " refines the ranking, and "),
                    TextSpan(text: "AdaBoost (AB)", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: " delivers the final result."),
                  ],
                ),
              ),
            ),
 
            // Expansion cards container for additional illness information.
            Padding(
              padding: EdgeInsets.only(top: 550.h),
              child: Column(
                children: [
                  SizedBox(height: 20.h),
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
 
            // Top bar with back button.
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
                      size: 30,
                      color: Color(0xFFE8F2F5),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  SizedBox(width: screenWidth * 0.13),
                  Text(
                    "Illness Information",
                    style: TextStyle(
                      fontSize: 25.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Oswald',
                      color: const Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("Small Floating Action Button pressed!");
        },
        child: const Icon(Icons.menu_book_sharp),
      ),
      floatingActionButtonLocation: CustomFABLocation(topOffset: 600.0.h, rightOffset: 16.0.w),
    );
  }
 
  Widget _buildExpansionCard({required String title, required String description}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 0.w),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 2.0),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w),
          childrenPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
 
class CustomFABLocation extends FloatingActionButtonLocation {
  final double topOffset;
  final double rightOffset;
 
  CustomFABLocation({this.topOffset = 100.0, this.rightOffset = 16.0});
 
  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final fabSize = scaffoldGeometry.floatingActionButtonSize;
    final double x = scaffoldGeometry.scaffoldSize.width - fabSize.width - rightOffset;
    final double y = topOffset;
    return Offset(x, y);
  }
}
