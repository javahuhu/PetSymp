import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:petsymp/HomePage/homepage.dart';
import 'package:petsymp/HomePage/profile.dart';
import 'package:provider/provider.dart';
import '../userdata.dart';
import 'package:url_launcher/url_launcher.dart';
import '../barchart/barfirebasegraph.dart';
import 'historyillnessdetails.dart';
import 'package:petsymp/illnessdescriptions.dart';

class ViewhistoryScreen extends StatefulWidget {
  final Map<String, dynamic> historyData; // Data passed from the history card
  const ViewhistoryScreen({Key? key, required this.historyData})
      : super(key: key);

  @override
  ViewhistoryScreenState createState() => ViewhistoryScreenState();
}

class ViewhistoryScreenState extends State<ViewhistoryScreen> {
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

  String _extractDescription(Map<String, dynamic> diagnosis) {
    final name = diagnosis['illness'] as String? ?? '';
    final info = illnessInformation[name];
    if (info != null && info['Description'] is List<dynamic>) {
      final list = (info['Description'] as List<dynamic>).cast<String>();
      if (list.isNotEmpty) return list.join('\n\n');
    }
    return 'No description available.';
  }

  final List<ListItem> recommendations = [
    const ListItem(
      title: 'Provide Medicine for Lethargy',
      subtitle: 'Techniques on how your dog can take vitamins easily',
      route: HomePageScreen(),
      isExternal: false,
      imageUrl: 'assets/youtube1.jpg',
    ),
    const ListItem(
      title: 'How to Easily Give Your Pet Medicine Without Stress!',
      subtitle:
          "Learn simple techniques to give your pet medicine, ensuring their health and comfort",
      route: Profilescreen(),
      isExternal: false,
      imageUrl: 'assets/youtube1.jpg',
    ),
    const ListItem(
      title: 'Tricks to Give Your Pet Medicine Without a Fight!',
      subtitle: 'Discover easy ways to give your pet medicine without stress',
      url:
          'https://www.youtube.com/results?search_query=flutter+list+with+images',
      isExternal: true,
      imageUrl: 'assets/youtube1.jpg',
    ),
    const ListItem(
      title: 'How to Hide Medicine in Treats for Your Pet!',
      subtitle:
          'Learn safe ways to hide pills in treats so your pet takes medicine without noticing',
      route: HomePageScreen(),
      isExternal: false,
      imageUrl: 'assets/youtube1.jpg',
    ),
    const ListItem(
      title: 'The Right Way to Give Your Pet Liquid Medicine!',
      subtitle:
          "Master techniques to give your pet liquid medicine without mess",
      route: Profilescreen(),
      isExternal: false,
      imageUrl: 'assets/youtube1.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Use the passed historyData.
    final Map<String, dynamic> historyData = widget.historyData;
    final String petName = historyData['petName'] ?? "Unknown";
    final List<Map<String, String>> petDetails =
        (historyData['petDetails'] as List<dynamic>?)
                ?.map((e) => Map<String, String>.from(e as Map))
                .toList() ??
            [
              {"icon": "🎂", "label": "Pet", "value": "Unknown"},
              {"icon": "🎂", "label": "Age", "value": "0"},
              {"icon": "📏", "label": "Size", "value": "0"},
              {"icon": "🐶", "label": "Breed", "value": "Unknown"},
              {"icon": "☣️", "label": "Symptoms", "value": ""},
            ];
    final List<Map<String, dynamic>> diagnoses =
        List<Map<String, dynamic>>.from(historyData['diagnosisResults'] ?? []);
    List<Map<String, dynamic>> topDiagnoses = [];
    if (diagnoses.isNotEmpty) {
      topDiagnoses = diagnoses.length >= 3
          ? diagnoses.sublist(0, 3)
          : List<Map<String, dynamic>>.from(diagnoses);
    }
    // Properly cast saved symptom details.
    final rawDetails = historyData['symptomDetails'] ?? {};
    final Map<String, List<Map<String, dynamic>>> savedSymptomDetails = {};
    if (rawDetails is Map) {
      rawDetails.forEach((key, value) {
        if (value is List) {
          savedSymptomDetails[key] =
              value.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      });
    }

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 25.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date display.
                Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBF2F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        historyData['date'] != null
                            ? (historyData['date'] as Timestamp)
                                .toDate()
                                .toString()
                            : "No Date",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF3D4A5C),
                        ),
                      ),
                      const Icon(
                        Icons.calendar_today_rounded,
                        color: Color(0xFF52AAA4),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                // Pet Card.
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20)),
                        child: Container(
                          height: 200.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                const Color.fromARGB(255, 82, 107, 106)
                                    .withValues(alpha: 0.7),
                                const Color(0xFF52AAA4),
                              ],
                            ),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Container(
                                  width: 150.w,
                                  height: 150.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 4,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: (historyData['petImage'] != null &&
                                            (historyData['petImage'] as String)
                                                .isNotEmpty)
                                        ? ((historyData['petImage'] as String)
                                                .startsWith("http")
                                            ? Image.network(
                                                historyData['petImage'],
                                                fit: BoxFit.cover,
                                              )
                                            : Image.asset(
                                                historyData['petImage'],
                                                fit: BoxFit.cover,
                                              ))
                                        : Image.asset(
                                            "assets/sampleimage.jpg",
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withValues(alpha: 0.5),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      petName,
                                      style: TextStyle(
                                        fontSize: 22.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(15.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pet Details",
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF3D4A5C),
                              ),
                            ),
                            SizedBox(height: 15.h),
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              childAspectRatio: 2.5,
                              crossAxisSpacing: 10.w,
                              mainAxisSpacing: 10.h,
                              children: petDetails.map((detail) {
                                return Container(
                                  padding: EdgeInsets.all(5.w),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEBF2F7),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        detail["label"]!,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF52AAA4),
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        detail["value"]!,
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF3D4A5C),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 25.h),
                if (topDiagnoses.isNotEmpty)
                  _buildDiagnosisSection(topDiagnoses),
                SizedBox(height: 25.h),
                _buildExpandableCard(
                  title: "Statistics & Analysis",
                  icon: Icons.bar_chart_rounded,
                  content: Column(
                    children: [
                      Container(
                        height: 300.h,
                        padding: EdgeInsets.symmetric(
                            horizontal: 5.w, vertical: 15.h),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 245, 245, 245),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: const Color(0xFFEBF2F7),
                            width: 1,
                          ),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Consumer<UserData>(
                            builder: (_, userData, __) {
                              final diagnoses = List<Map<String, dynamic>>.from(
                                  historyData['diagnosisResults'] as List? ??
                                      []);
                              diagnoses.sort((a, b) =>
                                  (b['confidence_ab'] as num)
                                      .compareTo((a['confidence_ab'] as num)));
                              final top10 = diagnoses.take(10).toList();
                              while (top10.length < 10) {
                                top10.add({
                                  'illness': '',
                                  'confidence_fc': 0.0,
                                  'confidence_gb': 0.0,
                                  'confidence_ab': 0.0,
                                  'subtype_coverage': 0.0
                                });
                              }
                              final labels = top10
                                  .map((d) => d['illness'] as String)
                                  .toList();
                              final fc = top10
                                  .map((d) =>
                                      (d['confidence_fc'] as num).toDouble())
                                  .toList();
                              final gb = top10
                                  .map((d) =>
                                      (d['confidence_gb'] as num).toDouble())
                                  .toList();
                              final ab = top10
                                  .map((d) =>
                                      (d['confidence_ab'] as num).toDouble())
                                  .toList();
                              final double groupWidth = 20.w;
                              final double gapWidth = 90.w;
                              final double totalRequiredWidth =
                                  (groupWidth * labels.length) +
                                      (gapWidth * (labels.length - 1));
                              final double screenWidth =
                                  MediaQuery.of(context).size.width - 20.w;
                              final double chartWidth =
                                  totalRequiredWidth < screenWidth
                                      ? screenWidth
                                      : totalRequiredWidth;
                              return SizedBox(
                                width: chartWidth,
                                child: BarChartRetrieve(
                                  illnessLabels: labels,
                                  fcScores: fc,
                                  gbScores: gb,
                                  abScores: ab,
                                  symptomDetails: savedSymptomDetails,
                                  petName: historyData['petName'] as String,
                                  petType: historyData['petType'] as String,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 245, 245, 245),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: const Color(0xFFEBF2F7),
                            width: 1,
                          ),
                        ),
                        child: Wrap(
                          spacing: 20.w,
                          runSpacing: 10.h,
                          children: [
                            _legendDot(
                                const Color(0xFF4285F4), "Confidence Score"),
                            _legendDot(
                                const Color(0xFF34A853), "Weighted Symptoms"),
                            _legendDot(
                                const Color(0xFFFFA726), "ML Score Adjustment"),
                            _legendDot(
                                const Color(0xFF7B1FA2), "Subtype Coverage"),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                      if (topDiagnoses.length >= 2)
                        Container(
                          padding: EdgeInsets.all(15.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: const Color(0xFFEBF2F7),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Top Diagnoses Comparison",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF3D4A5C),
                                ),
                              ),
                              SizedBox(height: 15.h),
                              _buildComparisonTable(topDiagnoses),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 25.h),
               
              ],
            ),
          ),
        ),
      ),
    );
  }
