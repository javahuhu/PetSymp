import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class HistoryassesmentScreen extends StatefulWidget {
  const HistoryassesmentScreen({super.key});

  @override
  HistoryassesmentScreenState createState() => HistoryassesmentScreenState();
}

class HistoryassesmentScreenState extends State<HistoryassesmentScreen> {
  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA), // Lighter, more modern background
      body:  Column(
          children: [
            // Enhanced App Bar
            Container(
              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF52AAA4), Color(0xFF3D8F8A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.15),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  
                  Expanded(
                    child: Center(
                      child: Text(
                        "Pet Health History",
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                 
                ],
              ),
            ),
            
            // Simplified heading with swipe instruction
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFEDF7F7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF52AAA4).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.swipe_left_alt_rounded, 
                    color: const Color(0xFF52AAA4),
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      "Swipe left to delete a pet profile",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF52AAA4),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // History list
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  Text(
                    "History Records",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4A4A4A),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                   
                  ),
                ],
              ),
            ),
            
            // Enhanced history list
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(userId)
                  .collection('History')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return _buildErrorState();
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
                if (docs == null || docs.isEmpty) return _buildEmptyState();

                // Group by month
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

                return Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    physics: const BouncingScrollPhysics(),
                    itemCount: groupedRecords.length,
                    itemBuilder: (context, index) {
                      final monthYear = groupedRecords.keys.elementAt(index);
                      final monthDocs = groupedRecords[monthYear]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF52AAA4).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    monthYear,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF52AAA4),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: const Color(0xFF52AAA4).withOpacity(0.2),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Text(
                                  "${monthDocs.length} entries",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[600],
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
      
      // No floating action button
    );
  }

  Widget _buildHistoryCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final String petName = data['petName'] as String? ?? "Pet";
    final List<dynamic> petDetails = data['petDetails'] is List ? data['petDetails'] : [];


    final String petType = petDetails.length > 0 && petDetails[0]['value'] != null
        ? petDetails[0]['value'].toString()
        : "Unknown";


    final String age = petDetails.length > 2 && petDetails[2]['value'] != null
        ? petDetails[2]['value'].toString()
        : "Unknown";

      final String size = petDetails.length > 3 && petDetails[3]['value'] != null
        ? petDetails[3]['value'] as String
        : "Medium";

      final String breed = petDetails.length > 4 && petDetails[4]['value'] != null
        ? petDetails[4]['value'] as String
        : "Unknown";

    String accountCreated = "";
    String formattedTime = "";
    if (data['date'] != null) {
      final timestamp = data['date'] as Timestamp;
      final date = timestamp.toDate();
      accountCreated = DateFormat('MMM d, yyyy').format(date);
      formattedTime = DateFormat('h:mm a').format(date);
    }

    final String petImage = data['petImage'] as String? ?? "";

    // For swipe-to-delete functionality
    return Dismissible(
      key: Key(doc.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        // Show confirmation dialog
        bool? result = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                "Delete Pet Profile",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4A4A4A),
                ),
              ),
              content: Text(
                "Are you sure you want to delete $petName's profile?",
                style: TextStyle(
                  color: Colors.grey[700],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red[700],
                  ),
                  child: const Text("Delete"),
                ),
              ],
            );
          },
        );
        
        // If user confirmed, delete from Firestore
        if (result == true) {
          try {
            final String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
            // Delete the pet profile from Firebase
            await FirebaseFirestore.instance
                .collection('Users')
                .doc(userId)
                .collection('History')
                .doc(doc.id)
                .delete();
                
            // You may want to show a success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("$petName's profile has been deleted"),
                backgroundColor: Colors.green[700],
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                margin: EdgeInsets.all(16),
              ),
            );
            
            return true;
          } catch (e) {
            // Handle error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Error deleting profile: ${e.toString()}"),
                backgroundColor: Colors.red[700],
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                margin: EdgeInsets.all(16),
              ),
            );
            return false;
          }
        }
        
        return result ?? false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        margin: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete_forever_rounded,
              color: Colors.white,
              size: 26.sp,
            ),
            SizedBox(height: 4.h),
            Text(
              "Delete",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              // Simple tap action if needed
            },
          child: Column(
            children: [
              // Enhanced header with gradient
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: const BoxDecoration(
                  gradient:  LinearGradient(
                    colors: [Color(0xFF52AAA4), Color(0xFF489E98)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Hero(
                      tag: "pet_${doc.id}",
                      child: Container(
                        width: 60.w,
                        height: 60.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          backgroundImage: petImage.isNotEmpty && petImage.startsWith("http")
                              ? NetworkImage(petImage)
                              : const AssetImage("assets/noimagepet.jpg") as ImageProvider,
                          backgroundColor: Colors.grey[300],
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
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
                          Row(
                            children: [
                              const Icon(
                                Icons.pets_rounded,
                                color: Colors.white70,
                                size: 14,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                petType,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 13.sp,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            accountCreated,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          formattedTime,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Simplified pet details section
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDetailItem(Icons.cake_rounded, "Age", age),
                    _buildDetailItem(Icons.straighten_rounded, "Size", size),
                    _buildDetailItem(Icons.pets_rounded, "Breed", breed.isNotEmpty ? breed : "Unknown"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
   ));
  }
  
  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: const Color(0xFF52AAA4).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFF52AAA4),
              size: 20.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF333333),
            ),
            softWrap: true, 
            overflow: TextOverflow.ellipsis,  
            maxLines: 1, 
          ),
        ],
      ),
    );
  }
  
  // Removed _buildActionButton method as it's no longer needed

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: const Color(0xFF52AAA4).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.pets_rounded,
                size: 80.sp,
                color: const Color(0xFF52AAA4),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              "No Health Records Yet",
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4A4A4A),
              ),
            ),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Text(
                "Track your pet's health journey by adding their first health record",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                ),
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
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 80.sp,
                color: Colors.red[400],
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              "Oops! Something went wrong",
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4A4A4A),
              ),
            ),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Text(
                "We're having trouble loading your pet's health records",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                ),
              ),
            ),
            SizedBox(height: 32.h),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF52AAA4),
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("Try Again"),
            ),
          ],
        ),
      ),
    );
  }
}