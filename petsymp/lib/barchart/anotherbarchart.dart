import 'package:fl_chart/fl_chart.dart';
import 'barresources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:petsymp/userdata.dart' as userdata;

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => userdata.UserData(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, child) => MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text("Bar Chart Sample")),
          body: Padding(
            padding: EdgeInsets.only(top: 25.h),
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(0, 19, 19, 44),
                borderRadius: BorderRadius.circular(0),
              ),
              height: 300.h,
              child: Consumer<userdata.UserData>(
                builder: (_, userData, __) {
                  // Use a null check on diagnosisResults to avoid accessing null.
                  final diagnoses = List<Map<String, dynamic>>.from(userData?.diagnosisResults ?? [])
                    ..sort((a, b) => (b['confidence_ab'] as num).compareTo(a['confidence_ab'] as num));

                  // Choose the top diagnosis: if one has confidence_ab exactly 1.0, take that; otherwise, take the first.
                  Map<String, dynamic> topDiagnosis = diagnoses.isNotEmpty
                      ? diagnoses.firstWhere(
                          (d) => (d['confidence_ab'] as num).toDouble() == 1.0,
                          orElse: () => diagnoses.first,
                        )
                      : {
                          'illness': '',
                          'confidence_fc': 0.0,
                          'confidence_gb': 0.0,
                          'confidence_ab': 0.0,
                          'subtype_coverage': 0.0,
                        };

                  // Prepare chart data for a single group.
                  final labels = [topDiagnosis['illness'] as String];
                  final fc = [(topDiagnosis['confidence_fc'] as num).toDouble()];
                  final gb = [(topDiagnosis['confidence_gb'] as num).toDouble()];
                  final ab = [(topDiagnosis['confidence_ab'] as num).toDouble()];

                  // Use screen width for the chart so the single bar can be centered.
                  final double chartWidth = MediaQuery.of(context).size.width;

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
      ),
    );
  }
}

class BarChartSample3 extends StatefulWidget {
  final List<String> illnessLabels;
  final List<double> fcScores;
  final List<double> gbScores;
  final List<double> abScores;

  const BarChartSample3({
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
  State<BarChartSample3> createState() => _BarChartSample3State();
}

class _BarChartSample3State extends State<BarChartSample3> {
  final double width = 7;
  late List<BarChartGroupData> rawBarGroups;
  late List<BarChartGroupData> showingBarGroups;
  int touchedGroupIndex = -1;

  @override
  void initState() {
    super.initState();
    rawBarGroups = List.generate(widget.illnessLabels.length, (index) {
      return makeGroupData(
        index,
        widget.fcScores[index],
        widget.gbScores[index],
        widget.abScores[index],
      );
    });
    showingBarGroups = List.of(rawBarGroups);
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
            SizedBox(height: 20.h,),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.center,  // Centers the bar group.
                  maxY: 100,
                  groupsSpace: 20,
                  barGroups: showingBarGroups,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final algorithm = ['FC', 'GB', 'AB'][rodIndex];
                        return BarTooltipItem(
                          '$algorithm: ${rod.toY.toStringAsFixed(1)}',
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
                      setState(() {
                        if (!event.isInterestedForInteractions) {
                          touchedGroupIndex = -1;
                          showingBarGroups = List.of(rawBarGroups);
                        } else {
                          touchedGroupIndex = index;
                          // No averaging — just highlight by copying original group.
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
                        reservedSize: 30, 
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}',
                          style: TextStyle(color: const Color.fromARGB(221, 160, 222, 241)),
                        ),
                      ),
                    ),

                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                         reservedSize: 30.h,
                        getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= widget.illnessLabels.length) return const SizedBox.shrink();

                        // Use the complete illness name without truncating it.
                        String label = widget.illnessLabels[i];

                        return SideTitleWidget(
                          space: 3.h,
                          meta: meta,
                          child: Text(
                            label,
                            style: TextStyle(fontSize: 18.sp, color:const Color.fromARGB(255, 214, 59, 59), fontFamily: 'Inter',),
                            // Option 1: Allow wrapping if you want to see the full text on multiple lines.
                            softWrap: true,
                            textAlign: TextAlign.center,
                            
                            // Option 2: If you prefer a single line, you could set maxLines to 1 
                            // and let the text scale down or overflow (choose one):
                            // maxLines: 1,
                            // overflow: TextOverflow.visible,
                          ),
                        );
                      },

                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                   gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: true,
                    horizontalInterval: 20, 
                  getDrawingHorizontalLine: (value) {
                    return const FlLine(
                      color:  Color.fromARGB(192, 160, 222, 241),
                      strokeWidth: 1.2,
                      dashArray: [5, 5], // 5 pixels on, 5 pixels off
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return const FlLine(
                      color:  Color.fromARGB(178, 160, 222, 241),
                      strokeWidth: 1.2,
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
    return Padding(
      padding: EdgeInsets.only(left: 102.w),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: const Color.fromARGB(0, 29, 29, 44),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _legendItem(widget.fcColor, "FC"),
            const SizedBox(width: 12),
            _legendItem(widget.gbColor, "GB"),
            const SizedBox(width: 12),
            _legendItem(widget.abColor, "AB"),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 14.w,
          height: 14.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: Colors.grey.shade700)),
      ],
    );
  }
}
