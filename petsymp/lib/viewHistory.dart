import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:petsymp/Illnessdetails.dart';
import 'package:petsymp/homepage.dart';
import 'package:petsymp/profile.dart';
import 'package:provider/provider.dart';
import 'userdata.dart';
import 'package:url_launcher/url_launcher.dart';
import 'barchart/barfirebasegraph.dart';

class ViewhistoryScreen extends StatefulWidget {
  final Map<String, dynamic> historyData; // Data passed from the history card
  const ViewhistoryScreen({Key? key, required this.historyData}) : super(key: key);

  @override
  ViewhistoryScreenState createState() => ViewhistoryScreenState();
}

class ViewhistoryScreenState extends State<ViewhistoryScreen> {
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
      url: 'https://www.youtube.com/results?search_query=flutter+list+with+images',
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
                  padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
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
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: Container(
                          height: 200.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                const Color.fromARGB(255, 82, 107, 106).withOpacity(0.7),
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
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: (historyData['petImage'] != null &&
                                            (historyData['petImage'] as String).isNotEmpty)
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
                                        Colors.black.withOpacity(0.5),
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                if (topDiagnoses.isNotEmpty) _buildDiagnosisSection(topDiagnoses),
                SizedBox(height: 25.h),
                _buildExpandableCard(
                  title: "Statistics & Analysis",
                  icon: Icons.bar_chart_rounded,
                  content: Column(
                    children: [
                      Container(
                        height: 300.h,
                        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 15.h),
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
                                  historyData['diagnosisResults'] as List? ?? []);
                              diagnoses.sort((a, b) => (b['confidence_ab'] as num)
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
                              final labels = top10.map((d) => d['illness'] as String).toList();
                              final fc = top10.map((d) => (d['confidence_fc'] as num).toDouble()).toList();
                              final gb = top10.map((d) => (d['confidence_gb'] as num).toDouble()).toList();
                              final ab = top10.map((d) => (d['confidence_ab'] as num).toDouble()).toList();
                              final double groupWidth = 20.w;
                              final double gapWidth = 90.w;
                              final double totalRequiredWidth =
                                  (groupWidth * labels.length) +
                                      (gapWidth * (labels.length - 1));
                              final double screenWidth =
                                  MediaQuery.of(context).size.width - 20.w;
                              final double chartWidth = totalRequiredWidth < screenWidth
                                  ? screenWidth
                                  : totalRequiredWidth;
                              // Note: the variable 'savedSymptomDetails' is built from the passed historyData.
                              return SizedBox(
                                width: chartWidth,
                                child: BarChartRetrieve(
                                  illnessLabels: labels,
                                  fcScores: fc,
                                  gbScores: gb,
                                  abScores: ab,
                                  symptomDetails: savedSymptomDetails,
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
                            _legendDot(const Color(0xFF4285F4), "Confidence Score"),
                            _legendDot(const Color(0xFF34A853), "Weighted Symptoms"),
                            _legendDot(const Color(0xFFFFA726), "ML Score Adjustment"),
                            _legendDot(const Color(0xFF7B1FA2), "Subtype Coverage"),
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
                _buildExpandableCard(
                  title: "Recommended Resources",
                  icon: Icons.lightbulb_outline,
                  content: Column(
                    children: recommendations
                        .map((item) => _buildRecommendationItem(item))
                        .toList(),
                  ),
                ),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiagnosisSection(List<Map<String, dynamic>> topDiagnoses) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.medical_information_rounded,
                color: Color(0xFF52AAA4),
              ),
              SizedBox(width: 10.w),
              Text(
                "Diagnosis Results",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF3D4A5C),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _buildDiagnosisItem(
            topDiagnoses[0],
            isPrimary: true,
            description:
                "A highly contagious viral disease that affects dogs, causing acute gastrointestinal illness, particularly in puppies.",
          ),
          if (topDiagnoses.length > 1)
            _buildDiagnosisItem(
              topDiagnoses[1],
              description:
                  "A highly contagious viral disease that affects dogs, causing acute gastrointestinal illness, particularly in puppies.",
            ),
          if (topDiagnoses.length > 2)
            _buildDiagnosisItem(
              topDiagnoses[2],
              description:
                  "A highly contagious viral disease that affects dogs, causing acute gastrointestinal illness, particularly in puppies.",
            ),
        ],
      ),
    );
  }

  Widget _buildDiagnosisItem(Map<String, dynamic> diagnosis,
      {bool isPrimary = false, required String description}) {
    final confidence = (diagnosis['confidence_ab'] as num?)?.toDouble() ?? 0.0;
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
                      color: Colors.black.withOpacity(0.1),
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
                          value: confidence,
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          color: isPrimary ? const Color(0xFF52AAA4) : const Color(0xFFFFA726),
                          strokeWidth: 8.w,
                        ),
                      ),
                      Text(
                        "${(confidence * 100).round()}%",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: isPrimary ? const Color(0xFF52AAA4) : const Color(0xFF3D4A5C),
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
                    if (isPrimary)
                      Container(
                        margin: EdgeInsets.only(top: 5.h),
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IllnessdetailsScreen(illnessName: diagnosis['illness']),
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
            color: Colors.black.withOpacity(0.05),
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

  Widget _buildRecommendationItem(ListItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FA),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            if (item.isExternal) {
              await _launchURL(item.url!);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => item.route!,
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    item.imageUrl,
                    width: 80.w,
                    height: 80.h,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF52AAA4),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        item.subtitle,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF6B7A8D),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 5.w),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFF52AAA4),
                  size: 18,
                ),
              ],
            ),
          ),
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
    final double coverage1 = (ill1['subtype_coverage'] as num?)?.toDouble() ?? 0.0;
    final double coverage2 = (ill2['subtype_coverage'] as num?)?.toDouble() ?? 0.0;
    return Table(
      border: TableBorder(
        horizontalInside: BorderSide(
          color: Colors.grey.withOpacity(0.2),
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
      color: isHighlighted ? const Color(0xFFEFF8F7).withOpacity(0.3) : Colors.transparent,
      child: Text(
        value.toStringAsFixed(2),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
          color: isHighlighted ? const Color(0xFF52AAA4) : const Color(0xFF3D4A5C),
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
