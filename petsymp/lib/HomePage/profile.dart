import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

// Custom text formatter to capitalize the first letter
class FirstLetterUpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    
    return TextEditingValue(
      text: newValue.text.substring(0, 1).toUpperCase() + 
            newValue.text.substring(1),
      selection: newValue.selection,
    );
  }
}

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  ProfilescreenState createState() => ProfilescreenState();
}

class ProfilescreenState extends State<Profilescreen> {
  String nickname = "Loading...";
  String email = "Loading...";
  String profileImageUrl = "assets/noprofile.jpg";
  bool isAssetImage = true;
  
  // Controllers for editing
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  // Additional controllers for the other fields
  final TextEditingController _petName = TextEditingController();
  final TextEditingController _titleController2 = TextEditingController(text: "Support");
  final TextEditingController _titleController3 = TextEditingController(text: "Terms & Conditions");
  
  // Loading state
  bool _isLoading = false;
  
  // Edit mode
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }
  
  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _petName.dispose();
    _titleController2.dispose();
    _titleController3.dispose();
    super.dispose();
  }

  Future<void> fetchUserData() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userId = user.uid;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data() as Map<String, dynamic>;

        setState(() {
          nickname = data['Username'] ?? "No Username";
          email = data['Email'] ?? "No Email";
          _petName.text = data['Pet Name'] ?? "No Pet";

          // Check if profile image URL exists from Cloudinary
          if (data.containsKey('ProfileImageUrl') &&
              (data['ProfileImageUrl'] as String).isNotEmpty) {
            profileImageUrl = data['ProfileImageUrl'];
            isAssetImage = false;
            print("Loaded profile image from Cloudinary: $profileImageUrl");
          } else {
            // Use default image if no Cloudinary URL exists
            profileImageUrl = "assets/noprofile.jpg";
            isAssetImage = true;
          }

          // Set the controllers with current values
          _nicknameController.text = nickname;
          _emailController.text = email;
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

  
  Future<void> _pickAndUploadImage() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final ImagePicker picker = ImagePicker();
      // Show dialog to select from gallery or camera
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            title: const Text('Choose Image Source'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF52AAA4),
                    child: Icon(Icons.photo_library, color: Colors.white),
                  ),
                  title: const Text('Gallery'),
                  onTap: () {
                    Navigator.of(context).pop(ImageSource.gallery);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF52AAA4),
                    child: Icon(Icons.camera_alt, color: Colors.white),
                  ),
                  title: const Text('Camera'),
                  onTap: () {
                    Navigator.of(context).pop(ImageSource.camera);
                  },
                ),
              ],
            ),
          );
        },
      );
      
      if (source == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      final XFile? image = await picker.pickImage(source: source);
      
      if (image == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      // Upload to Cloudinary
      String cloudinaryUrl = await _uploadToCloudinary(File(image.path));
      
      // Update Firestore with the new image URL
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .update({
            'ProfileImageUrl': cloudinaryUrl,
            'Pet Name': _petName.text.trim(),
        });
        
        setState(() {
          profileImageUrl = cloudinaryUrl;
          isAssetImage = false;
          _isLoading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 10.w),
                  const Text("Profile image updated successfully"),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 10),
                Text("Error: ${e.toString()}"),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red[100],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
  
  Future<String> _uploadToCloudinary(File imageFile) async {
    // Set your Cloudinary credentials
    String cloudName = 'dntn2fqjo';  // Replace with your actual cloud name
    String uploadPreset = 'ProfileImage';  // Replace with your upload preset
    String apiUrl = 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';
    
    try {
      // Create a unique file name using timestamp and user ID
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
      String uniqueFileName = 'profile_${userId}_$timestamp';
      
      Dio dio = Dio();
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imageFile.path),
        'upload_preset': uploadPreset,
        'public_id': uniqueFileName,  // Give image a unique name
        'folder': 'user_profiles',    // Store in a dedicated folder
      });
      
      // Show progress in console
      print('Uploading image to Cloudinary...');
      
      final response = await dio.post(
        apiUrl,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
        onSendProgress: (int sent, int total) {
          print('Upload progress: ${(sent / total * 100).toStringAsFixed(2)}%');
        },
      );
      
      if (response.statusCode == 200) {
        print('Image successfully uploaded to Cloudinary');
        print('Image URL: ${response.data['secure_url']}');
        return response.data['secure_url'];
      } else {
        print('Failed to upload image. Status code: ${response.statusCode}');
        throw Exception('Failed to upload image to Cloudinary');
      }
    } catch (e) {
      print('Error uploading to Cloudinary: $e');
      throw Exception('Error uploading to Cloudinary: $e');
    }
  }
  
  // Toggle edit mode
  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      
      if (_isEditMode) {
        // Update controllers with current values when entering edit mode
        _nicknameController.text = nickname;
        _emailController.text = email;
        
        // Ensure first letter capitalization when entering edit mode
        if (_nicknameController.text.isNotEmpty) {
          _nicknameController.text = _nicknameController.text[0].toUpperCase() + 
                                    _nicknameController.text.substring(1);
        }
      } else {
        // Reset controllers to current values when exiting edit mode without saving
        _nicknameController.text = nickname;
        _emailController.text = email;
      }
    });
  }
  
  // Cancel editing and return to view mode
  void _cancelEdit() {
    setState(() {
      _isEditMode = false;
      // Reset controllers to current values
      _nicknameController.text = nickname;
      _emailController.text = email;
    });
  }
  
  Future<void> _showSaveConfirmation() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // Allow dismiss by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: const Text('Save Changes'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to save these changes?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
                // Don't exit edit mode, stay in edit mode
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF52AAA4),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _updateUserProfile();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
  
  Future<void> _updateUserProfile() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Ensure username has first letter capitalized before saving
        String formattedUsername = _nicknameController.text;
        if (formattedUsername.isNotEmpty) {
          formattedUsername = formattedUsername[0].toUpperCase() + formattedUsername.substring(1);
          _nicknameController.text = formattedUsername;
        }
        
        // Update Firestore
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .update({
          'Username': formattedUsername,
          'Email': _emailController.text,
          'Pet Name': _petName.text.trim(),
        });
        
        // Update Firebase Auth email if changed
        if (user.email != _emailController.text) {
          try {
            await user.updateEmail(_emailController.text);
          } catch (e) {
            print("Error updating email in Auth: $e");
            // Continue with profile update even if email update fails
          }
        }
        
        setState(() {
          nickname = formattedUsername;
          email = _emailController.text;
          _isLoading = false;
          _isEditMode = false; // Exit edit mode after saving
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 10.w),
                  const Text("Profile updated successfully"),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 10),
                Text("Error updating profile: ${e.toString()}"),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red[100],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Beautiful gradient header
            Container(
              height: screenWidth * 0.6,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF52AAA4),
                    Color.fromARGB(255, 219, 230, 233),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.2),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Design elements (decorative circles)
                  Positioned(
                    top: -30,
                    right: -30,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -20,
                    left: -20,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  
                  // Title
                  Positioned(
                    top: 60.h,
                    child: Text(
                      "Profile",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Profile Image - Positioned at the bottom edge of the header
                  Positioned(
                    bottom: -60.h,
                    child: GestureDetector(
                      onTap: _pickAndUploadImage,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Hero(
                              tag: 'profileImage',
                              child: Container(
                                width: 120.w,
                                height: 120.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                ),
                                child: _isLoading
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF52AAA4)),
                                        ),
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(60.w),
                                        child: Image(
                                          image: isAssetImage
                                              ? AssetImage(profileImageUrl)
                                              : NetworkImage(profileImageUrl) as ImageProvider,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            print('Error loading profile image: $error');
                                            return Icon(
                                              Icons.person,
                                              size: 60.w,
                                              color: const Color(0xFF52AAA4),
                                            );
                                          },
                                        ),
                                      ),
                              ),
                            ),
                            
                            // Camera icon
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF52AAA4),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Space for profile image overlap
            SizedBox(height: 70.h),
            
            // User name with nice styling
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  Text(
                    nickname,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    email,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
            ),
            
            // Divider with space
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 40.w),
              child: const Divider(color: Color.fromRGBO(82, 170, 164, 0.3)),
            ),
            
            // Profile fields in a card for better organization
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(40, 40, 60, 0.5),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: Column(
                  children: [
                    _buildProfileField("img1", "Username", _nicknameController, editable: true),
                    _buildProfileField("img2", "Email", _emailController, editable: true),
                    _buildProfileField("img3", "Pet Name", _petName, editable: true),
                    
                  ],
                ),
              ),
            ),
            
            // Action buttons with better styling
            SizedBox(height: 30.h),
            _isEditMode 
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Cancel button
                      Expanded(
                        child: Container(
                          height: 55.h,
                          margin: EdgeInsets.only(right: 8.w),
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.close),
                            label: Text(
                              "Cancel",
                              style: TextStyle(fontSize: 16.sp),
                            ),
                            onPressed: _cancelEdit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[800],
                              foregroundColor: Colors.white,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Save button
                      Expanded(
                        child: Container(
                          height: 55.h,
                          margin: EdgeInsets.only(left: 8.w),
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.check),
                            label: Text(
                              "Save",
                              style: TextStyle(fontSize: 16.sp),
                            ),
                            onPressed: _showSaveConfirmation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF52AAA4),
                              foregroundColor: Colors.white,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  width: screenWidth - 40.w,
                  height: 55.h,
                  margin: EdgeInsets.symmetric(horizontal: 20.w),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: Text(
                      "Edit Profile",
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    onPressed: _toggleEditMode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF52AAA4),
                      foregroundColor: Colors.white,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                
            // Bottom padding for better scroll experience
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(String index, String label, TextEditingController controller, {required bool editable}) {
    final profile = profilelist[index];
    if (profile == null) {
      return const SizedBox();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
      child: Column(
        children: [
          Row(
            children: [
              // Icon in a circle
              Container(
                width: 40.w,
                height: 40.w,
                decoration:const BoxDecoration(
                  color: Color.fromRGBO(82, 170, 164, 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    profile["image"] ?? "",
                    width: 22.w,
                    height: 22.w,
                    fit: BoxFit.contain,
                    color: const Color(0xFF52AAA4),
                  ),
                ),
              ),
              SizedBox(width: 15.w),
              
              // Label and text field
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    (_isEditMode && editable)
                      ? TextField(
                          controller: controller,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                          ),
                          // Apply the FirstLetterUpperCaseTextFormatter only for username field
                          inputFormatters: label == "Username" 
                              ? [FirstLetterUpperCaseTextFormatter()]
                              : null,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                            border: InputBorder.none,
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color.fromRGBO(82, 170, 164, 0.5)),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF52AAA4), width: 2),
                            ),
                          ),
                        )
                      : Text(
                          label == "Username" ? nickname :
                          label == "Email" ? email : 
                          label == "Pet Name" ? _petName.text : label,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                          ),
                        ),
                  ],
                ),
              ),
              
              // Right action icon for editable fields when not in edit mode
              if (!_isEditMode && editable)
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Color.fromRGBO(82, 170, 164, 0.7),
                  size: 16,
                ),
            ],
          ),
        ],
      ),
    );
  }
}