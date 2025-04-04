// lib/petimage.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'assesment.dart';
import 'package:provider/provider.dart';
import 'userdata.dart';

class PetimageScreen extends StatefulWidget {
  const PetimageScreen({super.key});

  @override
  PetimageScreenState createState() => PetimageScreenState();
}

class PetimageScreenState extends State<PetimageScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  // This function picks an image and uploads it to Cloudinary.
  Future<void> _pickAndUploadImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      // Upload image to Cloudinary.
      String? uploadedUrl = await _uploadImageToCloudinary(pickedFile);
      if (uploadedUrl != null) {
        // Update the provider so that NewSummaryScreen can display the image.
        Provider.of<UserData>(context, listen: false).setPetImage(uploadedUrl);

        // Also update Firestore with the new profile image URL.
        final String? userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) {
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(userId)
              .update({'PetImage': uploadedUrl});
        }

        // Automatically navigate to the Assessment screen.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AssesmentScreen()),
        );
      }
    }
  }

  // Uploads the image using an unsigned preset "Petsymp" to your Cloudinary account.
  Future<String?> _uploadImageToCloudinary(XFile imageFile) async {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/dntn2fqjo/image/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = 'Petsymp'
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));
    final response = await request.send();
    final res = await http.Response.fromStream(response);
    if (response.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['secure_url'];
    } else {
      print('Upload failed: ${res.body}');
      return null;
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
                      : const Center(child: Text("")),
                ),
              ),
              SizedBox(height: 150.h),
              // Upload Button
              Center(
                child: ElevatedButton(
                  onPressed: _pickAndUploadImage,
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
