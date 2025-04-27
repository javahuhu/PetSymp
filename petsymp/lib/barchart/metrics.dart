import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:petsymp/Connection/dynamicconnections.dart';

class MetricsScreen extends StatefulWidget {
  final String petType;
  final String illnessName;
  const MetricsScreen({
    super.key,
    required this.petType,
    required this.illnessName,
  });

  @override
  MetricsScreenState createState() => MetricsScreenState();
}

class MetricsScreenState extends State<MetricsScreen> {
  // confusion matrix counts
  int _tp = 0, _fp = 0, _fn = 0, _tn = 0;

  // metric values (0.0–1.0)
  double _precision = 0.0;
  double _recall = 0.0;
  double _specificity = 0.0;
  double _f1Score = 0.0;
  double _accuracy = 0.0;

  // formatted formulas
  String _accuracyFormula = '';
  String _precFormula = '';
  String _recFormula = '';
  String _specFormula = '';
  String _f1Formula = '';

  bool _loading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchMetricsWithCM();
  }

  Future<void> _fetchMetricsWithCM() async {
    try {
      final url = Uri.parse(
        AppConfig.getMetricsWithCmURL(
        widget.petType,
        widget.illnessName,
      ),
      );
      final resp = await http.get(url);
      
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final cm = data['confusion_matrix'] as Map<String, dynamic>;
        final m = data['metrics'] as Map<String, dynamic>;

        _tp = cm['TP'] as int;
        _fp = cm['FP'] as int;
        _fn = cm['FN'] as int;
        _tn = cm['TN'] as int;

        _precision = (m['Precision'] as num).toDouble();
        _recall = (m['Recall'] as num).toDouble();
        _specificity = (m['Specificity'] as num).toDouble();
        _f1Score = (m['F1 Score'] as num).toDouble();
        
        // Calculate accuracy
        _accuracy = (_tp + _tn) / (_tp + _tn + _fp + _fn);

        // Format formulas with proper spacing
        _accuracyFormula = '(${_tp + _tn}) / (${_tp + _tn + _fp + _fn}) = '
            '${(_accuracy * 100).toStringAsFixed(1)}%';
        _precFormula = '$_tp / (${_tp + _fp}) = '
            '${(_precision * 100).toStringAsFixed(1)}%';
        _recFormula = '$_tp / (${_tp + _fn}) = '
            '${(_recall * 100).toStringAsFixed(1)}%';
        _specFormula = '$_tn / (${_tn + _fp}) = '
            '${(_specificity * 100).toStringAsFixed(1)}%';
        
        final p = _precision, r = _recall;
        _f1Formula = '2 × ${p.toStringAsFixed(2)} × ${r.toStringAsFixed(2)} '
            '/ (${p.toStringAsFixed(2)} + ${r.toStringAsFixed(2)}) = '
            '${(_f1Score * 100).toStringAsFixed(1)}%';

        setState(() => _loading = false);
      } else {
        setState(() {
          _loading = false;
          _errorMessage = 'Failed to load metrics: Server error ${resp.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = 'Failed to load metrics: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use ScreenUtil to ensure responsiveness
    ScreenUtil.init(context, designSize: const Size(390, 844));

    return Scaffold(
      backgroundColor: const Color(0xFFE8F2F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: const Color(0xFF1D1D2C),
            size: 24.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.illnessName,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1D1D2C),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Bubble background
            Positioned.fill(child: CustomPaint(painter: BubbleBackground())),
            
            if (_loading)
              const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF52AAA4),
                ),
              )
            else if (_errorMessage.isNotEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 48.sp),
                      SizedBox(height: 16.h),
                      Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16.sp),
                      ),
                      SizedBox(height: 24.h),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _loading = true;
                            _errorMessage = '';
                          });
                          _fetchMetricsWithCM();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF52AAA4),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 12.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Retry',
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Title Section
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
          child: Text(
            "Classification Metrics",
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF3666BF),
            ),
          ),
        ),
        
        // Metrics Card
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Confusion Matrix Visualization
                  _buildConfusionMatrix(),
                  
                  SizedBox(height: 16.h),
                  
                  // Metrics Table
                  _buildMetricsCard(),
                  
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfusionMatrix() {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: const BoxDecoration(
              color: Color(0xFF52AAA4),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            width: double.infinity,
            child: Text(
              'Confusion Matrix',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Actual vs Predicted Values',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1D1D2C),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cellSize = constraints.maxWidth / 3;
                    
                    return Table(
                      border: TableBorder.all(
                        color: const Color(0xFFE0E0E0),
                        width: 1,
                      ),
                      columnWidths: {
                        0: FixedColumnWidth(cellSize * 0.8),
                        1: FixedColumnWidth(cellSize * 1.1),
                        2: FixedColumnWidth(cellSize * 1.1),
                      },
                      children: [
                        // Header row
                        TableRow(
                          decoration: const BoxDecoration(
                            color: Color(0xFFF5F5F5),
                          ),
                          children: [
                            _buildMatrixCell('', cellSize, isHeader: true),
                            _buildMatrixCell('Predicted\nPositive', cellSize, isHeader: true),
                            _buildMatrixCell('Predicted\nNegative', cellSize, isHeader: true),
                          ],
                        ),
                        // Data rows
                        TableRow(
                          children: [
                            _buildMatrixCell('Actual\nPositive', cellSize, isHeader: true),
                            _buildMatrixCell('TP: $_tp', cellSize, highlight: true),
                            _buildMatrixCell('FN: $_fn', cellSize),
                          ],
                        ),
                        TableRow(
                          children: [
                            _buildMatrixCell('Actual\nNegative', cellSize, isHeader: true),
                            _buildMatrixCell('FP: $_fp', cellSize),
                            _buildMatrixCell('TN: $_tn', cellSize, highlight: true),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatrixCell(String text, double cellSize, {bool isHeader = false, bool highlight = false}) {
    return Container(
      padding: EdgeInsets.all(8.w),
      height: cellSize * 0.6,
      alignment: Alignment.center,
      color: highlight 
          ? const Color(0xFFE3F2FD) 
          : isHeader 
              ? const Color(0xFFF5F5F5) 
              : Colors.white,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: const Color(0xFF1D1D2C),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMetricsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: const BoxDecoration(
              color: Color(0xFF52AAA4),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            width: double.infinity,
            child: Text(
              'Model Performance',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Metrics Table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Table Header
                    Row(
                      children: [
                        _buildTableHeader('Metric', 1),
                        _buildTableHeader('Value', 1),
                        _buildTableHeader('Calculation', 2),
                      ],
                    ),
                    
                    // Accuracy Row
                    _buildMetricRow(
                      'Accuracy',
                      (_accuracy * 100).toStringAsFixed(1) + '%',
                      _accuracyFormula,
                      const Color(0xFFE3F2FD),
                    ),
                    
                    // Precision Row
                    _buildMetricRow(
                      'Precision',
                      (_precision * 100).toStringAsFixed(1) + '%',
                      _precFormula,
                    ),
                    
                    // Recall Row
                    _buildMetricRow(
                      'Recall',
                      (_recall * 100).toStringAsFixed(1) + '%',
                      _recFormula,
                    ),
                    
                    // Specificity Row
                    _buildMetricRow(
                      'Specificity',
                      (_specificity * 100).toStringAsFixed(1) + '%',
                      _specFormula,
                    ),
                    
                    // F1 Score Row
                    _buildMetricRow(
                      'F1 Score',
                      (_f1Score * 100).toStringAsFixed(1) + '%',
                      _f1Formula,
                      const Color(0xFFE3F2FD),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Metrics Explanation
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Metrics Explanation:',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1D1D2C),
                  ),
                ),
                SizedBox(height: 8.h),
                _buildExplanationItem('Accuracy', 'Overall correctness of predictions'),
                _buildExplanationItem('Precision', 'How many selected items are relevant'),
                _buildExplanationItem('Recall', 'How many relevant items are selected'),
                _buildExplanationItem('Specificity', 'True negative rate'),
                _buildExplanationItem('F1 Score', 'Harmonic mean of precision and recall'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String title, int flex) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        decoration: const BoxDecoration(
          color: Color(0xFFF5F5F5),
          border: Border(
            bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1D1D2C),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildMetricRow(String metric, String value, String formula, [Color? bgColor]) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
              child: Text(
                metric,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1D1D2C),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: _getValueColor(double.parse(value.replaceAll('%', ''))),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
              child: Text(
                formula,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: 'Monospace',
                  color: const Color(0xFF1D1D2C),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplanationItem(String term, String definition) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF52AAA4),
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$term: ',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1D1D2C),
                    ),
                  ),
                  TextSpan(
                    text: definition,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF1D1D2C),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getValueColor(double value) {
    if (value >= 90) {
      return const Color(0xFF4CAF50); // Excellent - Green
    } else if (value >= 80) {
      return const Color(0xFF8BC34A); // Good - Light Green
    } else if (value >= 70) {
      return const Color(0xFFFFC107); // Moderate - Amber
    } else if (value >= 60) {
      return const Color(0xFFFF9800); // Fair - Orange
    } else {
      return const Color(0xFFF44336); // Poor - Red
    }
  }
}

// Enhanced Bubble Background Painter
class BubbleBackground extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromRGBO(82, 170, 164, 0.12)
      ..style = PaintingStyle.fill;

    void drawBubble(Offset center, double radius) {
      canvas.drawCircle(center, radius, paint);
    }

    // Draw bubbles with relative positioning for any screen size
    drawBubble(Offset(size.width * 0.2, size.height * 0.2), size.width * 0.12);
    drawBubble(Offset(size.width * 0.8, size.height * 0.3), size.width * 0.09);
    drawBubble(Offset(size.width * 0.15, size.height * 0.7), size.width * 0.15);
    drawBubble(Offset(size.width * 0.75, size.height * 0.8), size.width * 0.18);
    drawBubble(Offset(size.width * 0.4, size.height * 0.5), size.width * 0.07);
    drawBubble(Offset(size.width * 0.9, size.height * 0.6), size.width * 0.05);
    drawBubble(Offset(size.width * 0.1, size.height * 0.4), size.width * 0.04);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}