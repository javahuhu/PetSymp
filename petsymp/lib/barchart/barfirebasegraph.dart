import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_charts/charts.dart';


class BarChartRetrieve extends StatefulWidget {
  
  final List<String> illnessLabels;
  final List<double> fcScores;
  final List<double> gbScores;
  final List<double> abScores;
  final Map<String, List<Map<String, dynamic>>> symptomDetails; // Stored symptom details

  const BarChartRetrieve({
    Key? key,
    required this.illnessLabels,
    required this.fcScores,
    required this.gbScores,
    required this.abScores,
    required this.symptomDetails,
  }) : super(key: key);

  // Enhanced colors with better contrast
  final Color fcColor = const Color(0xFF4285F4); // Google Blue
  final Color gbColor = const Color(0xFFEA4335); // Google Red
  final Color abColor = const Color(0xFFFBBC05); // Google Yellow

  @override
  State<BarChartRetrieve> createState() => _BarChartRetrieveState();
}

// Internal chart data model
class _ChartData {
  _ChartData(this.x, this.y);
  final String x;
  final double y;
}

class _BarChartRetrieveState extends State<BarChartRetrieve> {
  final double width = 7;
  late List<BarChartGroupData> rawBarGroups;
  late List<BarChartGroupData> showingBarGroups;
  int touchedGroupIndex = -1;

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

  Map<String, double> getFinalScoresFromDiagnosisResults(
    List<Map<String, dynamic>> diagnosisResults) {
    double finalFC = 0.0, finalGB = 0.0, finalAB = 0.0;
    for (var d in diagnosisResults) {
      final fc = (d['confidence_fc'] as num).toDouble();
      final gb = (d['confidence_gb'] as num).toDouble();
      final ab = (d['confidence_ab'] as num).toDouble();
      if (fc > finalFC) finalFC = fc;
      if (gb > finalGB) finalGB = gb;
      if (ab > finalAB) finalAB = ab;
    }
    return {
      "confidence_fc": finalFC,
      "confidence_gb": finalGB,
      "confidence_ab": finalAB,
    };
  }


