import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petsymp/loginaccount.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'userdata.dart'; // Assuming this provider holds the email (OTP email)
import 'dynamicconnections.dart';
class ChangepasswordScreen extends StatefulWidget {
  const ChangepasswordScreen({Key? key}) : super(key: key);

  @override
  ChangepasswordScreenState createState() => ChangepasswordScreenState();
}

class ChangepasswordScreenState extends State<ChangepasswordScreen> {
  final TextEditingController _changepasswordController = TextEditingController();
  final TextEditingController _confirmchangepasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isUpdating = false;

  // Your backend URL for resetting password
  final String resetPasswordURL = AppConfig.resetpass;

  Future<void> _updatePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUpdating = true;
      });

      try {
        // Retrieve the email and OTP from your provider (set previously in EmailScreen)
        final userData = Provider.of<UserData>(context, listen: false);
        final email = userData.email; // Ensure you save the email here in setOTPemail
        final otp = userData.otpCode; // OTP that was verified at RecoveryScreen

        final newPassword = _changepasswordController.text;

        // Prepare the request body
        final body = jsonEncode({
          "email": email,
          "newPassword": newPassword,
          "otp": otp, // Send the OTP if your endpoint verifies it
        });

        // Make the HTTP POST request to your backend endpoint
        final response = await http.post(
          Uri.parse(resetPasswordURL),
          headers: {"Content-Type": "application/json"},
          body: body,
        );

        print("URL: $resetPasswordURL");
        print("Body: $body");
        // After the request
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        if (response.statusCode == 200) {
          Fluttertoast.showToast(
            msg: "Password updated successfully!",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );

          // Automatically navigate to the login screen after password reset
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginaccountScreen()),
          );
        } else {
          Fluttertoast.showToast(
            msg: "Failed to update password. (${response.body})",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      } catch (e) {
        Fluttertoast.showToast(
          msg: "Unexpected error: ${e.toString()}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      } finally {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required String labelText,
    required bool isPasswordVisible,
    required VoidCallback onVisibilityToggle,
    required String? Function(String?) validator,
    IconData prefixIcon = Icons.lock_rounded,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8.w, bottom: 8.h),
          child: Text(
            labelText,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: !isPasswordVisible,
            textInputAction: TextInputAction.done,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(
                  color: const Color.fromRGBO(82, 170, 164, 1),
                  width: 2.w,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(
                  color: Colors.red,
                  width: 2.w,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(
                  color: Colors.red,
                  width: 2.w,
                ),
              ),
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 16.sp,
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: 20.h,
                horizontal: 20.w,
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 15.w, right: 10.w),
                child: Icon(
                  prefixIcon,
                  color: const Color.fromRGBO(82, 170, 164, 1),
                  size: 22.sp,
                ),
              ),
              suffixIcon: Padding(
                padding: EdgeInsets.only(right: 15.w),
                child: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                    color: Colors.grey.shade600,
                    size: 22.sp,
                  ),
                  onPressed: onVisibilityToggle,
                ),
              ),
              errorStyle: TextStyle(
                color: Colors.red.shade300,
                fontSize: 14.sp,
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D1D2C),
      body: SafeArea(
        child: Stack(
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF1D1D2C),
                    const Color(0xFF2C2C44),
                  ],
                ),
              ),
            ),
            // Back button
            Positioned(
              top: 10.h,
              left: 10.w,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.white,
                  size: 26.sp,
                ),
              ),
            ),
            // Main content scroll view
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 30.h),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            "Update Password",
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            "Create a new secure password",
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30.h),
                    Container(
                      height: 180.h,
                      width: double.infinity,
                      child: Center(
                        child: Image.asset(
                          'assets/catsit.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C44).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 8.w, bottom: 20.h),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.security_rounded,
                                    color: const Color.fromRGBO(82, 170, 164, 1),
                                    size: 24.sp,
                                  ),
                                  SizedBox(width: 10.w),
                                  Text(
                                    "Password Security",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildPasswordField(
                              controller: _changepasswordController,
                              hintText: 'Enter new password',
                              labelText: 'New Password',
                              isPasswordVisible: _isPasswordVisible,
                              onVisibilityToggle: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 24.h),
                            _buildPasswordField(
                              controller: _confirmchangepasswordController,
                              hintText: 'Confirm your password',
                              labelText: 'Confirm Password',
                              isPasswordVisible: _isConfirmPasswordVisible,
                              onVisibilityToggle: () {
                                setState(() {
                                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (value != _changepasswordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                              prefixIcon: Icons.lock_outline_rounded,
                            ),
                            SizedBox(height: 30.h),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(82, 170, 164, 0.15),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Password Tips:",
                                    style: TextStyle(
                                      color: const Color.fromRGBO(82, 170, 164, 1),
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  _buildTipItem("Use at least 8 characters"),
                                  _buildTipItem("Include uppercase & lowercase letters"),
                                  _buildTipItem("Include numbers and special characters"),
                                ],
                              ),
                            ),
                            SizedBox(height: 40.h),
                            SizedBox(
                              width: double.infinity,
                              height: 60.h,
                              child: ElevatedButton(
                                onPressed: _isUpdating ? null : _updatePassword,
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: const Color.fromRGBO(82, 170, 164, 1),
                                  disabledBackgroundColor: const Color.fromRGBO(82, 170, 164, 0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  elevation: 5,
                                ),
                                child: _isUpdating
                                    ? Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            height: 20.h,
                                            width: 20.w,
                                            child: const CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 3,
                                            ),
                                          ),
                                          SizedBox(width: 12.w),
                                          Text(
                                            "Updating...",
                                            style: TextStyle(
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Text(
                                        "Update Password",
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(height: 16.h),
                            SizedBox(
                              width: double.infinity,
                              height: 60.h,
                              child: TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white.withOpacity(0.8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                    side: BorderSide(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1.5.w,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTipItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: const Color.fromRGBO(82, 170, 164, 1),
            size: 16.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 13.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
