import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:petsymp/viewhistory.dart'; // Update with your actual path to ViewhistoryScreen
import 'package:url_launcher/url_launcher.dart';
class PetProfileScreen extends StatefulWidget {
  const PetProfileScreen({Key? key}) : super(key: key);

  @override
  _PetProfileScreenState createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends State<PetProfileScreen> {
  // Fetch pet history documents from Firestore.
  Future<List<Map<String, dynamic>>> fetchPetHistory() async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw Exception("User is not signed in.");
    }
    final snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('History')
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(29, 29, 44, 1.0),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(29, 29, 44, 1.0),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Pets Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22.sp,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white, size: 24.sp),
            onPressed: () {
              // Add search functionality here if needed
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchPetHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: const Color(0xFF52AAA4),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red[300],
                    size: 60.sp,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "Error: ${snapshot.error}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {}); // Retry fetching data
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF52AAA4),
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      "Retry",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pets,
                    color: Colors.grey[400],
                    size: 80.sp,
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    "No pet profiles found",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "Add a pet to get started",
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 32.h),
                  ElevatedButton.icon(
                    icon: Icon(Icons.add),
                    label: Text("Add Pet"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF52AAA4),
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onPressed: () {
                      // Add navigation to pet creation screen if needed
                    },
                  ),
                ],
              ),
            );
          } else {
            final petHistory = snapshot.data!;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 4.w, bottom: 16.h),
                    child: Text(
                      'Your Pets',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Two columns
                        crossAxisSpacing: 16.w,
                        mainAxisSpacing: 16.h,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: petHistory.length,
                      itemBuilder: (context, index) {
                        final petData = petHistory[index];
                        return _buildPetCard(context, petData);
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  /// Builds each pet card in the grid using the fetched data.
  Widget _buildPetCard(BuildContext context, Map<String, dynamic> petData) {
    final String petName = petData['petName'] ?? "Unknown";
    final List<dynamic> details = petData['petDetails'] ?? [];
    // Assume index 1 = Age, index 2 = Size, index 3 = Breed.
    final String age = (details.length > 1) ? details[1]['value'] ?? "0 yrs" : "0 yrs";
    final String breed = (details.length > 3) ? details[3]['value'] ?? "Unknown" : "Unknown";
    final String imageUrl = petData['petImage'] ?? "assets/sampleimage.jpg";
    
    return GestureDetector(
      onTap: () {
        _showPetDetails(context, petData);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF52AAA4).withOpacity(0.1),
              const Color(0xFF3D4A5C).withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pet image at the top with overlay gradient
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                  child: imageUrl.startsWith("http")
                      ? Image.network(
                          imageUrl,
                          height: 140.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 140.h,
                              color: Colors.grey[800],
                              child: Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.white70,
                                  size: 40.sp,
                                ),
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 140.h,
                              color: Colors.grey[800],
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: const Color(0xFF52AAA4),
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                        )
                      : Image.asset(
                          imageUrl,
                          height: 140.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
                // Gradient overlay on image
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 40.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Pet details below image
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      petName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(
                          Icons.pets,
                          size: 14.sp,
                          color: const Color(0xFF52AAA4),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            '$age • $breed',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[300],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Displays a bottom sheet with pet details and shows all assessments.
  /// For each assessment (each group of input symptoms) it computes the final illness based on diagnosisResults.
  void _showPetDetails(BuildContext context, Map<String, dynamic> petData) {
    // Extract the assessments array saved in the history document.
    final List<dynamic> assessments = petData['assessments'] ?? [];

    // Retrieve the overall date from the petData document (fallback if individual assessments don't have one)
    final dynamic timestamp = petData['date'];
    final String defaultDateStr = (timestamp != null && timestamp is Timestamp)
        ? "${timestamp.toDate().day} ${_getMonthAbbr(timestamp.toDate().month)} ${timestamp.toDate().year}"
        : "N/A";

    // Extract pet details.
    final List<dynamic> details = petData['petDetails'] ?? [];
    final String age = (details.length > 1) ? details[1]['value'] ?? "Unknown" : "Unknown";
    final String size = (details.length > 2) ? details[2]['value'] ?? "Unknown" : "Unknown";
    final String breed = (details.length > 3) ? details[3]['value'] ?? "Unknown" : "Unknown";

    // Build a list of health record widgets.
    List<Widget> healthRecords = [];
    if (assessments.isNotEmpty) {
      for (var assessment in assessments) {
        // Get the input symptoms (e.g. "vomiting + fever + diarrhea")
        final String inputSymptoms = assessment['allSymptoms'] ?? "";
        // Get the diagnosis results from this assessment.
        final List<dynamic> diag = assessment['diagnosisResults'] ?? [];
        String finalIllness = "No Result";
        Timestamp? assessTimestamp;
        if (diag.isNotEmpty) {
          // Sort the diagnosis results by confidence_ab descending and take the top one.
          List<dynamic> sortedDiag = List.from(diag);
          sortedDiag.sort((a, b) => (b['confidence_ab'] as num)
              .compareTo(a['confidence_ab'] as num));
          finalIllness = sortedDiag.first['illness'] ?? "No Result";
          assessTimestamp = sortedDiag.first['date'] is Timestamp
              ? sortedDiag.first['date'] as Timestamp
              : null;
        }
        final String assessDate = assessTimestamp != null
            ? "${assessTimestamp.toDate().day} ${_getMonthAbbr(assessTimestamp.toDate().month)} ${assessTimestamp.toDate().year}"
            : defaultDateStr;

        healthRecords.add(
          _buildHealthRecordItem(
            title: "$inputSymptoms\n→ $finalIllness",
            date: assessDate,
            status: "Completed",
            isCompleted: true,
            onTap: () {
              // When tapped, navigate to ViewhistoryScreen passing this specific assessment.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewhistoryScreen(historyData: Map<String, dynamic>.from(assessment)),
                ),
              );
            },
          ),
        );
      }
    } else {
      healthRecords.add(
        _buildHealthRecordItem(
          title: "No assessments available",
          date: defaultDateStr,
          status: "N/A",
          isCompleted: false,
          onTap: () {},
        ),
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(50.r)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top section with pet image and info.
              Stack(
                children: [
                  Container(
                    height: 350.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50.r),
                        topRight: Radius.circular(50.r),
                      ),
                      image: DecorationImage(
                        image: petData['petImage'] != null &&
                                (petData['petImage'] as String).startsWith("http")
                            ? NetworkImage(petData['petImage'])
                            : AssetImage(petData['petImage'] ?? "assets/sampleimage.jpg") as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12.h,
                    left: 12.w,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(8.sp),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12.h,
                    left: 16.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          petData['petName'] ?? "Unknown",
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 8.0,
                                color: Colors.black.withOpacity(0.5),
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          breed,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 8.0,
                                color: Colors.black.withOpacity(0.5),
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Details section.
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Details",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    // Pet details in 3 cards.
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailCard(
                            icon: Icons.cake,
                            iconColor: Colors.amber,
                            label: "Age",
                            value: age,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _buildDetailCard(
                            icon: Icons.pets,
                            iconColor: Colors.brown,
                            label: "Breed",
                            value: breed,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _buildDetailCard(
                            icon: Icons.straighten,
                            iconColor: Colors.blue,
                            label: "Size",
                            value: size,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    // Recent Health Records section.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Recent Health Records",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          "See All",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    // Display all assessments health records.
                    Column(
                      children: healthRecords,
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Helper method to get month abbreviation.
  String _getMonthAbbr(int month) {
    const List<String> months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
  
  /// Builds a detail card for age, breed, size.
  Widget _buildDetailCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 24.sp,
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Builds a health record item.
  Widget _buildHealthRecordItem({
    required String title,
    required String date,
    required String status,
    required bool isCompleted,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        child: Row(
          children: [
            // Status icon.
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.check_circle : Icons.access_time,
                color: isCompleted ? Colors.green : Colors.orange,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 16.w),
            // Title and date.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    date,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
            // Status label.
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: isCompleted ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w500,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Builds an expandable card (unchanged UI).
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
          backgroundColor: Colors.transparent,
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

  /// Builds a recommendation item (unchanged UI).
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
  final int age;
  final String breed;
  final Color color;
  final String size;

  const ListItem({
    required this.title,
    required this.subtitle,
    this.route,
    this.url,
    required this.isExternal,
    required this.imageUrl,
    required this.age,
    required this.breed,
    required this.color,
    required this.size,
  });
}

// Extension method to darken colors.
extension ColorExtension on Color {
  Color darken([int percent = 10]) {
    assert(1 <= percent && percent <= 100);
    final value = 1 - percent / 100;
    return Color.fromARGB(
      alpha,
      (red * value).round(),
      (green * value).round(),
      (blue * value).round(),
    );
  }
}
