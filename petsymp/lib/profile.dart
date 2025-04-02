import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  ProfilescreenState createState() => ProfilescreenState();
}

class ProfilescreenState extends State<Profilescreen> {
  String nickname = "Loading...";
  String email = "Loading...";

  @override
  void initState() {
    super.initState();
    fetchUserNickname();
  }

  Future<void> fetchUserNickname() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String userId = user.uid; // ✅ Use Firebase Auth UID as the document ID

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(userId) // ✅ Fetch by UID (document ID)
            .get();

        if (userDoc.exists) {
          setState(() {
            nickname = userDoc.get('Username') ?? "No Username";
            email = userDoc.get('Email') ?? "No Email";
          });
        } else {
          setState(() {
            nickname = "User Not Found";
            email = "Email Not Found";
          });
        }
      } else {
        setState(() {
          nickname = "Not Logged In";
          email = "Not Logged In";
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    }
  }

  final Map<String, Map<String, String>> profilelist = {
    "img1": {
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
    "img6": {
      "image": "assets/logout.png",
    }
  };

  @override
  Widget build(BuildContext context) {
    // Screen dimensions
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(29, 29, 44, 1.0),
      body: Stack(
        children: [
          Positioned(
            top: screenHeight * 0.001, // 20% from the top of the screen
            left: screenWidth * 0.001, // 10% from the left of the screen
            child: Column(
              children: [
                Row(
                  children: [
                    // Circular Image
                    Container(
                      width: screenWidth * 1, // 15% of screen width
                      height:
                          screenWidth * 0.5, // Equal height for circular image
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 219, 230, 233),
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(200),
                              bottomLeft: Radius.circular(200))),

                      child: Stack(
                        fit: StackFit.expand,
                        clipBehavior: Clip
                            .none, // ✅ Use this instead of 'overflow: Overflow.visible'
                        children: <Widget>[
                          // 🐾 Paw Image Inside Yellow Background

                          // 📌 "Summary of Input" Title Inside Yellow Background
                          Positioned(
                            top: 100.h,
                            left: (screenWidth - 150.w) /
                                2, // centers horizontally
                            child: Container(
                              width: 150.w,
                              height: 150.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color.fromARGB(255, 95, 94, 94),
                                  width: 3,
                                ),
                              ),
                              child: const CircleAvatar(
                                backgroundImage:
                                    AssetImage('assets/profile.jpg'),
                                backgroundColor: Colors.grey,
                              ),
                            ),
                          ),

                          Positioned(
                            top: 240.h,
                            left: 0.04.w,
                            child: Container(
                              width: 510.w,
                              height: screenHeight * 0.6,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(
                                    0, 255, 255, 255), // Set Background Color
                                borderRadius: BorderRadius.circular(
                                    25), // Optional rounded corners
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(
                                    0), // Add padding inside container
                                child: ListView(
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: [
                                    _buildInputCard("img1", nickname),
                                    _buildInputCard("img2", email),
                                    _buildInputCard("img3", "Title"),
                                    _buildInputCard("img4", "Title"),
                                    _buildInputCard("img5", "Title"),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            top: 670.h,
                            left: 114.w,
                            child: Container(
                                width: 150.w,
                                height: 50.h,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(
                                      0, 255, 255, 255), // Set Background Color
                                  borderRadius: BorderRadius.circular(
                                      25), // Optional rounded corners
                                ),
                                child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromRGBO(
                                            82, 170, 164, 1),
                                        foregroundColor: const Color.fromARGB(
                                            255, 255, 255, 255)),
                                    child: Text(
                                      "Edit Profile",
                                      style: TextStyle(fontSize: 18.sp),
                                    ))),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard(String index, String fallbackTitle) {
    final profile = profilelist[index];

    if (profile == null) {
      return const SizedBox(); // Return empty if profile doesn't exist
    }

    return Card(
        elevation: 0,
        color: Colors.transparent,
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        child: Container(
          decoration: BoxDecoration(
              border:
                  Border(bottom: BorderSide(color: Colors.white, width: 1.w))),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                SizedBox(width: 10.w),
                Image.asset(
                  profile["image"] ?? "",
                  width: 30.w,
                  height: 30.h,
                  fit: BoxFit.contain,
                  color: const Color.fromRGBO(82, 170, 164, 1),
                ),
                SizedBox(width: 70.w), // spacing between image and text
                Text(
                  profile["Title"] ?? fallbackTitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
