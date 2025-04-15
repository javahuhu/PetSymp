import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'barresources.dart';
import 'package:provider/provider.dart';
import 'package:petsymp/userdata.dart';
import 'package:petsymp/Connection/dynamicconnections.dart';

class BarChartSample2 extends StatefulWidget {
  final List<String> illnessLabels;
  final List<double> fcScores;
  final List<double> gbScores;
  final List<double> abScores;

  const BarChartSample2({
    super.key,
    required this.illnessLabels,
    required this.fcScores,
    required this.gbScores,
    required this.abScores,
  });

  final Color fcColor = const Color.fromARGB(255, 0, 34, 255);
  final Color gbColor = AppColors.contentColorRed;
  final Color abColor = AppColors.contentColorOrange;

  @override
  State<BarChartSample2> createState() => _BarChartSample2State();
}

// New model to represent a symptom's details from the knowledge base.
class SymptomDetail {
  final String name;
  final double baseWeight;
  final String severity;
  final double priority;

  // Add FC → GB → AB fields
  final double fcWeight;
  final double gbAdjustment;
  final double gbWeight;
  final double abFactor;
  final double abWeight;

  SymptomDetail({
    required this.name,
    required this.baseWeight,
    required this.severity,
    required this.priority,
    required this.fcWeight,
    required this.gbAdjustment,
    required this.gbWeight,
    required this.abFactor,
    required this.abWeight,
  });

  factory SymptomDetail.fromJson(Map<String, dynamic> json) {
    return SymptomDetail(
      name: json['name'] as String,
      baseWeight: (json['base_weight'] as num).toDouble(),
      severity: json['severity'] as String,
      priority: (json['priority'] as num).toDouble(),
      fcWeight: (json['fc_weight'] as num).toDouble(),
      gbAdjustment: (json['gb_adjustment'] as num).toDouble(),
      gbWeight: (json['gb_weight'] as num).toDouble(),
      abFactor: (json['ab_factor'] as num).toDouble(),
      abWeight: (json['ab_weight'] as num).toDouble(),
    );
  }
}






// Internal chart data model.
class _ChartData {
  _ChartData(this.x, this.y);
  final String x;
  final double y;
}

class _BarChartSample2State extends State<BarChartSample2> {
  final double width = 7;
  late List<BarChartGroupData> rawBarGroups;
  late List<BarChartGroupData> showingBarGroups;
  int touchedGroupIndex = -1;

 
   Future<List<SymptomDetail>> _fetchKnowledgeDetailsForIllness(String illness) async {
    final url = Uri.parse(AppConfig.getKnowledgeDetailsURL(illness));
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> detailsJson = data["knowledge"] as List<dynamic>;
      return detailsJson
          .map((item) => SymptomDetail.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception("Failed to load knowledge details");
    }
  }


  Map<String, double> _computeFinalScores(List<SymptomDetail> symptoms, String illnessName) {
  final userData = Provider.of<UserData>(context, listen: false);
  final match = userData.diagnosisResults.firstWhere(
    (element) => element['illness'] == illnessName,
    orElse: () => {
      'confidence_fc': 0.0,
      'confidence_gb': 0.0,
      'confidence_ab': 0.0,
    },
  );

  return {
    "confidence_fc": (match['confidence_fc'] ),
    "confidence_gb": (match['confidence_gb'] ),
    "confidence_ab": (match['confidence_ab'] ),
  };
}


