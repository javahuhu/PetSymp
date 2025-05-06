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
import '../userdata.dart';
import 'package:animate_do/animate_do.dart';

class PetimageScreen extends StatefulWidget {
  const PetimageScreen({super.key});

  @override
  PetimageScreenState createState() => PetimageScreenState();
}

class PetimageScreenState extends State<PetimageScreen> {
  bool _isAnimated = false;
  File? _image;
  final ImagePicker _picker = ImagePicker();

  // New variables for loading overlay control.
  bool _isLoading = false;
  double _loadingOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    // Trigger the animation after the widget builds.
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimated = true;
      });
    });
  }

  // Function to show a bottom sheet for selecting the image source.
  Future<ImageSource?> _showImageSourceSelection() async {
    return await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.of(context).pop(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // This function picks an image using the chosen source and uploads it.
  Future<void> _pickAndUploadImage() async {
    // Show bottom sheet for image source selection.
    final ImageSource? source = await _showImageSourceSelection();
    if (source == null) return; // User cancelled the selection.

    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        // Start showing the loading overlay.
        _isLoading = true;
        _loadingOpacity = 1.0;
      });
      // Upload image to Cloudinary.
      String? uploadedUrl = await _uploadImageToCloudinary(pickedFile);
      if (uploadedUrl != null) {
        // Update provider so that the next screen can display the image.
        Provider.of<UserData>(context, listen: false).setPetImage(uploadedUrl);

        // Update Firestore with the new pet image URL.
        final String? userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) {
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(userId)
              .update({'PetImage': uploadedUrl});
        }

        // Fade out the loading overlay.
        setState(() {
          _loadingOpacity = 0.0;
        });
        // Wait for the fade-out animation to complete.
        await Future.delayed(const Duration(milliseconds: 500));

        // Navigate to the Assessment screen.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AssesmentScreen()),
        );
      } else {
        // In case of upload failure, hide the loading overlay.
        setState(() {
          _isLoading = false;
          _loadingOpacity = 0.0;
        });
      }
    }
  }

  // Uploads the image using an unsigned preset "Petsymp" to your Cloudinary account.
  Future<String?> _uploadImageToCloudinary(XFile imageFile) async {
    final url =
        Uri.parse('https://api.cloudinary.com/v1_1/dntn2fqjo/image/upload');
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
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            // Gradient background.
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(225, 240, 243, 1.0),
                  Color.fromRGBO(201, 229, 231, 1.0),
                  Color(0xFFE8F2F5),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Bubble decorations.
                Positioned(
                  top: -screenHeight * 0.05,
                  right: -screenWidth * 0.15,
                  child: Container(
                    width: screenWidth * 0.5,
                    height: screenWidth * 0.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromRGBO(66, 134, 129, 0.1),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -screenHeight * 0.05,
                  left: -screenWidth * 0.15,
                  child: Container(
                    width: screenWidth * 0.4,
                    height: screenWidth * 0.4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromRGBO(66, 134, 129, 0.1),
                    ),
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.12,
                  left: screenWidth * 0.08,
                  child: Container(
                    width: screenWidth * 0.12,
                    height: screenWidth * 0.12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color.fromRGBO(66, 134, 129, 0.6),
                        width: 2,
                      ),
                      color: Colors.transparent,
                    ),
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.4,
                  right: -screenWidth * 0.1,
                  child: Container(
                    width: screenWidth * 0.3,
                    height: screenWidth * 0.3,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromRGBO(66, 134, 129, 0.1),
                      border: Border.all(
                        color: Color.fromRGBO(66, 134, 129, 0.3),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: screenHeight * 0.15,
                  right: screenWidth * 0.3,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromRGBO(72, 38, 163, 0.4),
                    ),
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.6,
                  left: screenWidth * 0.15,
                  child: Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromRGBO(72, 38, 163, 0.3),
                    ),
                  ),
                ),
                // Animated title text.
                AnimatedPositioned(
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  top: _isAnimated ? screenHeight * 0.13 : -200,
                  left: screenWidth * 0.05,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: screenWidth,
                        height: screenWidth * 0.15,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          "Upload Pet Image",
                          style: TextStyle(
                            fontFamily: 'Oswald',
                            fontSize: 35.sp,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.05),
                    ],
                  ),
                ),
                // Animated image asset.
               Positioned(
               top: 94.h,
               left: 37.w,
               child: SlideInLeft(
                 duration:const Duration(milliseconds: 1000),
                 delay: const Duration(milliseconds: 300),
                 from: 100,
                 child: Image.asset(
                   "assets/takingpicture.png",
                   width: 0.8.sw, // Adjust width relative to screen
                   height: 0.8.sh, // Adjust height relative to screen
                   fit: BoxFit.contain, // Keep aspect ratio
                 ),
               )
             ),
             

                // Foreground UI elements.
                Column(
                  children: [
                    SizedBox(height: 200.h),
                    // Circular image container.
                    Container(
                      height: 250.w,
                      width: 250.w,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromRGBO(29, 29, 44, 1.0),
                          width: 13.w,
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
                    // Upload Button.
                    Center(
                      child: SlideInUp(
                        duration: const Duration(milliseconds: 1000),
                        delay: const Duration(milliseconds: 300),
                        from: 100,
                        child: ElevatedButton(
                          onPressed: _pickAndUploadImage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(66, 134, 130, 1.0),
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
                    ),
                    SizedBox(height: 15.h),
                    // Skip Button.
                    Center(
                      child: SlideInUp(
                        duration: const Duration(milliseconds: 1000),
                        delay: const Duration(milliseconds: 600),
                        from: 200,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AssesmentScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(66, 134, 130, 1.0),
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
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Loading overlay.
          if (_isLoading)
            AnimatedOpacity(
              opacity: _loadingOpacity,
              duration: const Duration(milliseconds: 500),
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
