import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'assesment.dart';

class PetimageScreen extends StatefulWidget {
  const PetimageScreen({super.key});

  @override
  PetimageScreenState createState() => PetimageScreenState();
}

class PetimageScreenState extends State<PetimageScreen> {
  File? _image;
  final ImagePicker picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedImage =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });

      // Upload image to Firebase (No print statements)
      await _uploadImageToFirebase();
    }
  }

  Future<void> _uploadImageToFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not logged in!")),
        );
        return;
      }

      String fileName = "user_pets/${user.uid}.jpg"; // Unique pet image file
      Reference ref = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(_image!);

      TaskSnapshot snapshot = await uploadTask;
      String downloadURL = await snapshot.ref.getDownloadURL();

      // Store pet image URL in Firestore under the user's pet collection
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("pets")
          .doc("pet_image")
          .set({
        "imageUrl": downloadURL,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pet image uploaded successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload pet image: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F2F5),
      body: Stack(
        children: [
          // Background Image (Centered)
          Positioned(
            top: 94.h,
            left: 37.w,
            child: Image.asset(
              "assets/takingpicture.png",
              width: 0.8.sw, // Adjust width relative to screen
              height: 0.8.sh, // Adjust height relative to screen
              fit: BoxFit.contain, // Keep aspect ratio
            ),
          ),

          // Foreground UI
          Column(
            children: [
              SizedBox(height: 200.h), // Space from the top
              
              // Circular Image Container
              Container(
                height: 250.w,
                width: 250.w,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromRGBO(29, 29, 44, 1.0),
                    width: 7.w,
                  ),
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: _image != null
                      ? Image.file(
                          _image!,
                          fit: BoxFit.cover,
                        )
                      : const Center(child: Text("meow")),
                ),
              ),

              SizedBox(height: 150.h),

              // Upload Button
              Center(
                child: ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(66, 134, 130, 1.0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.r),
                    ),
                    fixedSize: Size(0.9.sw, 0.068.sh),
                  ),
                  child: Text(
                    "Upload Image",
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 15.h),

              // Skip Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AssesmentScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(66, 134, 130, 1.0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.r),
                    ),
                    fixedSize: Size(0.9.sw, 0.068.sh),
                  ),
                  child: Text(
                    "Skip",
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
