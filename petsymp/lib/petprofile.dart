import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:petsymp/viewhistory.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';


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
    
    // Get the history collection reference
    final historyCol = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('History');
    
    // Get the documents ordered by date
    final snapshot = await historyCol
        .orderBy('date', descending: true)
        .get();
    
    // Map the documents to include their IDs
    return snapshot.docs
        .map((doc) {
          // Add the document ID to each document data
          final data = doc.data();
          return {
            ...data,
            'id': doc.id, // Include the document ID for editing
          };
        })
        .toList();
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
              // Add search functionality here if needed.
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
                      setState(() {}); // Retry fetching data.
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF52AAA4),
                      padding: EdgeInsets.symmetric(
                          horizontal: 24.w, vertical: 12.h),
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
                      padding: EdgeInsets.symmetric(
                          horizontal: 24.w, vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onPressed: () {
                      // Add navigation to pet creation screen if needed.
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
                        crossAxisCount: 2, // Two columns.
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
    final List<dynamic> details = petData['petDetails'] is List ? petData['petDetails'] : [];
    // Extract details with fallbacks.
    final String age = details.length > 1 ? (details[1]['value']?.toString() ?? "0 yrs") : "0 yrs";
    final String breed = details.length > 3 ? (details[3]['value']?.toString() ?? "Unknown") : "Unknown";
    // Removed Symptoms detail from the pet card display.
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
            // Pet image at the top with overlay gradient.
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
                // Gradient overlay on image.
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
            // Pet details below the image.
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

  /// Displays a bottom sheet with pet details and health record assessments.
  /// Each assessment's symptom input is merged (deep copy) into the pet's details
  /// so that when you tap a health record, the correct symptom (e.g. "diarrhea" or "vomiting") is shown.
  /// The bottom sheet height can be manually adjusted by the user by dragging the image area.
  void _showPetDetails(BuildContext context, Map<String, dynamic> petData) {
    final List<dynamic> assessments = petData['assessments'] is List ? petData['assessments'] : [];
    final dynamic timestamp = petData['date'];
    final String defaultDateStr = (timestamp != null && timestamp is Timestamp)
        ? "${timestamp.toDate().day} ${_getMonthAbbr(timestamp.toDate().month)} ${timestamp.toDate().year}"
        : "N/A";
    final List<dynamic> details = petData['petDetails'] is List ? petData['petDetails'] : [];
    final String age = details.length > 1 ? (details[1]['value']?.toString() ?? "Unknown") : "Unknown";
    final String size = details.length > 2 ? (details[2]['value']?.toString() ?? "Unknown") : "Unknown";
    final String breed = details.length > 3 ? (details[3]['value']?.toString() ?? "Unknown") : "Unknown";

    List<Widget> healthRecords = [];
    if (assessments.isNotEmpty) {
      for (var assessment in assessments) {
        // Use the symptom input stored in this assessment.
        final String inputSymptoms = assessment['allSymptoms'] ?? "";
        // Get the diagnosis results from the assessment.
        final List<dynamic> diag = assessment['diagnosisResults'] ?? [];
        String finalIllness = "No Result";
        Timestamp? assessTimestamp;
        if (diag.isNotEmpty) {
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

        // Create a deep copy of the petDetails list.
        List<dynamic> updatedPetDetails = (petData['petDetails'] as List<dynamic>?)
            ?.map((e) => Map<String, dynamic>.from(e))
            .toList() ?? [];
        // Update or add the Symptoms detail for this assessment.
        if (updatedPetDetails.length >= 5) {
          updatedPetDetails[4]['value'] = inputSymptoms;
        } else {
          updatedPetDetails.add({"icon": "☣️", "label": "Symptoms", "value": inputSymptoms});
        }

        // Merge the pet's basic data with the assessment-specific fields.
        Map<String, dynamic> mergedData = {
          'id': petData['id'], // Include document ID for editing
          'petName': petData['petName'] ?? "Unknown",
          'petDetails': updatedPetDetails,
          'petImage': petData['petImage'] ?? "assets/sampleimage.jpg",
          'petType': petData['petType'] ?? "",
          // Overwrite/assign assessment-specific fields.
          'date': assessment['date'] ?? defaultDateStr,
          'diagnosisResults': assessment['diagnosisResults'] ?? [],
          'allSymptoms': inputSymptoms,
          'symptomDetails': assessment['symptomDetails'] ?? {},
        };

        healthRecords.add(
          _buildHealthRecordItem(
            title: "$inputSymptoms\n→ $finalIllness",
            date: assessDate,
            status: "Completed",
            isCompleted: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewhistoryScreen(historyData: mergedData),
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

    // Create a key to access the modal sheet's state
    final GlobalKey<ImageDraggableBottomSheetState> resizableSheetKey = GlobalKey<ImageDraggableBottomSheetState>();

    // Store the current context's size
    final Size screenSize = MediaQuery.of(context).size;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false, // Disable default dragging to use our custom implementation
      isDismissible: true,
      builder: (context) {
        return ImageDraggableBottomSheet(
          key: resizableSheetKey,
          initialHeight: screenSize.height * 0.85, // Start at 85% of screen height
          minHeight: screenSize.height * 0.4, // Minimum height (40%)
          maxHeight: screenSize.height * 0.95, // Maximum height (95%)
          petData: petData,
          borderRadius: BorderRadius.vertical(top: Radius.circular(50.r)),
          petBreed: breed,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(50.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          onPetDetailsUpdated: () {
            // Refresh the screen when pet details are updated
            setState(() {});
          },
          child: Padding(
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
                // Pet details in cards
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
                // Display all health record items.
                Column(
                  children: healthRecords,
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        );
      },
      // Set barrier color and other modal properties
      barrierColor: Colors.black.withOpacity(0.5),
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
  
  /// Builds a detail card for a pet detail.
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
  
  /// Builds an expandable card (UI remains unchanged).
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
  
  /// Builds a recommendation item.
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

/// A bottom sheet that can be resized by dragging the image area.
/// 
/// This widget displays a bottom sheet with a pet image at the top that
/// can be dragged to adjust the height of the sheet.
class ImageDraggableBottomSheet extends StatefulWidget {
  final Widget child;
  final double initialHeight;
  final double minHeight;
  final double maxHeight;
  final BoxDecoration decoration;
  final BorderRadius borderRadius;
  final Map<String, dynamic> petData;
  final String petBreed;
  final VoidCallback? onPetDetailsUpdated;

  const ImageDraggableBottomSheet({
    Key? key,
    required this.child,
    required this.initialHeight,
    required this.minHeight,
    required this.maxHeight,
    required this.decoration,
    required this.borderRadius,
    required this.petData,
    required this.petBreed,
    this.onPetDetailsUpdated,
  }) : super(key: key);

  @override
  State<ImageDraggableBottomSheet> createState() => ImageDraggableBottomSheetState();
}

class ImageDraggableBottomSheetState extends State<ImageDraggableBottomSheet> with SingleTickerProviderStateMixin {
  late double _currentHeight;
  bool _isDragging = false;
  late AnimationController _snapController;
  late Animation<double> _snapAnimation;
  
  // Add fixed bottom limit constant
  final double _fixedBottomLimit = 500.0; // Adjust value as needed
  
  // Heights for magnetic snapping
  double? _snapToHeight;
  final List<double> _snapPoints = [];

  @override
  void initState() {
    super.initState();
    _currentHeight = widget.initialHeight;
    
    // Setup animation controller for smooth snapping
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _snapController.addListener(() {
      if (_snapToHeight != null) {
        setState(() {
          _currentHeight = _snapAnimation.value;
        });
      }
    });
    
    // Calculate snap points - these are positions where the sheet will "snap" to
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenHeight = MediaQuery.of(context).size.height;
      _snapPoints.addAll([
        screenHeight * 0.45, // Small peek
        screenHeight * 0.65, // Half view
        screenHeight * 0.85, // Full view
      ]);
    });
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  void setHeight(double newHeight) {
    setState(() {
      // Use fixed bottom limit instead of widget.minHeight
      _currentHeight = newHeight.clamp(_fixedBottomLimit, widget.maxHeight);
    });
  }
  
  void _snapToNearestPoint(double velocity) {
    // Find the nearest snap point that's above our fixed bottom limit
    double? nearestPoint;
    double minDistance = double.infinity;
    
    for (final point in _snapPoints) {
      // Only consider snap points above our fixed limit
      if (point >= _fixedBottomLimit) {
        final distance = (_currentHeight - point).abs();
        if (distance < minDistance) {
          minDistance = distance;
          nearestPoint = point;
        }
      }
    }
    
    // If there are no valid snap points, default to the fixed bottom limit
    nearestPoint ??= _fixedBottomLimit;
    
    // If the velocity is significant, snap in that direction
    if (velocity.abs() > 800 && nearestPoint != _fixedBottomLimit) {
      final direction = velocity < 0 ? 1 : -1;
      final currentIndex = _snapPoints.indexOf(nearestPoint);
      int targetIndex = (currentIndex + direction).clamp(0, _snapPoints.length - 1);
      
      // Ensure the target snap point is above our fixed limit
      while (targetIndex >= 0 && targetIndex < _snapPoints.length && 
             _snapPoints[targetIndex] < _fixedBottomLimit) {
        targetIndex += direction > 0 ? 1 : -1;
      }
      
      // If we found a valid target, use it
      if (targetIndex >= 0 && targetIndex < _snapPoints.length) {
        nearestPoint = _snapPoints[targetIndex];
      }
    }
    
    // Snap to the selected point if it differs from current height
    if (nearestPoint != null && (nearestPoint - _currentHeight).abs() > 10) {
      _snapToHeight = nearestPoint;
      
      // Create animation
      _snapAnimation = Tween<double>(
        begin: _currentHeight,
        end: _snapToHeight,
      ).animate(CurvedAnimation(
        parent: _snapController,
        curve: Curves.easeOutCubic,
      ));
      
      // Start animation
      _snapController.reset();
      _snapController.forward().then((_) {
        _snapToHeight = null;
      });
    }
  }

  // Add method to show edit dialog
  void _showEditDialog(BuildContext context) {
    // Controllers for the text fields
    final TextEditingController ageController = TextEditingController();
    final TextEditingController sizeController = TextEditingController();
    
    // Get current values from petData to prefill
    final List<dynamic> details = widget.petData['petDetails'] is List ? widget.petData['petDetails'] : [];
    final String currentAge = details.length > 1 ? (details[1]['value']?.toString() ?? "") : "";
    final String currentSize = details.length > 2 ? (details[2]['value']?.toString() ?? "") : "";
    
    // Set initial values
    ageController.text = currentAge;
    sizeController.text = currentSize;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Edit Pet Details",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF3D4A5C),
            ),
          ),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: ageController,
                  decoration: InputDecoration(
                    labelText: 'Age',
                    hintText: 'e.g. 2 yrs',
                    prefixIcon: Icon(Icons.cake, color: Colors.amber),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: const Color(0xFF52AAA4), width: 2),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                controller: sizeController,
                inputFormatters: [
                  FirstLetterUpperCaseTextFormatter(),
                  FilteringTextInputFormatter.deny(RegExp(r'[0-9]')),
                ],
                decoration: InputDecoration(
                  labelText: 'Size',
                  hintText: 'e.g. Medium',
                  prefixIcon: Icon(Icons.straighten, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: const Color(0xFF52AAA4), width: 2),
                  ),
                ),
              ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF52AAA4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                "Save",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () async {
                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: const Color(0xFF52AAA4),
                      ),
                    );
                  },
                );
                
                try {
                  // Update Firestore with new values
                  await _updatePetDetails(ageController.text, sizeController.text);
                  
                  // Close loading dialog
                  Navigator.of(context).pop();
                  
                  // Close edit dialog
                  Navigator.of(context).pop();
                  
                  // Show success snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Pet details updated successfully"),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  );
                  
                  // Notify parent about the update
                  if (widget.onPetDetailsUpdated != null) {
                    widget.onPetDetailsUpdated!();
                  }
                } catch (e) {
                  // Close loading dialog
                  Navigator.of(context).pop();
                  
                  // Show error snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error updating pet details: ${e.toString()}"),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    ).then((_) {
      // Dispose controllers when dialog is closed
      ageController.dispose();
      sizeController.dispose();
    });
  }

  // Add method to update Firestore
  Future<void> _updatePetDetails(String newAge, String newSize) async {
    try {
      // Get user ID
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception("User is not signed in.");
      }
      
      // Get document ID from petData
      final String documentId = widget.petData['id'] ?? "";
      if (documentId.isEmpty) {
        throw Exception("Document ID not found");
      }
      
      // Create a copy of the pet details
      List<dynamic> updatedDetails = [];
      if (widget.petData['petDetails'] is List) {
        updatedDetails = List.from(widget.petData['petDetails']);
        
        // Update age (index 1)
        if (updatedDetails.length > 1) {
          updatedDetails[1] = {
            ...updatedDetails[1] as Map<String, dynamic>,
            'value': newAge
          };
        }
        
        // Update size (index 2)
        if (updatedDetails.length > 2) {
          updatedDetails[2] = {
            ...updatedDetails[2] as Map<String, dynamic>,
            'value': newSize
          };
        }
      }
      
      // Update Firestore
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('History')
          .doc(documentId)
          .update({
            'petDetails': updatedDetails,
          });
      
      // Update local state to reflect changes
      setState(() {
        widget.petData['petDetails'] = updatedDetails;
      });
      
    } catch (e) {
      print("Error updating pet details: $e");
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: _isDragging ? 0 : 200),
      curve: Curves.easeInOut,
      height: _currentHeight,
      decoration: widget.decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Pet image section that acts as the draggable area
          GestureDetector(
            onVerticalDragStart: (details) {
              // Stop any running snap animation
              _snapController.stop();
              _snapToHeight = null;
              
              setState(() {
                _isDragging = true;
              });
            },
            onVerticalDragUpdate: (details) {
              // Calculate new height when dragging
              final newHeight = _currentHeight - details.delta.dy;
              
              // Apply the fixed bottom limit
              final limitedHeight = newHeight.clamp(_fixedBottomLimit, widget.maxHeight);
              
              setState(() {
                _currentHeight = limitedHeight;
              });
            },
            onVerticalDragEnd: (details) {
              setState(() {
                _isDragging = false;
              });
              
              // Snap to nearest point when user stops dragging
              _snapToNearestPoint(details.velocity.pixelsPerSecond.dy);
            },
            child: Stack(
              children: [
                Container(
                  height: 350.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: widget.borderRadius,
                    image: DecorationImage(
                      image: widget.petData['petImage'] != null &&
                              (widget.petData['petImage'] as String).startsWith("http")
                          ? NetworkImage(widget.petData['petImage'])
                          : AssetImage(widget.petData['petImage'] ?? "assets/sampleimage.jpg") as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Close button
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
                // Edit button
                Positioned(
                  top: 280.h,
                  right: 12.w,
                  child: GestureDetector(
                    onTap: () {
                      // Show edit dialog for age and size
                      _showEditDialog(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.sp),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 22.sp,
                      ),
                    ),
                  ),
                ),
                // Pet name and breed info at the bottom of the image
                Positioned(
                  bottom: 12.h,
                  left: 16.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.petData['petName'] ?? "Unknown",
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
                        widget.petBreed,
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
          ),
          // Content section
          Expanded(
            child: NotificationListener<ScrollNotification>(
              // Prevent scroll actions when dragging the modal
              onNotification: (notification) {
                if (_isDragging) {
                  return true; // Block scroll when dragging
                }
                return false; // Allow scroll normally
              },
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: widget.child,
              ),
            ),
          ),
        ],
      ),
    );
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

class FirstLetterUpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue; // Return empty value
    }
    
    // Capitalize the first letter and keep the rest as-is
    final text = newValue.text;
    final firstLetter = text[0].toUpperCase();
    final restOfText = text.substring(1);
    
    return newValue.copyWith(
      text: firstLetter + restOfText,
      selection: newValue.selection,
    );
  }
}