  @override
  Widget build(BuildContext context) {
    Map<String, double> scores = {
      "confidence_fc": touchedGroupIndex >= 0 ? widget.fcScores[touchedGroupIndex] : 0.0,
      "confidence_gb": touchedGroupIndex >= 0 ? widget.gbScores[touchedGroupIndex] : 0.0,
      "confidence_ab": touchedGroupIndex >= 0 ? widget.abScores[touchedGroupIndex] : 0.0,
    };

    return AspectRatio(
      aspectRatio: 1.3,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced title section with gradient background
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue[50]!,
                      Colors.blue[100]!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _buildEnhancedIcon(),
                    const SizedBox(width: 16),
                    Text(
                      'Confidence Comparison',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 22.sp,
                        fontFamily: 'Oswald',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              
              // Enhanced chart area
              Expanded(
                child: BarChart(
                  BarChartData(
                    maxY: 100,
                    groupsSpace: 20,
                    barGroups: showingBarGroups,
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        tooltipRoundedRadius: 8,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final algorithm = ['FC', 'GB', 'AB'][rodIndex];
                          return BarTooltipItem(
                            '$algorithm: ${rod.toY.toStringAsFixed(0)}%',
                            const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
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
                          // Get the illness name
                          final illness = widget.illnessLabels[index].toLowerCase();
                          
                          // Look for the illness in the symptom details, trying both lowercase and original case
                          final details = widget.symptomDetails[illness] ?? 
                                         widget.symptomDetails[widget.illnessLabels[index]];
                                         
                          if (details == null || details.isEmpty) {
                            showDialog(
                              context: context,
                              builder: (context) => _buildSimpleDialog(
                                title: "No Matching Symptoms",
                                content: "The selected illness does not have saved symptom details.",
                                context: context,
                              ),
                            );
                            return;
                          }
                          
                          // Create chart data for doughnut chart
                          final List<_ChartData> chartData = details.map((d) {
                            double baseWeight = 0.0;
                            if (d['base_weight'] is num) {
                              baseWeight = (d['base_weight'] as num).toDouble();
                            }
                            return _ChartData(d['name'] as String, baseWeight);
                          }).toList();

                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return _buildDetailDialog(
                                title: "Why ${widget.illnessLabels[index]} ?",
                                details: details,
                                chartData: chartData,
                                scores: scores,
                                context: context,
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
                          getTitlesWidget: (value, meta) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              '${value.toInt()}',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 12,
                              ),
                            ),
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
                              space: 4,
                              meta: meta,
                              child: Text(
                                label,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
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
                      drawVerticalLine: false,
                      horizontalInterval: 20,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey[300]!,
                          strokeWidth: 1,
                          dashArray: [5, 5],
                        );
                      },
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                        left: BorderSide(color: Colors.grey[300]!, width: 1),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildEnhancedLegend(),
            ],
          ),
        ),
      ),
    );
  }

  // Enhanced icon with shadow effect
  Widget _buildEnhancedIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(width: 4, height: 12, color: widget.fcColor.withOpacity(0.6)),
          const SizedBox(width: 3),
          Container(width: 4, height: 20, color: widget.gbColor.withOpacity(0.8)),
          const SizedBox(width: 3),
          Container(width: 4, height: 28, color: widget.abColor),
        ],
      ),
    );
  }

  // Enhanced legend with gradient background
  Widget _buildEnhancedLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[50]!,
            Colors.grey[100]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildEnhancedLegendItem(widget.fcColor, "Forward Chaining"),
          const SizedBox(width: 16),
          _buildEnhancedLegendItem(widget.gbColor, "Gradient Boosting"),
          const SizedBox(width: 16),
          _buildEnhancedLegendItem(widget.abColor, "Ada Boost"),
        ],
      ),
    );
  }

  // Enhanced legend item with shadow effect
  Widget _buildEnhancedLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label, 
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Simple dialog for showing error messages
  Widget _buildSimpleDialog({
    required String title,
    required String content,
    required BuildContext context,
  }) {
    return AlertDialog(
      title: Text(
        title, 
        style: const TextStyle(
          fontFamily: 'Oswald',
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(content),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue[700],
          ),
          child: const Text("OK"),
        ),
      ],
    );
  }

  // Enhanced detail dialog with improved styling
  Widget _buildDetailDialog({
    required String title,
    required List<Map<String, dynamic>> details,
    required List<_ChartData> chartData,
    required Map<String, double> scores,
    required BuildContext context,
  }) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue[50]!,
              Colors.blue[100]!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20.sp,
            fontFamily: 'Oswald',
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      content: SizedBox(
        width: 500.w,
        height: 600.h,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced doughnut chart
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Center(
                        child: SizedBox(
                          height: 250.w,
                          width: 250.w,
                          child: SfCircularChart(
                            palette: const [
                              Color(0xFF4285F4), // Blue
                              Color(0xFFEA4335), // Red
                              Color(0xFFFBBC05), // Yellow
                              Color(0xFF34A853), // Green
                              Color(0xFF7986CB), // Indigo
                              Color(0xFFFFB74D), // Orange
                              Color(0xFF4DB6AC), // Teal
                            ],
                            margin: EdgeInsets.zero,
                            tooltipBehavior: TooltipBehavior(enable: true),
                            series: <CircularSeries<_ChartData, String>>[
                              DoughnutSeries<_ChartData, String>(
                                dataSource: chartData,
                                xValueMapper: (_ChartData data, _) => data.x,
                                yValueMapper: (_ChartData data, _) => data.y,
                                explode: true,
                                explodeIndex: 0,
                                dataLabelSettings: const DataLabelSettings(
                                  isVisible: true,
                                  labelPosition: ChartDataLabelPosition.outside,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Symptoms Doughnut Graph",
                        style: TextStyle(
                          fontSize: 20.sp, 
                          fontFamily: 'Oswald',
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Symptom details section
              _buildDetailSection(
                title: "Symptom Details",
                child: _buildScrollableTable(
                  columns: const ["Symptom", "Base Weight", "Severity", "Priority"],
                  rows: details.map((d) {
                    return [
                      d['name'] ?? '',
                      d['base_weight']?.toString() ?? '',
                      d['severity'] ?? '',
                      d['priority']?.toString() ?? '',
                    ];
                  }).toList(),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Forward Chaining section
              _buildDetailSection(
                title: "Forward Chaining",
                child: Column(
                  children: [
                    _buildScrollableTable(
                      columns: const ["Symptom", "FC Weight"],
                      rows: details.map((d) {
                        return [
                          d['name'] ?? '',
                          d['fc_weight']?.toString() ?? '',
                        ];
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    _buildFormulaDisplay("Base × Severity × Priority"),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Gradient Boosting section
              _buildDetailSection(
                title: "Gradient Boosting",
                child: Column(
                  children: [
                    _buildScrollableTable(
                      columns: const ["GB Adjustment", "GB Weight"],
                      rows: details.map((d) {
                        return [
                          d['gb_adjustment'] is num 
                              ? (d['gb_adjustment'] as num).toStringAsFixed(2) 
                              : d['gb_adjustment']?.toString() ?? '',
                          d['gb_weight'] is num 
                              ? (d['gb_weight'] as num).toStringAsFixed(2) 
                              : d['gb_weight']?.toString() ?? '',
                        ];
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    _buildFormulaDisplay("FC Weight + GB Adjustment"),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Ada Boost section
              _buildDetailSection(
                title: "Ada Boost",
                child: Column(
                  children: [
                    _buildScrollableTable(
                      columns: const ["AB Factor", "AB Weight"],
                      rows: details.map((d) {
                        return [
                          d['ab_factor'] is num 
                              ? (d['ab_factor'] as num).toStringAsFixed(2) 
                              : d['ab_factor']?.toString() ?? '',
                          d['ab_weight'] is num 
                              ? (d['ab_weight'] as num).toStringAsFixed(2) 
                              : d['ab_weight']?.toString() ?? '',
                        ];
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    _buildFormulaDisplay("GB Weight × AB Factor"),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Final Results section
              _buildDetailSection(
                title: "Total Result for each Algorithm",
                child: Column(
                  children: [
                    Table(
                      border: TableBorder.all(
                        width: 1, 
                        color: Colors.grey.shade300,
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                      ),
                      children: [
                        TableRow(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                          ),
                          children: const [
                            Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Center(
                                child: Text(
                                  "Algorithm",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Center(
                                child: Text(
                                  "Final Score",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                        _buildResultRow("Forward Chaining", scores["confidence_fc"]!, false),
                        _buildResultRow("Gradient Boosting", scores["confidence_gb"]!, false),
                        _buildResultRow("AdaBoost", scores["confidence_ab"]!, true),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Final score highlight
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12, 
                          horizontal: 24,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green[50]!,
                              Colors.green[100]!,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Text(
                          "Final Score: ${scores["confidence_ab"]!.toStringAsFixed(2)}%",
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Info box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Note: The tables above illustrate the results of different algorithms used in illness analysis. Forward Chaining (FC) provides the initial diagnosis, Gradient Boosting (GB) refines the ranking, and AdaBoost (AB) delivers the final result.",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 12.sp,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue[700],
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: const Text(
            "Close",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  // Enhanced detail section with card styling
  Widget _buildDetailSection({
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp, 
                  fontFamily: 'Oswald',
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  // Enhanced scrollable table
   Widget _buildScrollableTable({
    required List<String> columns,
    required List<List<dynamic>> rows,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
            dataRowColor: MaterialStateProperty.all(Colors.white),
            columnSpacing: 20,
            horizontalMargin: 12,
            headingTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            dataTextStyle: const TextStyle(
              color: Colors.black87,
            ),
            columns: columns.map((column) => 
              DataColumn(
                label: Text(column),
              )
            ).toList(),
            rows: rows.map((row) => 
              DataRow(
                cells: row.map((cell) => 
                  DataCell(Text(cell.toString()))
                ).toList(),
              )
            ).toList(),
          ),
        ),
      ),
    );
  }

  // Enhanced formula display
  Widget _buildFormulaDisplay(String formula) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[50]!,
            Colors.grey[100]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Formula:",
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.blue[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                formula,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontFamily: 'Oswald',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced result table row
  TableRow _buildResultRow(String algorithm, double score, bool isHighlighted) {
    final Color bgColor = isHighlighted ? Colors.amber.shade50 : Colors.transparent;
    
    return TableRow(
      decoration: BoxDecoration(
        color: bgColor,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: Text(
              algorithm,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: Text(
              "${score.toStringAsFixed(2)}%",
              style: TextStyle(
                fontSize: 14,
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                color: score > 70 ? Colors.green[700] : Colors.black87,
              ),
            ),
          ),
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
        BarChartRodData(
          toY: cap(y1), 
          color: widget.fcColor,
          width: width,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 100,
            color: widget.fcColor.withOpacity(0.1),
          ),
        ),
        BarChartRodData(
          toY: cap(y2), 
          color: widget.gbColor,
          width: width,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 100,
            color: widget.gbColor.withOpacity(0.1),
          ),
        ),
        BarChartRodData(
          toY: cap(y3), 
          color: widget.abColor,
          width: width,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 100,
            color: widget.abColor.withOpacity(0.1),
          ),
        ),
      ],
    );
  }
}