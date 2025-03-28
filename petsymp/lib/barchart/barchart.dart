import 'package:fl_chart/fl_chart.dart';
import 'barresources.dart';
import 'barcolorextension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

class _BarChartSample2State extends State<BarChartSample2> {
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                makeTransactionsIcon(),
                const SizedBox(
                  width: 38,
                ),
                Text(
                  'Confidence Comparison',
                  style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0), fontSize: 22.sp,  fontFamily: 'Oswald',),
                ),
                const SizedBox(
                  width: 4,
                ),
                
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
                           const TextStyle(color: Color.fromARGB(255, 0, 0, 0),)
                           ,
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
                          // No averaging — just highlight by copying original group
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
                          style: const TextStyle(color:  Color.fromARGB(255, 0, 0, 0)),
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
                              style:  const TextStyle(fontSize: 15, color:  Color.fromARGB(255, 0, 0, 0)),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                              textAlign: TextAlign.center,
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
                      color:  Color.fromARGB(192, 0, 0, 0),
                      strokeWidth: 1.5,
                      dashArray: [5, 5], // Explicitly defined dash array
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return const FlLine(
                      color:  Color.fromARGB(177, 0, 0, 0),
                      strokeWidth: 1.5,
                      dashArray: [5, 5], // Explicitly defined dash array
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
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 28,
          color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.8),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 42,
          color: const Color.fromARGB(255, 0, 0, 0).withOpacity(1),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 28,
          color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.8),
        ),
        const SizedBox(
          width: space,
        ),
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
          borderRadius: BorderRadius.circular(20), // adjust radius as desired
        ),
      ),
      const SizedBox(width: 4),
      Text(label, style:  TextStyle(color: const Color.fromARGB(255, 0, 0, 0))),
    ],
  );
}

}