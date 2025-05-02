import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:petsymp/barchart/anotherbarchart.dart';
import '../illnessdescriptions.dart'; 
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/akar_icons.dart';

class HistoryIllnessdetailsScreen extends StatefulWidget {
  final Map<String, dynamic> diagnosisData;
  final List<Map<String, dynamic>> allDiagnoses;
  final int totalIllnesses;// The full diagnosis record passed from the history screen.
  const HistoryIllnessdetailsScreen({Key? key, required this.diagnosisData, required this.totalIllnesses,required this.allDiagnoses}) : super(key: key);
 
  @override
  HistoryIllnessdetailsScreenState createState() => HistoryIllnessdetailsScreenState();
}
 
class HistoryIllnessdetailsScreenState extends State<HistoryIllnessdetailsScreen> {
  bool _isNavigating = false;


void _showThresholdIllnessesDialog() {
  const double threshold = 0.02;

  final filtered = widget.allDiagnoses.where((ill) {
    final prob = (ill['confidence_softmax'] as num? ?? 0).toDouble();
    return prob >= threshold;
  }).toList();

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text(
        'Possible Illnesses',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: filtered.isEmpty
            ? const Text('No illnesses meet that threshold.')
            : ListView.builder(
                shrinkWrap: true,
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final ill = filtered[i];
                  final name = ill['illness'] as String? ?? 'Unknown';
                  final prob =
                      (ill['confidence_softmax'] as num?)?.toDouble() ?? 0.0;

                  return Container(
                    margin: EdgeInsets.only(bottom: 10.h),
                    padding: EdgeInsets.all(12.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "Probability: ${(prob * 100).toStringAsFixed(1)}%",
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
    ),
  );
}

  
  void _showAllIllnessesDialog() {
  final diagnoses = widget.allDiagnoses;

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text(
        'All Diagnosed Illnesses',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: diagnoses.length,
          itemBuilder: (_, i) {
            final ill = diagnoses[i];
            final name = ill['illness'] as String? ?? 'Unknown';
            final prob = (ill['confidence_softmax'] as num? ?? 0).toDouble();

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "Probability: ${(prob * 100).toStringAsFixed(1)}%",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(191, 41, 168, 210),
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
        )
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
 
    
    final Map<String, dynamic>? details = illnessInformation[widget.diagnosisData['illness']];
 
    
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

    final double softmaxProb = (widget.diagnosisData['confidence_softmax'] as num?)?.toDouble() ?? 0.0;
    final int totalIllnesses = widget.totalIllnesses;

    

  


    return Scaffold(
      backgroundColor: const Color.fromRGBO(29, 29, 44, 1.0),
      body: SingleChildScrollView(
        child: 
        
        Column(
        children: [
        Padding(
          padding: EdgeInsets.only(
            top: 30.h,
            left: 8.w,
            right: 8.w,
          ),
          child:   Center(child:
                  Text(
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
              padding: EdgeInsets.only(right: 24.w, top: 25.h, bottom: 25.h),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(0, 19, 19, 44),
                  borderRadius: BorderRadius.circular(0),
                ),
                height: 300.h,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  child: Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 25.w,
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
              padding: EdgeInsets.only(top: 0.h, left: 30.w, right: 5.w),
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


            
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 50.h),
          child: 
          Column (
          children:[
          
          GestureDetector(
        behavior: HitTestBehavior.opaque,
         onTap: _showThresholdIllnessesDialog,
         child: Container (
          height: 60.h,
         
          decoration: BoxDecoration(
            color: Colors.blueGrey,
            borderRadius: BorderRadius.circular(5.r),
            boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 255, 255, 255).withValues(alpha: 0.1), // Shadow color with opacity
              blurRadius: 12, // Soften the shadow
              spreadRadius: 2, // Extend the shadow
              offset: Offset(0, 0), // Shadow position (x, y)
            ),
          ],
          ),
          child: Align(
          alignment: Alignment.center,
          child:
          Padding(padding: EdgeInsets.symmetric(horizontal: 20.w),
          child:
          Row(
            
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
                color: const Color.fromARGB(255, 203, 211, 219),
                fontSize: 15.sp,
              ),
              children: const [
                TextSpan(text: "Most Probable Diagnosis", style:  TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          )],))))),

          SizedBox(height: 30.h,),
         GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          _showAllIllnessesDialog();
        },
  child: Container(
    height: 60.h,
    decoration: BoxDecoration(
      color: Colors.blueGrey,
      borderRadius: BorderRadius.circular(5.r),
      boxShadow: [
        BoxShadow(
          color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.1),
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
                baseline: 18.sp,
                baselineType: TextBaseline.alphabetic,
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(
                      color: const Color.fromARGB(255, 203, 211, 219),
                      fontSize: 15.sp,
                    ),
                    children: [
                      TextSpan(
                        text: "Probability: ${(softmaxProb * 100).toStringAsFixed(2)}%",
                        style: const TextStyle(fontWeight: FontWeight.bold,),
                      ),
                      TextSpan(
                        text: " ( Top Ranked out of $totalIllnesses Illnesses )",
                        style: const TextStyle(fontWeight: FontWeight.bold),
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
),



          
          
          ]),
        ),
 
            
            Padding(
              padding: EdgeInsets.only(top: 0.h),
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
              
             
 
          ],
        ),
      ),
     
  );}
 
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
 