Widget _buildDiagnosisSection(List<Map<String, dynamic>> topDiagnoses) {
  final primary = topDiagnoses[0];
  final secondary = topDiagnoses.length > 1 ? topDiagnoses[1] : null;
  final tertiary = topDiagnoses.length > 2 ? topDiagnoses[2] : null;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildDiagnosisItem(
        primary,
        isPrimary: true,
        description: _extractDescription(primary),
        rank: 1,
      ),
      if (secondary != null) ...[
        SizedBox(height: 16.h),
        _buildDiagnosisItem(
          secondary,
          description: _extractDescription(secondary),
          rank: 2,
        ),
      ],
      if (tertiary != null) ...[
        SizedBox(height: 16.h),
        _buildDiagnosisItem(
          tertiary,
          description: _extractDescription(tertiary),
          rank: 3,
        ),
      ],
    ],
  );
}

Widget _buildDiagnosisItem(
  Map<String, dynamic> diagnosis, {
  bool isPrimary = false,
  required String description,
  required int rank,
}) {
  final confidence = (diagnosis['confidence_ab'] as num?)?.toDouble() ?? 0.0;
  final type = diagnosis['type'] ?? "Unknown";

  final ageRaw = (diagnosis['age_specificity'] ?? "Unknown").toString();
  final sizeRaw = (diagnosis['size_specificity'] ?? "Unknown").toString();

  final ageLabel = ageRaw.toLowerCase() == 'any' ? 'Any Age' : ageRaw;
  final sizeLabel = sizeRaw.toLowerCase() == 'any' ? 'Any Size' : sizeRaw;

  return Container(
    margin: EdgeInsets.only(bottom: 20.h),
    padding: EdgeInsets.all(15.w),
    decoration: BoxDecoration(
      color: isPrimary ? const Color(0xFFEFF8F7) : const Color(0xFFF7F9FA),
      borderRadius: BorderRadius.circular(15),
      border: isPrimary
          ? Border.all(color: const Color(0xFF52AAA4), width: 1.5)
          : Border.all(color: const Color(0xFFEBF2F7), width: 1),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(25),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 60.w,
                      height: 60.w,
                      child: CircularProgressIndicator(
                        value: 100,
                        backgroundColor: Colors.grey.withAlpha(50),
                        color: const Color(0xFF52AAA4),
                        strokeWidth: 8.w,
                      ),
                    ),
                    Text(
                      "$rank",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: isPrimary
                            ? const Color(0xFF52AAA4)
                            : const Color(0xFF3D4A5C),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    diagnosis['illness'] ?? "Unknown",
                    style: TextStyle(
                      fontSize: isPrimary ? 18.sp : 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3D4A5C),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 4.h,
                    children: [
                      if (isPrimary)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF52AAA4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "Most Likely",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      if (type.isNotEmpty)
                        _buildInfoChip(type),
                      _buildInfoChip(ageLabel),
                      _buildInfoChip(sizeLabel),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 15.h),
        Text(
          description,
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF6B7A8D),
          ),
        ),
        SizedBox(height: 15.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: () {
                final Map<String, dynamic> historyData = widget.historyData;
                final List<Map<String, dynamic>> diagnoses =
                    List<Map<String, dynamic>>.from(
                        historyData['diagnosisResults'] ?? []);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoryIllnessdetailsScreen(
                      diagnosisData: diagnosis,
                      totalIllnesses: diagnoses.length,
                      allDiagnoses: diagnoses,
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.arrow_forward,
                color: Color(0xFF52AAA4),
                size: 18,
              ),
              label: Text(
                "See Details",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF52AAA4),
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildInfoChip(String label) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFF52AAA4)),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF52AAA4),
      ),
    ),
  );
}

  Widget _buildExpandableCard({
    required String title,
    required IconData icon,
    required Widget content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          backgroundColor: const Color.fromARGB(0, 0, 0, 0),
          leading: Icon(
            icon,
            color: const Color(0xFF52AAA4),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF3D4A5C),
            ),
          ),
          initiallyExpanded: true,
          childrenPadding: EdgeInsets.all(15.w),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [content],
        ),
      ),
    );
  }


  Widget _buildComparisonTable(List<Map<String, dynamic>> topDiagnoses) {
    final ill1 = topDiagnoses[0];
    final ill2 = topDiagnoses[1];
    final double confAb1 = (ill1['confidence_ab'] as num?)?.toDouble() ?? 0.0;
    final double confAb2 = (ill2['confidence_ab'] as num?)?.toDouble() ?? 0.0;
    final double confFc1 = (ill1['confidence_fc'] as num?)?.toDouble() ?? 0.0;
    final double confFc2 = (ill2['confidence_fc'] as num?)?.toDouble() ?? 0.0;
    final double mlScore1 = confAb1 - confFc1;
    final double mlScore2 = confAb2 - confFc2;
    final double coverage1 =
        (ill1['subtype_coverage'] as num?)?.toDouble() ?? 0.0;
    final double coverage2 =
        (ill2['subtype_coverage'] as num?)?.toDouble() ?? 0.0;
    return Table(
      border: TableBorder(
        horizontalInside: BorderSide(
          color: Colors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      columnWidths: const {
        0: FlexColumnWidth(1.1),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: const Color(0xFFEFF8F7),
            borderRadius: BorderRadius.circular(8),
          ),
          children: [
            _tableHeaderCell("Metric"),
            _tableHeaderCell(ill1['illness'] ?? "Top 1"),
            _tableHeaderCell(ill2['illness'] ?? "Top 2"),
          ],
        ),
        TableRow(
          children: [
            _tableCell("Confidence"),
            _tableScoreCell(confAb1, true),
            _tableScoreCell(confAb2, false),
          ],
        ),
        TableRow(
          children: [
            _tableCell("Symptoms Match"),
            _tableScoreCell(confFc1, true),
            _tableScoreCell(confFc2, false),
          ],
        ),
        TableRow(
          children: [
            _tableCell("ML Adjustment"),
            _tableScoreCell(mlScore1, true),
            _tableScoreCell(mlScore2, false),
          ],
        ),
        TableRow(
          children: [
            _tableCell("Coverage"),
            _tableScoreCell(coverage1, true),
            _tableScoreCell(coverage2, false),
          ],
        ),
      ],
    );
  }

  Widget _tableHeaderCell(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF3D4A5C),
        ),
      ),
    );
  }

  Widget _tableCell(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          color: const Color(0xFF6B7A8D),
        ),
      ),
    );
  }

  Widget _tableScoreCell(double value, bool isHighlighted) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      color: isHighlighted
          ? const Color(0xFFEFF8F7).withValues(alpha: 0.3)
          : Colors.transparent,
      child: Text(
        value.toStringAsFixed(2),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
          color:
              isHighlighted ? const Color(0xFF52AAA4) : const Color(0xFF3D4A5C),
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: const Color(0xFF6B7A8D),
          ),
        ),
      ],
    );
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}

class ListItem {
  final String title;
  final String subtitle;
  final Widget? route;
  final String? url;
  final bool isExternal;
  final String imageUrl;

  const ListItem({
    required this.title,
    required this.subtitle,
    this.route,
    this.url,
    required this.isExternal,
    required this.imageUrl,
  });
}
