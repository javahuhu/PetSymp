import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(0.w),
            child: Column(
              children: [
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_sharp,
                        size: 30.sp,
                        color: const Color.fromARGB(255, 0, 0, 0),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    SizedBox(width: 107.w),
                    Text(
                      "History",
                      style: TextStyle(
                        fontSize: 25.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Oswald',
                        color: const Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 70.h),
                // Retrieve History Records via StreamBuilder:
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Users')
                      .doc(userId)
                      .collection('History')
                      .orderBy('date', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(
                          height: 200.h,
                          child: Center(child: CircularProgressIndicator()));
                    }
                    final docs = snapshot.data?.docs;
                    if (docs == null || docs.isEmpty) {
                      return Text("No history records found");
                    }
                    // Build a list of cards from the history documents.
                    return Column(
                      children: docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final String docId = doc.id;
                        // Get the petName directly from the history record.
                        final String petName =
                            data['petName'] as String? ?? "Pet";
                        // Get petDetails list (as saved in NewSummaryScreen).
                        final petDetails =
                            data['petDetails'] as List<dynamic>? ?? [];
                        // For breed and symptoms, we still rely on petDetails.
                        final String breed = (petDetails.length > 2 &&
                                petDetails[2]['value'] != null)
                            ? petDetails[2]['value'] as String
                            : "";
                        final String symptoms = (petDetails.length > 3 &&
                                petDetails[3]['value'] != null)
                            ? petDetails[3]['value'] as String
                            : "";
                        // Retrieve diagnosisResults from history.
                        final diagnoses =
                            data['diagnosisResults'] as List<dynamic>? ?? [];
                        String illness = "";
                        double confidence = 0.0;
                        if (diagnoses.isNotEmpty) {
                          final first = diagnoses[0] as Map<String, dynamic>;
                          illness = first['illness'] ?? "";
                          confidence =
                              (first['confidence_ab'] as num?)?.toDouble() ?? 0.0;
                        }
                        // Retrieve the dynamic pet image from the history record.
                        final String petImage =
                            data['petImage'] as String? ?? "";
                        return _buildInputCard(
                          docId,
                          petImage,
                          petName, // dynamic pet name from history
                          breed,
                          "Symptoms: $symptoms",
                          "Illness: $illness",
                          "Confidence: ${confidence.toStringAsFixed(1)}%",
                        );
                      }).toList(),
                    );
                  },
                ),
                SizedBox(height: 10.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Modified _buildInputCard now accepts a docId and dynamic petImage URL and pet name.
  Widget _buildInputCard(String docId, String petImage, String petName, String breed, String symptoms, String illness, String confidence) {
    return Card(
      elevation: 0,
      color: Colors.transparent,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color.fromARGB(255, 0, 0, 0), width: 1),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 70.w,
                    height: 70.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color.fromARGB(255, 95, 94, 94),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      // Use NetworkImage if petImage is non-empty and starts with "http", else use default asset.
                      backgroundImage: petImage.isNotEmpty && petImage.startsWith("http")
                          ? NetworkImage(petImage)
                          : const AssetImage("assets/goldenpet.png") as ImageProvider,
                      backgroundColor: Colors.grey,
                    ),
                  ),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: Row(
                      children: [
                        // Pet name as the first Expanded widget.
                        Expanded(
                          flex: 1,
                          child: Text(
                            petName,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Oswald',
                            ),
                          ),
                        ),
                        // Divider
                        Container(
                          height: 25.h,
                          width: 1.5,
                          color: Colors.black,
                          margin: EdgeInsets.symmetric(horizontal: 10.w),
                        ),
                        // Breed
                        Expanded(
                          flex: 2,
                          child: Text(
                            breed,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        // Trash IconButton (to delete the history record)
                        // ... Inside your _buildInputCard method:
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red, size: 20.sp),
                          onPressed: () async {
                            final bool? confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Confirm Deletion"),
                                content: const Text("Are you sure you want to delete this record?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text("Delete"),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              final String? userId = FirebaseAuth.instance.currentUser?.uid;
                              if (userId != null) {
                                await FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(userId)
                                    .collection('History')
                                    .doc(docId)
                                    .delete();
                              }
                            }
                          },
                        ),

                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 30.h, right: 100.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      symptoms,
                      style: TextStyle(fontFamily: 'Inter', fontSize: 13.sp),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      illness,
                      style: TextStyle(fontFamily: 'Inter', fontSize: 13.sp),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      confidence,
                      style: TextStyle(fontFamily: 'Inter', fontSize: 13.sp),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.h),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                  ).copyWith(
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                  child: Text(
                    "View Report",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 70, 120, 117),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
