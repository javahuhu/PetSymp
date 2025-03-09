import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petsymp/loginaccount.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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


  Future<void> gotoPage(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
 

 Future<void> _signUpUser() async {
  try {
    if (!_formKey.currentState!.validate()) return;

    // Username check
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection("Users")
        .where("Username", isEqualTo: _usernameController.text.trim())
        .get();

    if (query.docs.isNotEmpty) {
      Fluttertoast.showToast(
        msg: "Username is already used",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    // Create user
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (userCredential.user != null) {
      String userId = userCredential.user!.uid;

      // Store user data (remove password storage!)
      await FirebaseFirestore.instance.collection("Users").doc(userId).set({
        "Username": _usernameController.text.trim(),
        "Email": _emailController.text.trim(),
        "CreatedTime": Timestamp.now(),
      });

      // Show success toast
      Fluttertoast.showToast(
        msg: "Account Successfully Created",
        toastLength: Toast.LENGTH_LONG,  // Changed to LONG
        gravity: ToastGravity.CENTER,
        backgroundColor: const Color.fromRGBO(82, 170, 164, 1),
        textColor: Colors.white,
      );

      // Navigate after toast has time to display
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginaccountScreen()),
      );
    }

  } catch (e) {
    print("Signup Error: $e");
    Fluttertoast.showToast(
      msg: "Error: ${e.toString()}",
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
            color: Color.fromARGB(255, 255, 255, 255), // Border color when not focused
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
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

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
                Icons.arrow_back_sharp,
                color: const Color.fromRGBO(61, 47, 40, 1),
                size: 40.sp,
              ),
              label: const Text(''),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
          // 
          

          //Logo at the top
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 0.045.sh),
                child: const Center(
                  child:  Text(
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
          // Rounded container for input fields and button
          Positioned(
            bottom: 0,
            child: Container(
              width: 1.0.sw,
              height: 0.65.sh,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(29, 29, 44, 1.0),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.r),
                  topRight: Radius.circular(40.r),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  top: 46.h, // Add more space at the top
                  left: 8.w,
                  right: 8.w,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Form(
  key: _formKey,
  child: Column(
    children: [
      // Username Input
            SizedBox(
              width: 0.8.sw, // Adjust width dynamically (85% of screen width)
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
                  fillColor: const Color.fromARGB(255, 255, 255, 255),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r), // Scaled radius
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 255, 255, 255), // Border color when not focused
                      width: 2.0, // Thickness when not focused
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(
                      color: Color.fromRGBO(82, 170, 164, 1), // Border color when focused
                      width: 3.0, // Thickness when focused
                    ),
                  ),
                  hintText: 'Username',
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 15.h,
                    horizontal: 15.w,
                  ),
                  suffixIcon: _usernameController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _usernameController.clear(); // Clear the input
                            setState(() {}); // Trigger a rebuild to hide the icon
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {}); // Trigger a rebuild to show/hide the clear icon
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
            ),

            SizedBox(height: 15.h),

      // Email Input
                  SizedBox(
                    width: 0.8.sw, // Adjust width dynamically
                    child: TextFormField(
                      controller: _emailController,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color.fromARGB(255, 255, 255, 255),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 255, 255, 255),
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(
                            color: Color.fromRGBO(82, 170, 164, 1),
                            width: 3.0,
                          ),
                        ),
                        hintText: 'Email',
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 15.h,
                          horizontal: 15.w,
                        ),
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
                      onChanged: (value) {
                        setState(() {});
                      },
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

                  // Password Input
                  SizedBox(
                    width: 0.8.sw, // Adjust width dynamically
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
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                  ),

                  SizedBox(height: 15.h),

                  // Confirm Password Input
                  SizedBox(
                    width: 0.8.sw, // Adjust width dynamically
                    child: _buildPasswordField(
                      controller: _confirmPass,
                      hintText: 'Confirm Password',
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
                    ElevatedButton(
                      onPressed: _signUpUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(82, 170, 164, 1),
                        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        fixedSize: Size( 0.8.sw,  0.069.sh),
                      ),
                      child:  Text(
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

          Positioned(
            top: 0.15.sh, // Adjust height dynamically
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

        ],
      ),
    );
  }
}
