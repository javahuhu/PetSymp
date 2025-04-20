import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class IllnessMetricsScreen extends StatefulWidget {
  final String illnessName;
  final String petName;
  final String petType;
  const IllnessMetricsScreen({
    Key? key,
    required this.illnessName,
    required this.petName,
    required this.petType,
  }) : super(key: key);

  @override
  _IllnessMetricsScreenState createState() => _IllnessMetricsScreenState();
}

class _IllnessMetricsScreenState extends State<IllnessMetricsScreen> with SingleTickerProviderStateMixin {
  Map<String, int>? _confMatrix;
  Map<String, double>? _metrics;
  bool _loading = true;
  String? _errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  // Step-by-step calculation formulas
  String _accuracyFormula = '';
  String _precFormula = '';
  String _recFormula = '';
  String _specFormula = '';
  String _f1Formula = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _fetchSavedMetricsWithCm();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchSavedMetricsWithCm() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final petName = widget.petName;
      final petType = widget.petType;

      // ✅ Step 1: Get the latest history document (sorted by date)
      final historySnap = await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .collection('History')
          .where('petName', isEqualTo: petName)
          .where('petType', isEqualTo: petType)
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      if (historySnap.docs.isEmpty) {
        setState(() {
          _loading = false;
          _errorMessage = 'No history found for ${widget.petName}';
        });
        return;
      }

      final data = historySnap.docs.first.data();
      final assessments = data['assessments'] as List<dynamic>?;

      if (assessments == null || assessments.isEmpty) {
        setState(() {
          _loading = false;
          _errorMessage = 'No assessments found for ${widget.petName}';
        });
        return;
      }

      // ✅ Step 2: Walk from latest to oldest assessment
      Map<String, dynamic>? foundEntry;
      for (int i = assessments.length - 1; i >= 0; i--) {
        final entry = assessments[i] as Map<String, dynamic>;

        // Firebase might store key as 'Metrics/Confusion'
        final metricsMap = entry['Metrics/Confusion'] as Map<String, dynamic>?;
        if (metricsMap != null && metricsMap.containsKey(widget.illnessName)) {
          foundEntry = Map<String, dynamic>.from(metricsMap[widget.illnessName]);
          break;
        }
      }

      if (foundEntry == null) {
        setState(() {
          _loading = false;
          _errorMessage = 'No metrics found for ${widget.illnessName}';
        });
        return;
      }

      // ✅ Step 3: Parse confusion matrix
      final cmRaw = foundEntry['confusion_matrix'] as Map<String, dynamic>;
      final confMatrix = {
        'TP': (cmRaw['TP'] as num).toInt(),
        'FP': (cmRaw['FP'] as num).toInt(),
        'FN': (cmRaw['FN'] as num).toInt(),
        'TN': (cmRaw['TN'] as num).toInt(),
      };

      // ✅ Step 4: Parse metrics
      final mRaw = foundEntry['metrics'] as Map<String, dynamic>;
      final metrics = <String, double>{};
      mRaw.forEach((k, v) {
        if (v is num) metrics[k] = v.toDouble();
      });

      // If accuracy is missing, calculate it
      if (!metrics.containsKey('accuracy')) {
        final tp = confMatrix['TP']!;
        final tn = confMatrix['TN']!;
        final fp = confMatrix['FP']!;
        final fn = confMatrix['FN']!;
        metrics['accuracy'] = (tp + tn) / (tp + tn + fp + fn);
      }

      // Generate step-by-step calculation formulas
      final tp = confMatrix['TP']!;
      final tn = confMatrix['TN']!;
      final fp = confMatrix['FP']!;
      final fn = confMatrix['FN']!;
      final precision = metrics['precision'] ?? 0.0;
      final recall = metrics['recall'] ?? 0.0;
      final specificity = metrics['specificity'] ?? 0.0;
      final f1Score = metrics['f1Score'] ?? 0.0;
      final accuracy = metrics['accuracy'] ?? 0.0;

