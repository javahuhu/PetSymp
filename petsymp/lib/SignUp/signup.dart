import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petsymp/LogIn/loginaccount.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui'; // Import this for lerpDoub

// Custom TextInputFormatter to capitalize only the first letter
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

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  SignupScreenState createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPass = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  Future<void> gotoPage(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _signUpUser() async {
  try {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // 🔍 Check if username already exists in Firestore
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection("Users")
        .where("Username", isEqualTo: _usernameController.text.trim())
        .get();

    if (query.docs.isNotEmpty) {
      Fluttertoast.showToast(
        msg: "Username is already used choose",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      setState(() => _isLoading = false);
      return;
    }

   
    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (userCredential.user != null) {
      String userId = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection("Users").doc(userId).set({
        "Username": _usernameController.text.trim(),
        "Email": _emailController.text.trim(),
        "CreatedTime": Timestamp.now(),
      });

      Fluttertoast.showToast(
        msg: "Account Successfully Created",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: const Color.fromRGBO(82, 170, 164, 1),
        textColor: Colors.white,
      );

      await Future.delayed(const Duration(seconds: 1));
      setState(() => _isLoading = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginaccountScreen()),
      );
    }
  } on FirebaseAuthException catch (e) {
    setState(() => _isLoading = false);

    if (e.code == 'email-already-in-use choose another email') {
      Fluttertoast.showToast(
        msg: "Email is already in use.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } else if (e.code == 'invalid-email') {
      Fluttertoast.showToast(
        msg: "Invalid email format.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } else {
      Fluttertoast.showToast(
        msg: "Signup Error: ${e.message}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  } catch (e) {
    setState(() => _isLoading = false);
    Fluttertoast.showToast(
      msg: "Unexpected error: ${e.toString()}",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }
}


  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool isPasswordVisible,
    required VoidCallback onVisibilityToggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isPasswordVisible,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color.fromARGB(255, 255, 255, 255),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(
            color: Color.fromARGB(
                255, 255, 255, 255), // Border color when not focused
            width: 2.0, // Thickness when not focused
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(
            color: Color.fromRGBO(82, 170, 164, 1), // Border color when focused
            width: 3.0, // Thickness when focused
          ),
        ),
        hintText: hintText,
        contentPadding: EdgeInsets.symmetric(
          vertical: 15.h,
          horizontal: 15.w,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: onVisibilityToggle,
        ),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFE8F2F5),
      body: Stack(
        children: [
          // Back Button
          Positioned(
            top: 30.h,
            left: 5.w,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: const Color.fromRGBO(61, 47, 40, 1),
                size: 26.sp,
              ),
              label: const Text(''),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.transparent),
                elevation: WidgetStateProperty.all(0),
                shadowColor: WidgetStateProperty.all(Colors.transparent),
                overlayColor: WidgetStateProperty.all(
                    Colors.transparent), 
              ),
            ),
          ),
          

          
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 0.045.sh),
                child: const Center(
                  child: Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
             
            child: Container(
  height: 528.h, 
  decoration: BoxDecoration(
    color: const Color.fromRGBO(29, 29, 44, 1.0),
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(40.r),
      topRight: Radius.circular(40.r),
    ),
  ),
  child: SafeArea(
    top: false,
    child: SingleChildScrollView(
      padding: EdgeInsets.only(
        top: 46.h,
        left: 8.w,
        right: 8.w,
        bottom: MediaQuery.of(context).viewInsets.bottom + 0.h,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 450.h,
          maxHeight: 450.h,
        ),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Username Field
                    SizedBox(
                      width: 0.8.sw,
                      child: TextFormField(
                        controller: _usernameController,
                        autofillHints: const [AutofillHints.name],
                        inputFormatters: [
                          FirstLetterUpperCaseTextFormatter(),
                          FilteringTextInputFormatter.deny(RegExp(r'[0-9]')),
                        ],
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide:
                                const BorderSide(color: Colors.white, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: const BorderSide(
                              color: Color.fromRGBO(82, 170, 164, 1),
                              width: 3,
                            ),
                          ),
                          hintText: 'Username',
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 15.h, horizontal: 15.w),
                          suffixIcon: _usernameController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _usernameController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                        ),
                        onChanged: (_) => setState(() {}),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                      ),
                    ),

                    SizedBox(height: 15.h),

                    // Email Field
                    SizedBox(
                      width: 0.8.sw,
                      child: TextFormField(
                        controller: _emailController,
                        autofillHints: const [AutofillHints.email],
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide:
                                const BorderSide(color: Colors.white, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: const BorderSide(
                              color: Color.fromRGBO(82, 170, 164, 1),
                              width: 3,
                            ),
                          ),
                          hintText: 'Email',
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 15.h, horizontal: 15.w),
                          suffixIcon: _emailController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _emailController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                        ),
                        onChanged: (_) => setState(() {}),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Invalid Email';
                          }
                          return null;
                        },
                      ),
                    ),

                    SizedBox(height: 15.h),

                    // Password Field
                    SizedBox(
                      width: 0.8.sw,
                      child: _buildPasswordField(
                        controller: _passwordController,
                        hintText: 'Password',
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
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),
                    ),

                    SizedBox(height: 15.h),

                    // Confirm Password Field
                    SizedBox(
                      width: 0.8.sw,
                      child: _buildPasswordField(
                        controller: _confirmPass,
                        hintText: 'Confirm Password',
                        isPasswordVisible: _isConfirmPasswordVisible,
                        onVisibilityToggle: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40.h),

              // Sign Up Button
              ElevatedButton(
                onPressed: _signUpUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(82, 170, 164, 1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  fixedSize: Size(0.8.sw, 0.069.sh),
                ),
                child: Text(
                  "Sign Up",
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
),

          ),

          Positioned(
            top: 122.h,// Adjust height dynamically
            left: (1.sw - 0.85.sw) / 2, // Center horizontally
            child: Container(
              height: 0.2.sh, // Adjust height dynamically
              width: 0.85.sw, // Adjust width dynamically
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/catsit.png'),
                  fit: BoxFit.cover, // Adjust as needed
                ),
              ),
            ),
          ),

           if (_isLoading) ...[
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                color: Colors.black.withOpacity(0.2), // Slight dim color
              ),
            ),
            const Center(
              child: CircularProgressIndicator(
                color: const Color.fromRGBO(82, 170, 164, 1),
                strokeWidth: 5,
              ),
            ),
          ]
        ],
      ),
    );
  }
}