  @override
  void initState() {
    rawBarGroups = List.generate(widget.illnessLabels.length, (index) {
      return makeGroupData(
        index,
        widget.fcScores[index],
        widget.gbScores[index],
        widget.abScores[index],
      );
    });
    showingBarGroups = List.of(rawBarGroups);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

 

    return AspectRatio(
      aspectRatio: 1.3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                makeTransactionsIcon(),
                const SizedBox(width: 38),
                Text(
                  'Confidence Comparison',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    fontSize: 22.sp,
                    fontFamily: 'Oswald',
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: BarChart(
                BarChartData(
                  maxY: 100,
                  groupsSpace: 20,
                  barGroups: showingBarGroups,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final algorithm = ['FC', 'GB', 'AB'][rodIndex];
                        return BarTooltipItem(
                          '$algorithm: ${rod.toY.toStringAsFixed(0)}',
                          const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                        );
                      },
                    ),
                    touchCallback: (event, response) {
                      if (response == null || response.spot == null) {
                        setState(() {
                          touchedGroupIndex = -1;
                          showingBarGroups = List.of(rawBarGroups);
                        });
                        return;
                      }
                      final index = response.spot!.touchedBarGroupIndex;
                      if (event is FlTapUpEvent) {
                        // Show the dialog using a FutureBuilder to fetch the details.
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            
                            return FutureBuilder<List<SymptomDetail>>(
                      future: _fetchKnowledgeDetailsForIllness(widget.illnessLabels[index]),
                      builder: (context, snapshot) {
                        
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return AlertDialog(
                            title: const Text("Loading details..."),
                            content: SizedBox(
                              height: 100.h,
                              child: const Center(child: CircularProgressIndicator()),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return AlertDialog(
                            title: const Text("Error"),
                            content: Text(snapshot.error.toString()),
                          );
                        } else {

                      
                          final details = snapshot.data!;
                          // Get user input symptoms from the provider.
                          final userData = Provider.of<UserData>(context, listen: false);
                          final userSymptoms = userData.petSymptoms.map((s) => s.toLowerCase()).toList();
                           
                          final illnessName = widget.illnessLabels[index];
                          final result = userData.diagnosisResults.firstWhere(
                            (illness) => illness['illness'] == illnessName,
                            orElse: () => {
                              'confidence_fc': 0.0,
                              'confidence_gb': 0.0,
                              'confidence_ab': 0.0,
                            },
                          );
                          
   
                          // Filter the fetched details to only include symptoms that match the user input.
                          final filteredDetails = details.where((d) => userSymptoms.contains(d.name.toLowerCase())).toList();
                          final scores = _computeFinalScores(filteredDetails, illnessName);

                          
                          // If no matching symptoms, you can show a message.
                          if (filteredDetails.isEmpty) {
                            return AlertDialog(
                              title: const Text("No Matching Symptoms"),
                              content:  const  Text("The selected illness does not contain any symptoms that match your input."),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child:const Text("OK"),
                                ),
                              ],
                            );
                          }

                          // Build chart data from the filtered details.
                          final List<_ChartData> chartData =
                              filteredDetails.map((d) => _ChartData(d.name, d.baseWeight)).toList();

                          return AlertDialog(
                            insetPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            title: Text("Why ${widget.illnessLabels[index]} ?"),
                            content: SizedBox(
                              width: 500.w,
                              height: 600.h,
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Doughnut chart displaying the filtered symptom base weights.
                                    Center(
                                      child: SizedBox(
                                        height: 250.w,
                                        width: 250.w,
                                        child: SfCircularChart(
                                          tooltipBehavior: TooltipBehavior(enable: true),
                                          series: <CircularSeries<_ChartData, String>>[
                                            DoughnutSeries<_ChartData, String>(
                                              dataSource: chartData,
                                              xValueMapper: (_ChartData data, _) => data.x,
                                              yValueMapper: (_ChartData data, _) => data.y,
                                              dataLabelSettings: const DataLabelSettings(isVisible: true),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        "Symptoms Doughnut Graph",
                                        style: TextStyle(fontSize: 22.sp, fontFamily: 'Oswald'),
                                      ),
                                    ),
                                    SizedBox(height: 20.h),
                                    // Table showing each filtered symptom's details.
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Table(
                                        defaultColumnWidth: FixedColumnWidth(200.w),
                                        textDirection: TextDirection.ltr,
                                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                        border: TableBorder.all(width: 1, color: const Color.fromARGB(255, 151, 150, 150)),
                                        children: [
                                          const TableRow(
                                            children: [
                                              Center(child: Text("Symptom", textScaleFactor: 1.4, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold))),
                                              Center(child: Text("Base Weight", textScaleFactor: 1.4, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold))),
                                              Center(child: Text("Severity", textScaleFactor: 1.4, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold))),
                                              Center(child: Text("Priority", textScaleFactor: 1.4, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold))),
                                            ],
                                          ),
                                          ...filteredDetails.map((d) {
                                            return TableRow(
                                              children: [
                                                Center(child: Padding(padding: const EdgeInsets.all(8.0), child: Text(d.name, style: const TextStyle(fontFamily: 'Inter')))),
                                                Center(child: Padding(padding: const EdgeInsets.all(8.0), child: Text(d.baseWeight.toString(), style: const TextStyle(fontFamily: 'Inter')))),
                                                Center(child: Padding(padding: const EdgeInsets.all(8.0), child: Text(d.severity, style: const TextStyle(fontFamily: 'Inter')))),
                                                Center(child: Padding(padding: const EdgeInsets.all(8.0), child: Text(d.priority.toString(), style: const TextStyle(fontFamily: 'Inter')))),
                                              ],
                                            );
                                          }).toList(),
                                        ],
                                      ),
                                    ),
                                    // Keep the remaining UI sections (Forward Chaining, Gradient Boosting, Ada Boost) unchanged.
                                    SizedBox(height: 15.h),
                                    Center(
                                      child: Text(
                                        "Forward Chaining",
                                        style: TextStyle(fontSize: 22.sp, fontFamily: 'Oswald'),
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                     SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Table(
                                        defaultColumnWidth:  FixedColumnWidth(155.w),
                                        textDirection: TextDirection.ltr,
                                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                        border: TableBorder.all(width: 1, color: const Color.fromARGB(255, 151, 150, 150)),
                                        children: [
                                          const TableRow(
                                            children: [
                                              Center(child: Text("Symptom", textScaleFactor: 1.4, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter'))),
                                              Center(child: Text("FC Weight", textScaleFactor: 1.4, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter'))),
                                            ],
                                          ),
                                          ...filteredDetails.map((d) {
                                            return TableRow(
                                              children: [
                                                Center(child: Padding(padding: const EdgeInsets.all(8.0), child: Text(d.name, style:  TextStyle(fontFamily: 'Inter', fontSize: 15.sp)))),
                                                Center(child: Padding(padding: const EdgeInsets.all(8.0), child: Text(d.fcWeight.toStringAsFixed(2), style: TextStyle(fontFamily: 'Inter', fontSize: 15.sp)))),
                                                
                                              ],
                                            );
                                          }).toList(),
                                        ],
                                     )),
                                    

                                    SizedBox(height: 15.h),
                                    Padding(
                                      padding: EdgeInsets.only(right: 210.w),
                                      child: Text(
                                        "Formula:",
                                        style: TextStyle(fontSize: 18.sp, fontFamily: 'Inter', color: Colors.blueAccent),
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                    Center(
                                      child: Text(
                                        "Base × Severity × Priority",
                                        style: TextStyle(fontSize: 18.sp, fontFamily: 'Oswald'),
                                      ),
                                    ),

                                    
                           SizedBox(height: 60.h),
                            Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blueAccent,
                                size: 24.sp,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    style: TextStyle(
                                      color: const Color.fromARGB(255, 127, 127, 127),
                                      fontSize: 12.sp,
                                    ),
                                    children: const [
                                      const TextSpan(
                                          text:
                                              "Note: The graph above illustrates the results of different algorithms used in illness analysis. "),
                                      const TextSpan(
                                          text: "Forward Chaining (FC)",
                                          style: TextStyle(fontWeight: FontWeight.bold)),
                                      const TextSpan(text: " provides the initial diagnosis, "),
                                      const TextSpan(
                                          text: "Gradient Boosting (GB)",
                                          style: TextStyle(fontWeight: FontWeight.bold)),
                                      const TextSpan(text: " refines the ranking, and "),
                                      const TextSpan(
                                          text: "AdaBoost (AB)",
                                          style: TextStyle(fontWeight: FontWeight.bold)),
                                      const TextSpan(text: " delivers the final result."),
                                    ],
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),


                                    


                                       SizedBox(height: 50.h,),
                  Center(
                      child: Text(
                            "Gradient Boosting",
                            style: TextStyle(fontSize: 18.sp, fontFamily: 'Oswald'),
                          ),
                        ),


                                    SizedBox(height: 10.h,),

                   SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child:Table(
                  defaultColumnWidth:  FixedColumnWidth(155.w),
                  textDirection: TextDirection.ltr,
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  border: TableBorder.all(width: 1, color: const Color.fromARGB(255, 151, 150, 150)),
                  children: [
                    const TableRow(
                      children: [
                        Center(
                            child: Text("GB Adjustment",
                                textScaleFactor: 1.4,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontFamily: 'Inter'))),
                        Center(
                            child: Text("GB Weight",
                                textScaleFactor: 1.4,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontFamily: 'Inter'))),
                      ],
                    ),
                    ...filteredDetails.map((d) {
                      return TableRow(
                        children: [
                          Center(
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    d.gbAdjustment.toStringAsFixed(2),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontFamily: 'Inter', fontSize: 15.sp),
                                  ))),
                          Center(
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    d.gbWeight.toStringAsFixed(2),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontFamily: 'Inter', fontSize: 15.sp),
                                  ))),
                        ],
                      );
                    }).toList(),
                  ],
                )),


                SizedBox(height: 15.h,),
              Padding(
                padding: EdgeInsets.only(right: 210.w),
                  child: Text(
                        "Formula:",
                        style: TextStyle(fontSize: 18.sp, fontFamily: 'Inter', color: Colors.blueAccent),
                      ),
                    ),


                SizedBox(height: 10.h,),
              Center(
                  child: Text(
                        "FC Weight + GB Adjustment",
                        style: TextStyle(fontSize: 18.sp, fontFamily: 'Oswald'),
                      ),
                    ),


                    
                           SizedBox(height: 60.h),
                            Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blueAccent,
                                size: 24.sp,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    style: TextStyle(
                                      color: const Color.fromARGB(255, 127, 127, 127),
                                      fontSize: 12.sp,
                                    ),
                                    children: const [
                                      const TextSpan(
                                          text:
                                              "Note: The graph above illustrates the results of different algorithms used in illness analysis. "),
                                      const TextSpan(
                                          text: "Forward Chaining (FC)",
                                          style: TextStyle(fontWeight: FontWeight.bold)),
                                      const TextSpan(text: " provides the initial diagnosis, "),
                                      const TextSpan(
                                          text: "Gradient Boosting (GB)",
                                          style: TextStyle(fontWeight: FontWeight.bold)),
                                      const TextSpan(text: " refines the ranking, and "),
                                      const TextSpan(
                                          text: "AdaBoost (AB)",
                                          style: TextStyle(fontWeight: FontWeight.bold)),
                                      const TextSpan(text: " delivers the final result."),
                                    ],
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),





                    

                     SizedBox(height: 50.h,),
                  Center(
                      child: Text(
                            "Ada Boost",
                            style: TextStyle(fontSize: 22.sp, fontFamily: 'Oswald'),
                          ),
                        ),


                    SizedBox(height: 10.h,),
                     SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Table(
                    defaultColumnWidth:  FixedColumnWidth(155.w),
                    textDirection: TextDirection.ltr,
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    border: TableBorder.all(width: 1, color: const Color.fromARGB(255, 151, 150, 150)),
                    children: [
                      const TableRow(
                        children: [
                          Center(
                            child: Text(
                              "AB Factor",
                              textScaleFactor: 1.4,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontFamily: 'Inter'),
                            ),
                          ),
                          Center(
                            child: Text(
                              "AB Weight",
                              textScaleFactor: 1.4,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontFamily: 'Inter'),
                            ),
                          ),
                        ],
                      ),
                      ...filteredDetails.map((d) {
                        return TableRow(
                          children: [
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  d.abFactor.toStringAsFixed(2),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontFamily: 'Inter', fontSize: 15.sp),
                                ),
                              ),
                            ),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  d.abWeight.toStringAsFixed(2),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontFamily: 'Inter', fontSize: 15.sp),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  )),