      // Format formulas with proper spacing
      _accuracyFormula = '(${tp + tn}) / (${tp + tn + fp + fn}) = '
          '${(accuracy * 100).toStringAsFixed(1)}%';
      _precFormula = '$tp / (${tp + fp}) = '
          '${(precision * 100).toStringAsFixed(1)}%';
      _recFormula = '$tp / (${tp + fn}) = '
          '${(recall * 100).toStringAsFixed(1)}%';
      _specFormula = '$tn / (${tn + fp}) = '
          '${(specificity * 100).toStringAsFixed(1)}%';
      
      final p = precision, r = recall;
      _f1Formula = '2 × ${p.toStringAsFixed(2)} × ${r.toStringAsFixed(2)} '
          '/ (${p.toStringAsFixed(2)} + ${r.toStringAsFixed(2)}) = '
          '${(f1Score * 100).toStringAsFixed(1)}%';

      setState(() {
        _confMatrix = confMatrix;
        _metrics = metrics;
        _loading = false;
      });
      
      _animationController.forward();
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = 'Error fetching metrics: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure ScreenUtil is initialized
    ScreenUtil.init(context, designSize: const Size(390, 844));
    
    return Scaffold(
      backgroundColor: const Color(0xFFE8F2F5),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back,
              color: const Color(0xFF3666BF),
              size: 20.sp,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.illnessName,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF3666BF),
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.info_outline,
                color: const Color(0xFF3666BF),
                size: 20.sp,
              ),
              onPressed: () => _showMetricsInfo(context),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background decoration
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundPainter(),
            ),
          ),
          
          // Pet info bar
          Positioned(
            top: kToolbarHeight + MediaQuery.of(context).padding.top + 16.h,
            left: 16.w,
            right: 16.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    widget.petType.toLowerCase() == 'dog' 
                      ? Icons.pets
                      : Icons.flutter_dash,
                    color: const Color(0xFF52AAA4),
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      widget.petName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1D1D2C),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF52AAA4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      widget.petType,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF52AAA4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Main content
          Positioned.fill(
            top: kToolbarHeight + MediaQuery.of(context).padding.top + 80.h,
            left: 0,
            right: 0,
            bottom: 0,
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF52AAA4),
                    ),
                  )
                : _errorMessage != null
                    ? _buildErrorView()
                    : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: const Color(0xFF52AAA4),
              size: 64.sp,
            ),
            SizedBox(height: 16.h),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1D1D2C),
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _loading = true;
                  _errorMessage = null;
                });
                _fetchSavedMetricsWithCm();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF52AAA4),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_metrics == null || _confMatrix == null) {
      return Center(
        child: Text(
          'No saved metrics for ${widget.illnessName}',
          style: TextStyle(fontSize: 16.sp),
        ),
      );
    }

    final tp = _confMatrix!['TP']!;
    final fp = _confMatrix!['FP']!;
    final fn = _confMatrix!['FN']!;
    final tn = _confMatrix!['TN']!;

    // Percent values
    final acc = ((_metrics!['accuracy'] ?? 0.0) * 100).toStringAsFixed(1);
    final pre = ((_metrics!['precision'] ?? 0.0) * 100).toStringAsFixed(1);
    final rec = ((_metrics!['recall'] ?? 0.0) * 100).toStringAsFixed(1);
    final spec = ((_metrics!['specificity'] ?? 0.0) * 100).toStringAsFixed(1);
    final f1 = ((_metrics!['f1Score'] ?? 0.0) * 100).toStringAsFixed(1);

    return FadeTransition(
      opacity: _fadeInAnimation,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Metrics overview card
            _buildOverviewCard(acc, pre, rec),
            
            SizedBox(height: 24.h),
            
            // Confusion Matrix Card
            _buildMatrixCard(tp, fp, fn, tn),
            
            SizedBox(height: 24.h),
            
            // Detailed Metrics Card
            _buildDetailedMetricsCard(acc, pre, rec, spec, f1),
            
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(String accuracy, String precision, String recall) {
    // Convert string to double for coloring
    final accValue = double.parse(accuracy);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF3666BF),
            const Color(0xFF52AAA4),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3666BF).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Model Performance',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.sentiment_satisfied_alt,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Excellent',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCircularMetric('Accuracy', accuracy, Colors.white),
                _buildCircularMetric('Precision', precision, Colors.white),
                _buildCircularMetric('Recall', recall, Colors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularMetric(String label, String value, Color color) {
    final double percentage = double.parse(value);
    
    return Column(
      children: [
        SizedBox(
          width: 70.w,
          height: 70.w,
          child: Column(
            children: [
              CircularProgressIndicator(
                value: percentage / 100,
                strokeWidth: 3.w,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
               SizedBox(height: 8.h),
              Center(
                child: Text(
                  '$value%',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMatrixCard(int tp, int fp, int fn, int tn) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFF52AAA4),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.grid_on,
                  color: Colors.white,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Confusion Matrix',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                Text(
                  'Actual vs Predicted Values',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1D1D2C),
                  ),
                ),
                SizedBox(height: 16.h),
                Table(
                  border: TableBorder.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5F5F5),
                      ),
                      children: [
                        _buildMatrixCell('', isHeader: true),
                        _buildMatrixCell('Predicted +', isHeader: true),
                        _buildMatrixCell('Predicted -', isHeader: true),
                      ],
                    ),
                    TableRow(
                      children: [
                        _buildMatrixCell('Actual +', isHeader: true),
                        _buildMatrixCell(
                          'TP: $tp',
                          highlight: true,
                          highlightColor: const Color(0xFFE3F2FD),
                        ),
                        _buildMatrixCell('FN: $fn'),
                      ],
                    ),
                    TableRow(
                      children: [
                        _buildMatrixCell('Actual -', isHeader: true),
                        _buildMatrixCell('FP: $fp'),
                        _buildMatrixCell(
                          'TN: $tn',
                          highlight: true,
                          highlightColor: const Color(0xFFE3F2FD),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                _buildMatrixLegend(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatrixLegend() {
    return Wrap(
      spacing: 16.w,
      runSpacing: 8.h,
      children: [
        _buildLegendItem('TP', 'True Positive', const Color(0xFFE3F2FD)),
        _buildLegendItem('FP', 'False Positive', Colors.white),
        _buildLegendItem('FN', 'False Negative', Colors.white),
        _buildLegendItem('TN', 'True Negative', const Color(0xFFE3F2FD)),
      ],
    );
  }

  Widget _buildLegendItem(String code, String label, Color bgColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24.w,
          height: 24.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            code,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1D1D2C),
            ),
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: const Color(0xFF1D1D2C),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedMetricsCard(
      String accuracy, String precision, String recall, String specificity, String f1) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFF52AAA4),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: Colors.white,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Detailed Metrics',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.w),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(2),  // Metric column
                1: FlexColumnWidth(1.5), // Value column - increased width
                2: FlexColumnWidth(4),  // Calculation column
              },
              border: TableBorder.symmetric(
                inside: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              children: [
                _buildDetailedRow(
                  ['Metric', 'Value', 'Calculation'], 
                  isHeader: true
                ),
                _buildDetailedRow([
                  'Accuracy',
                  '$accuracy%',
                  _accuracyFormula
                ]),
                _buildDetailedRow([
                  'Precision',
                  '$precision%',
                  _precFormula
                ]),
                _buildDetailedRow([
                  'Recall',
                  '$recall%',
                  _recFormula
                ]),
                _buildDetailedRow([
                  'Specificity',
                  '$specificity%',
                  _specFormula
                ]),
                _buildDetailedRow([
                  'F1 Score',
                  '$f1%',
                  _f1Formula
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatrixCell(String text, {bool isHeader = false, bool highlight = false, Color highlightColor = Colors.transparent}) {
    return Container(
      padding: EdgeInsets.all(12.w),
      color: highlight ? highlightColor : (isHeader ? const Color(0xFFF5F5F5) : Colors.white),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: isHeader ? 14.sp : 13.sp,
          color: const Color(0xFF1D1D2C),
        ),
      ),
    );
  }

  TableRow _buildDetailedRow(List<String> cells, {bool isHeader = false}) {
    final bgColor = isHeader ? const Color(0xFFF5F5F5) : Colors.white;
    return TableRow(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      children: [
        // Metric column
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
          child: Text(
            cells[0],
            style: TextStyle(
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              fontSize: isHeader ? 14.sp : 13.sp,
              color: const Color(0xFF1D1D2C),
            ),
          ),
        ),
        // Value column - center aligned
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
          child: Text(
            cells[1],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isHeader ? 14.sp : 13.sp,
              color: const Color(0xFF1D1D2C),
            ),
          ),
        ),
        // Calculation column
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
          child: Text(
            cells[2],
            style: TextStyle(
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              fontSize: isHeader ? 14.sp : 13.sp,
              fontFamily: !isHeader ? 'Monospace' : null,
              color: const Color(0xFF1D1D2C),
            ),
          ),
        ),
      ],
    );
  }

  void _showMetricsInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.all(16.w),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Understanding Classification Metrics',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1D1D2C),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              _buildInfoItem(
                'Confusion Matrix',
                'Shows how the predictions are distributed between true and false positives/negatives for ${widget.illnessName}.',
                Icons.grid_on,
              ),
              _buildInfoItem(
                'Accuracy',
                'The proportion of correct predictions (both true positives and true negatives) among the total number of cases examined.',
                Icons.check_circle_outline,
              ),
              _buildInfoItem(
                'Precision',
                'The proportion of positive identifications that were actually correct. High precision means low false positives.',
                Icons.precision_manufacturing_outlined,
              ),
               _buildInfoItem(
                'Recall',
                'The proportion of actual positives that were correctly identified. High recall means low false negatives.',
                Icons.restore_outlined,
              ),
              _buildInfoItem(
                'Specificity',
                'The proportion of actual negatives that were correctly identified. Measures the model\'s ability to identify non-illness cases.',
                Icons.shield_outlined,
              ),
              _buildInfoItem(
                'F1 Score',
                'The harmonic mean of precision and recall. Provides a single metric that balances both concerns.',
                Icons.analytics_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String title, String description, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF52AAA4),
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1D1D2C),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.only(left: 28.w),
            child: Text(
              description,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF1D1D2C).withOpacity(0.7),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Background Painter
class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Background gradient
    final Paint gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFE8F2F5),
          const Color(0xFFE8F2F5).withOpacity(0.8),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      gradientPaint,
    );
    
    // Draw bubbles
    final paint = Paint()
      ..color = const Color(0xFF52AAA4).withOpacity(0.1)
      ..style = PaintingStyle.fill;
    
    // Draw various bubbles
    _drawBubble(canvas, paint, Offset(size.width * 0.2, size.height * 0.15), size.width * 0.1);
    _drawBubble(canvas, paint, Offset(size.width * 0.8, size.height * 0.2), size.width * 0.15);
    _drawBubble(canvas, paint, Offset(size.width * 0.15, size.height * 0.6), size.width * 0.12);
    _drawBubble(canvas, paint, Offset(size.width * 0.85, size.height * 0.7), size.width * 0.18);
    _drawBubble(canvas, paint, Offset(size.width * 0.5, size.height * 0.4), size.width * 0.08);
    _drawBubble(canvas, paint, Offset(size.width * 0.7, size.height * 0.9), size.width * 0.14);
    
    // Draw decorative elements - Paw prints
    final pawPaint = Paint()
      ..color = const Color(0xFF3666BF).withOpacity(0.05)
      ..style = PaintingStyle.fill;
    
    _drawPawPrint(canvas, pawPaint, Offset(size.width * 0.1, size.height * 0.3), size.width * 0.06);
    _drawPawPrint(canvas, pawPaint, Offset(size.width * 0.9, size.height * 0.4), size.width * 0.05);
    _drawPawPrint(canvas, pawPaint, Offset(size.width * 0.3, size.height * 0.85), size.width * 0.07);
  }
  
  void _drawBubble(Canvas canvas, Paint paint, Offset center, double radius) {
    canvas.drawCircle(center, radius, paint);
  }
  
  void _drawPawPrint(Canvas canvas, Paint paint, Offset center, double size) {
    // Main pad
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + size * 0.2),
        width: size * 1.2,
        height: size * 1.0,
      ),
      paint,
    );
    
    // Toes
    canvas.drawCircle(
      Offset(center.dx - size * 0.4, center.dy - size * 0.3),
      size * 0.3,
      paint,
    );
    canvas.drawCircle(
      Offset(center.dx, center.dy - size * 0.4),
      size * 0.3,
      paint,
    );
    canvas.drawCircle(
      Offset(center.dx + size * 0.4, center.dy - size * 0.3),
      size * 0.3,
      paint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}