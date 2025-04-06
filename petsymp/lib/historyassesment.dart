import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:petsymp/viewHistory.dart';

class HistoryassesmentScreen extends StatefulWidget {
  const HistoryassesmentScreen({super.key});

  @override
  HistoryassesmentScreenState createState() => HistoryassesmentScreenState();
}

class HistoryassesmentScreenState extends State<HistoryassesmentScreen> {
  // This static map is still here, but the dynamic pet image and name come from Firestore.
  final Map<String, Map<String, String>> profilelist = {
    "img1": {
      "profile": "assets/profile.jpg",
      "image": "assets/security.png",
    },
    "img2": {
      "image": "assets/support.png",
    },
    "img3": {
      "image": "assets/condition.png",
    },
    "img4": {
      "image": "assets/editprofile.png",
    },
    "img5": {
      "image": "assets/restore.png",
    },
  };

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 219, 230, 233),
      body: 
         Column(
          children: [
            // Fixed App Bar that stays at the top
            Container(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              decoration: const BoxDecoration(
                color: Color(0xFF52AAA4),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  
                  Expanded(
                    child: Padding( padding: EdgeInsets.only(left: 94.w),
                      child: Text(
                        "Pet Health History",
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  // Balance the layout with an invisible icon
                 const IconButton(
                    icon: Icon(
                      Icons.search,
                      color: Colors.transparent,
                    ),
                    onPressed: null,
                  ),
                ],
              ),
            ),
            
            // Empty State Widget
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(userId)
                  .collection('History')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _buildErrorState();
                }
                
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF52AAA4),
                      ),
                    ),
                  );
                }
                
                final docs = snapshot.data?.docs;
                if (docs == null || docs.isEmpty) {
                  return _buildEmptyState();
                }
                
                // Group records by month
                Map<String, List<QueryDocumentSnapshot>> groupedRecords = {};
                for (var doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final timestamp = data['date'] as Timestamp?;
                  
                  if (timestamp != null) {
                    final date = timestamp.toDate();
                    final monthYear = DateFormat('MMMM yyyy').format(date);
                    
                    if (!groupedRecords.containsKey(monthYear)) {
                      groupedRecords[monthYear] = [];
                    }
                    
                    groupedRecords[monthYear]!.add(doc);
                  }
                }
                
                // Build grouped records list
                return Expanded(
                  child: groupedRecords.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                          itemCount: groupedRecords.length,
                          itemBuilder: (context, index) {
                            final monthYear = groupedRecords.keys.elementAt(index);
                            final monthDocs = groupedRecords[monthYear]!;
                            
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  child: Row(
                                    children: [
                                      Text(
                                        monthYear,
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF52AAA4),
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: Container(
                                          height: 1.5,
                                          color: const Color(0xFF52AAA4).withOpacity(0.3),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ...monthDocs.map((doc) => _buildHistoryCard(doc)).toList(),
                              ],
                            );
                          },
                        ),
                );
              },
            ),
          ],
        ),
      
    );
  }

  Widget _buildHistoryCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final String docId = doc.id;
    
    // Get date formatted
    String formattedDate = "";
    if (data['date'] != null) {
      final timestamp = data['date'] as Timestamp;
      final date = timestamp.toDate();
      formattedDate = DateFormat('MMM d, yyyy').format(date);
    }
    
    // Get the petName directly from the history record
    final String petName = data['petName'] as String? ?? "Pet";
    
    // Get petDetails list
    final petDetails = data['petDetails'] as List<dynamic>? ?? [];
    
    // For breed and symptoms, we still rely on petDetails
    final String breed = (petDetails.length > 2 && petDetails[2]['value'] != null)
        ? petDetails[2]['value'] as String
        : "";
    final String symptoms = (petDetails.length > 3 && petDetails[3]['value'] != null)
        ? petDetails[3]['value'] as String
        : "";
    
    // Retrieve diagnosisResults from history
    final diagnoses = data['diagnosisResults'] as List<dynamic>? ?? [];
    String illness = "";
    double confidence = 0.0;
    if (diagnoses.isNotEmpty) {
      final first = diagnoses[0] as Map<String, dynamic>;
      illness = first['illness'] ?? "";
      confidence = (first['confidence_ab'] as num?)?.toDouble() ?? 0.0;
    }
    
    // Retrieve the dynamic pet image from the history record
    final String petImage = data['petImage'] as String? ?? "";

    return Dismissible(
      key: Key(docId),
      background: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      secondaryBackground: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "Delete",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(width: 8.w),
            const Icon(
              Icons.delete_outline,
              color: Colors.white,
            ),
          ],
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Text("Confirm Deletion"),
            content: const Text("Are you sure you want to delete this record?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Color(0xFF52AAA4)),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) async {
        final String? userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) {
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(userId)
              .collection('History')
              .doc(docId)
              .delete();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Record deleted"),
              backgroundColor: const Color(0xFF52AAA4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              action: SnackBarAction(
                label: "UNDO",
                textColor: Colors.white,
                onPressed: () {
                  // Implement undo functionality if needed
                },
              ),
            ),
          );
        }
      },
      child: Card(
        elevation: 5,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        color: const Color.fromARGB(255, 236, 236, 236),
        margin: EdgeInsets.only(bottom: 16.h),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Column(
            children: [
              // Card Header
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: const BoxDecoration(
                  color: Color(0xFF52AAA4),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 55.w,
                      height: 55.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        backgroundImage: petImage.isNotEmpty && petImage.startsWith("http")
                            ? NetworkImage(petImage)
                            : const AssetImage("assets/goldenpet.png") as ImageProvider,
                        backgroundColor: Colors.grey[300],
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            petName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            breed,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formattedDate,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "${confidence.toStringAsFixed(1)}%",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Symptoms section - now directly below the header to match the image
              Padding(
                padding: EdgeInsets.only(top: 12.w, left: 16.w, right: 16.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF52AAA4).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.medical_services_outlined,
                        color: Color(0xFF52AAA4),
                        size: 15,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Symptoms",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF52AAA4),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          symptoms,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Card Content - remaining content
              Container(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Diagnosis section - moved below symptoms
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFF52AAA4).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.medical_information_outlined,
                            color: Color(0xFF52AAA4),
                            size: 16,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Diagnosis",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF52AAA4),
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                illness.isEmpty ? "No diagnosis available" : illness,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // View Report Button
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ViewhistoryScreen()),
                        );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: const Color.fromARGB(255, 131, 81, 185),
                            backgroundColor: Colors.transparent, // Transparent background
                            shadowColor: Colors.transparent, // No shadow color
                            surfaceTintColor: Colors.transparent, // (for Material 3)
                            padding: EdgeInsets.zero, 
                        ),
                        
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                           
                            SizedBox(width: 8.w),
                            const Text("Report"),
                          ],
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
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              "No History Records",
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Your pet health records will appear here",
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80.sp,
              color: Colors.red[300],
            ),
            SizedBox(height: 16.h),
            Text(
              "Something went wrong",
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Please try again later",
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () {
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF52AAA4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 12.h,
                ),
              ),
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}