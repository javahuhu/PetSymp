import 'package:fl_chart/fl_chart.dart';
import 'barresources.dart';
import 'barcolorextension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
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
  late List<_ChartData> data;


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

     data = [
      _ChartData('David', 25),
      _ChartData('Steve', 38),
      _ChartData('Jack', 34),
      _ChartData('Others', 52)
    ];
    

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
            const TextStyle(
              color: Color.fromARGB(255, 0, 0, 0),
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
        // Show a pop-up dialog when the user lifts the tap
        if (event is FlTapUpEvent) {
         showDialog(
  context: context,
  builder: (BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      title: Text("Why ${widget.illnessLabels[index]} ?"),
      content: SizedBox(
        width: 500.w,
        height: 600.h,
        child: 
        SingleChildScrollView( child:
        Column(
          children: [
            // Container for the chart with fixed size
            SizedBox(
              height: 250.w,
              width: 250.w,
              child: SfCircularChart(
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CircularSeries<_ChartData, String>>[
                  DoughnutSeries<_ChartData, String>(
                    dataSource: data,
                    xValueMapper: (_ChartData data, _) => data.x,
                    yValueMapper: (_ChartData data, _) => data.y,
                  )
                ],
              ),
            ),
            
            Center(
              child: Text(
                "Symptoms Doughnut Graph",
                style: TextStyle(fontSize: 22.sp, fontFamily: 'Oswald'),
              ),
            ),
            SizedBox(height: 20.h),
            // Wrap the table in a horizontally scrolling view
             SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Table(
                  // Force each column to have a fixed width so the table is wider than the available space
                  defaultColumnWidth: const FixedColumnWidth(200),
                  textDirection: TextDirection.ltr,
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  border: TableBorder.all(width: 2, color: const Color.fromARGB(255, 0, 0, 0)),
                  children:  [
                   const TableRow(
                      children: [
                        Center(child: Text("Symptom", textScaleFactor: 1.8, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter'))),
                        Center(child: Text("Base Weight", textScaleFactor: 1.8, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter'))),
                        Center(child: Text("Severity", textScaleFactor: 1.8, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter'))),
                        Center(child: Text("Priority", textScaleFactor: 1.8, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter'))),
                      ],
                    ),
                    TableRow(
                      children: [
                        Center(child: Text("Education", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 15.sp))),
                        Center(child: Text("Institution name", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter' ,fontSize: 15.sp))),
                        Center(child: Text("University", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 15.sp))),
                        Center(child: Text("University", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 15.sp))),
                      ],
                    ),
                    TableRow(
                      children: [
                        Center(child: Text("Education", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 15.sp))),
                        Center(child: Text("Institution name", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 15.sp))),
                        Center(child: Text("University", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 15.sp))),
                        Center(child: Text("University", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 15.sp))),
                      ],
                    ),
                    TableRow(
                      children: [
                        Center(child: Text("Education", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 15.sp))),
                        Center(child: Text("Institution name", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 15.sp))),
                        Center(child: Text("University", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 15.sp))),
                        Center(child: Text("University", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter',fontSize: 15.sp))),
                      ],
                    ),
                  ],
                ),
              ),
            

                        Padding(
              padding: EdgeInsets.only(top: 25.h, left: 20.w, right: 5.w),
              child: Text.rich(
                TextSpan(
                  style: TextStyle(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    fontSize: 15.sp,
                  ),
                  children: const [
                    TextSpan(text: "Note: The graph above illustrates the Smptoms input with their Base Weight. "),
                    TextSpan(text: "Symptoms", style:  TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: " that been provided by the user. "),
                    TextSpan(text: "Base Weight", style:  TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: " The weight of the symptoms in the Knowledge Base. "),
                    TextSpan(text: "Severity", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: " How severe is the provided symptoms (e.g Vomiting: High)"),
                  ],
                ),
              ),
            ),

              SizedBox(height: 15.h,),
              Center(
                  child: Text(
                        "Forward Chaining",
                        style: TextStyle(fontSize: 22.sp, fontFamily: 'Oswald'),
                      ),
                    ),




                SizedBox(height: 10.h,),
                 Table(
                  // Force each column to have a fixed width so the table is wider than the available space
                  defaultColumnWidth: const FixedColumnWidth(150),
                  textDirection: TextDirection.ltr,
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  border: TableBorder.all(width: 2, color: const Color.fromARGB(255, 0, 0, 0)),
                  children:  [
                   const TableRow(
                      children: [
                        Center(child: Text("Base Weight", textScaleFactor: 1.4, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter'))),
                        Center(child: Text("FC Weight", textScaleFactor: 1.4, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter'))),
                        
                      ],
                    ),
                    TableRow(
                      children: [
                        Center(child: Text("1.0", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 15.sp))),
                        Center(child: Text("0.8", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter' ,fontSize: 15.sp))),
                        
                      ],
                    ),
                    TableRow(
                      children: [
                        Center(child: Text("1.0", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 15.sp))),
                        Center(child: Text("0.8", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter' ,fontSize: 15.sp))),
                        
                      ],
                    ),
                    TableRow(
                      children: [
                        Center(child: Text("1.0", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 15.sp))),
                        Center(child: Text("0.8", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter' ,fontSize: 15.sp))),
                        
                      ],
                    ),
                    TableRow(
                      children: [
                        Center(child: Text("1.0", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 15.sp))),
                        Center(child: Text("0.8", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter' ,fontSize: 15.sp))),
                        
                      ],
                    ),
                    TableRow(
                      children: [
                        Center(child: Text("1.0", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 15.sp))),
                        Center(child: Text("0.8", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter' ,fontSize: 15.sp))),
                        
                      ],
                    ),
                    
                  ],
                ),


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
                        "Base × Severity × Priority",
                        style: TextStyle(fontSize: 18.sp, fontFamily: 'Oswald'),
                      ),
                    ),





                  SizedBox(height: 50.h,),
                  Center(
                      child: Text(
                            "Gradient Boosting",
                            style: TextStyle(fontSize: 18.sp, fontFamily: 'Oswald'),
                          ),
                        ),


                    SizedBox(height: 10.h,),
                 Table(
                  // Force each column to have a fixed width so the table is wider than the available space
                  defaultColumnWidth: const FixedColumnWidth(150),
                  textDirection: TextDirection.ltr,
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  border: TableBorder.all(width: 2, color: const Color.fromARGB(255, 0, 0, 0)),
                  children:  [
                   const TableRow(
                      children: [
                        Center(child: Text("GB Adjustment", textScaleFactor: 1.4, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter'))),
                        Center(child: Text("GB Weight", textScaleFactor: 1.4, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter'))),
                        
                      ],
                    ),
                    TableRow(
                      children: [
                        Center(child: Text("1.0", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 15.sp))),
                        Center(child: Text("0.8", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter' ,fontSize: 15.sp))),
                        
                      ],
                    ),

                    TableRow(
                      children: [
                        Center(child: Text("1.0", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 15.sp))),
                        Center(child: Text("0.8", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter' ,fontSize: 15.sp))),
                        
                      ],
                    ),
                    TableRow(
                      children: [
                        Center(child: Text("1.0", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 15.sp))),
                        Center(child: Text("0.8", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter' ,fontSize: 15.sp))),
                        
                      ],
                    ),
                    TableRow(
                      children: [
                        Center(child: Text("1.0", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 15.sp))),
                        Center(child: Text("0.8", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter' ,fontSize: 15.sp))),
                        
                      ],
                    ),
                    TableRow(
                      children: [
                        Center(child: Text("1.0", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 15.sp))),
                        Center(child: Text("0.8", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter' ,fontSize: 15.sp))),
                        
                      ],
                    ),
                    
                  ],
                ),


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
















                     SizedBox(height: 50.h,),
                  Center(
                      child: Text(
                            "Ada Boost",
                            style: TextStyle(fontSize: 22.sp, fontFamily: 'Oswald'),
                          ),
                        ),


                    SizedBox(height: 10.h,),
                 Table(
                  // Force each column to have a fixed width so the table is wider than the available space
                  defaultColumnWidth: const FixedColumnWidth(150),
                  textDirection: TextDirection.ltr,
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  border: TableBorder.all(width: 2, color: const Color.fromARGB(255, 0, 0, 0)),
                  children:  [
                   const TableRow(
                      children: [
                        Center(child: Text("AB Factor", textScaleFactor: 1.4, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter'))),
                        Center(child: Text("AB Weight", textScaleFactor: 1.4, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter'))),
                        
                      ],
                    ),
                    TableRow(
                      children: [
                        Center(child: Text("1.0", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 15.sp))),
                        Center(child: Text("0.8", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter' ,fontSize: 15.sp))),
                        
                      ],
                    ),
                    TableRow(
                      children: [
                        Center(child: Text("1.0", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 15.sp))),
                        Center(child: Text("0.8", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter' ,fontSize: 15.sp))),
                        
                      ],
                    ),
                    TableRow(
                      children: [
                        Center(child: Text("1.0", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 15.sp))),
                        Center(child: Text("0.8", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter' ,fontSize: 15.sp))),
                        
                      ],
                    ),
                    TableRow(
                      children: [
                        Center(child: Text("1.0", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 15.sp))),
                        Center(child: Text("0.8", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter' ,fontSize: 15.sp))),
                        
                      ],
                    ),
                    TableRow(
                      children: [
                        Center(child: Text("1.0", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 15.sp))),
                        Center(child: Text("0.8", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter' ,fontSize: 15.sp))),
                        
                      ],
                    ),
                    
                  ],
                ),


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
              
              

          ],
        ),
      ),
    ));
  },
);




        }
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
)

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

class _ChartData {
  _ChartData(this.x, this.y);
  final String x;
  final double y;
}