                SizedBox(height: 15.h,),
              Padding(
                padding: EdgeInsets.only(right: 210.w),
                  child: Text(
                        "Formula:",
                        style: TextStyle(fontSize: 18.sp, fontFamily: 'Inter', color: Colors.blueAccent),
                      ),
                    ),


                SizedBox(height: 10.h,),
              Center(
                  child: Text(
                        "GB Weight × AB Factor",
                        style: TextStyle(fontSize: 18.sp, fontFamily: 'Oswald'),
                      ),
                    ),
                           SizedBox(height: 60.h),
                            Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blueAccent,
                                size: 24.sp,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    style: TextStyle(
                                      color: const Color.fromARGB(255, 127, 127, 127),
                                      fontSize: 12.sp,
                                    ),
                                    children: const [
                                      const TextSpan(
                                          text:
                                              "Note: The graph above illustrates the results of different algorithms used in illness analysis. "),
                                      const TextSpan(
                                          text: "Forward Chaining (FC)",
                                          style: TextStyle(fontWeight: FontWeight.bold)),
                                      const TextSpan(text: " provides the initial diagnosis, "),
                                      const TextSpan(
                                          text: "Gradient Boosting (GB)",
                                          style: TextStyle(fontWeight: FontWeight.bold)),
                                      const TextSpan(text: " refines the ranking, and "),
                                      const TextSpan(
                                          text: "AdaBoost (AB)",
                                          style: TextStyle(fontWeight: FontWeight.bold)),
                                      const TextSpan(text: " delivers the final result."),
                                    ],
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),





                          SizedBox(height: 30.h),
                          Center(
                            child: Text(
                              "Complete Symptom Breakdown",
                              style: TextStyle(fontSize: 20.sp, fontFamily: 'Oswald'),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Table(
                              defaultColumnWidth: FixedColumnWidth(140.w),
                              textDirection: TextDirection.ltr,
                              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                              border: TableBorder.all(width: 1, color: Colors.grey),
                              children: [
                                const TableRow(
                                  decoration: BoxDecoration(color: Color.fromARGB(255, 239, 239, 239)),
                                  children: [
                                    Center(child: Padding(padding: EdgeInsets.all(8), child: Text("Symptom", style: TextStyle(fontWeight: FontWeight.bold)))),
                                    Center(child: Padding(padding: EdgeInsets.all(8), child: Text("FC Weight", style: TextStyle(fontWeight: FontWeight.bold)))),
                                    Center(child: Padding(padding: EdgeInsets.all(8), child: Text("GB Adj.", style: TextStyle(fontWeight: FontWeight.bold)))),
                                    Center(child: Padding(padding: EdgeInsets.all(8), child: Text("GB Weight", style: TextStyle(fontWeight: FontWeight.bold)))),
                                    Center(child: Padding(padding: EdgeInsets.all(8), child: Text("AB Factor", style: TextStyle(fontWeight: FontWeight.bold)))),
                                    Center(child: Padding(padding: EdgeInsets.all(8), child: Text("AB Weight", style: TextStyle(fontWeight: FontWeight.bold)))),
                                  ],
                                ),
                                ...filteredDetails.map((d) {
                                  return TableRow(
                                    children: [
                                      Center(child: Padding(padding: const EdgeInsets.all(8.0), child: Text(d.name))),
                                      Center(child: Padding(padding: const EdgeInsets.all(8.0), child: Text(d.fcWeight.toStringAsFixed(2)))),
                                      Center(child: Padding(padding: const EdgeInsets.all(8.0), child: Text(d.gbAdjustment.toStringAsFixed(2)))),
                                      Center(child: Padding(padding: const EdgeInsets.all(8.0), child: Text(d.gbWeight.toStringAsFixed(2)))),
                                      Center(child: Padding(padding: const EdgeInsets.all(8.0), child: Text(d.abFactor.toStringAsFixed(2)))),
                                      Center(child: Padding(padding: const EdgeInsets.all(8.0), child: Text(d.abWeight.toStringAsFixed(2)))),
                                    ],
                                  );
                                }).toList(),
                              ],
                            ),
                          ),






                          
                                       SizedBox(height: 50.h,),
                                

                                 SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Table(
                                  defaultColumnWidth: FixedColumnWidth(160.w),
                                  border: TableBorder.all(width: 1, color: Colors.grey),
                                  children: [
                                    const TableRow(
                                      children: [
                                        Center(child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text("Algorithm", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                                        )),
                                        Center(child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text("Final Score", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                                        )),
                                      ],
                                    ),
                                    TableRow(
                                      children: [
                                        const Center(child: Padding(padding: EdgeInsets.all(8.0), child: Text("Forward Chaining", style: TextStyle(fontFamily: 'Inter')))),
                                        Center(child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text("${scores["confidence_fc"]!.toStringAsFixed(2)}%", style: TextStyle(fontFamily: 'Inter')),
                                        )),
                                      ],
                                    ),
                                    TableRow(
                                      children: [
                                        const Center(child: Padding(padding: EdgeInsets.all(8.0), child: Text("Gradient Boosting", style: TextStyle(fontFamily: 'Inter')))),
                                        Center(child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text("${scores["confidence_gb"]!.toStringAsFixed(2)}%", style: TextStyle(fontFamily: 'Inter')),
                                        )),
                                      ],
                                    ),
                                    TableRow(
                                       decoration: BoxDecoration(color: Color.fromARGB(255, 121, 216, 104)),
                                      children: [
                                        const Center(child: Padding(padding: EdgeInsets.all(8.0), child: Text("AdaBoost", style: TextStyle(fontFamily: 'Inter')))),
                                        Center(child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text("${scores["confidence_ab"]!.toStringAsFixed(2)}%", style: TextStyle(fontFamily: 'Inter')),
                                        )),
                                      ],
                                    ),
                                  ],
                                )),


                            SizedBox(height: 15.h,),
                            Center(
                              child: Text(
                                "Final Score",
                                style: TextStyle(fontSize: 18.sp, fontFamily: 'Oswald'),
                              ),
                            ),
                            SizedBox(height: 60.h,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.blueAccent,
                                  size: 24.sp,
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      style: TextStyle(
                                        color: const Color.fromARGB(255, 127, 127, 127),
                                        fontSize: 12.sp,
                                      ),
                                      children: const [
                                        TextSpan(
                                            text: "Note: The table above illustrates the final scores computed using different algorithms. "),
                                        TextSpan(
                                            text: "Forward Chaining (FC)",
                                            style: TextStyle(fontWeight: FontWeight.bold)),
                                        TextSpan(text: ", "),
                                        TextSpan(
                                            text: "Gradient Boosting (GB)",
                                            style: TextStyle(fontWeight: FontWeight.bold)),
                                        TextSpan(text: ", and "),
                                        TextSpan(
                                            text: "AdaBoost (AB)",
                                            style: TextStyle(fontWeight: FontWeight.bold)),
                                        TextSpan(text: " are combined to produce the Final Score."),
                                      ],
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 30),


              


                                    // ... (keep the Gradient Boosting and Ada Boost sections unchanged)
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    );

                          },
                        );
                      }
                      setState(() {
                        if (!event.isInterestedForInteractions) {
                          touchedGroupIndex = -1;
                          showingBarGroups = List.of(rawBarGroups);
                        } else {
                          touchedGroupIndex = index;
                          showingBarGroups = List.of(rawBarGroups);
                        }
                      });
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 20,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}',
                          style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= widget.illnessLabels.length) return const SizedBox.shrink();
                          String label = widget.illnessLabels[i];
                          if (label.length > 10) label = '${label.substring(0, 10)}…';
                          return SideTitleWidget(
                            space: 3,
                            meta: meta,
                            child: Text(
                              label,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    drawVerticalLine: true,
                    horizontalInterval: 20,
                    getDrawingHorizontalLine: (value) {
                      return const FlLine(
                        color: Color.fromARGB(192, 0, 0, 0),
                        strokeWidth: 1.5,
                        dashArray: [5, 5],
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return const FlLine(
                        color: Color.fromARGB(177, 0, 0, 0),
                        strokeWidth: 1.5,
                        dashArray: [5, 5],
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget makeTransactionsIcon() {
    const width = 4.5;
    const space = 3.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: width,
          height: 10,
          color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.4),
        ),
        const SizedBox(width: space),
        Container(
          width: width,
          height: 28,
          color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.8),
        ),
        const SizedBox(width: space),
        Container(
          width: width,
          height: 42,
          color: const Color.fromARGB(255, 0, 0, 0).withOpacity(1),
        ),
        const SizedBox(width: space),
        Container(
          width: width,
          height: 28,
          color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.8),
        ),
        const SizedBox(width: space),
        Container(
          width: width,
          height: 10,
          color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.4),
        ),
      ],
    );
  }

  BarChartGroupData makeGroupData(int x, double y1, double y2, double y3) {
    double cap(double value) => (value * 100).clamp(0, 100);
    return BarChartGroupData(
      x: x,
      barsSpace: 4,
      barRods: [
        BarChartRodData(toY: cap(y1), color: widget.fcColor, width: width),
        BarChartRodData(toY: cap(y2), color: widget.gbColor, width: width),
        BarChartRodData(toY: cap(y3), color: widget.abColor, width: width),
      ],
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      decoration: BoxDecoration(
        color: const Color.fromARGB(0, 29, 29, 44),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _legendItem(widget.fcColor, "Forward Chaining"),
          const SizedBox(width: 12),
          _legendItem(widget.gbColor, "Gradient Boosting"),
          const SizedBox(width: 12),
          _legendItem(widget.abColor, "Ada Boost"),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
      ],
    );
  }
}
