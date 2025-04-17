import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petsymp/ResetPassword/email.dart';
import 'package:petsymp/SignUp/signup.dart';
import 'package:url_launcher/url_launcher.dart';
import 'progress.dart';

import 'dart:ui'; // Import this for lerpDoub
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

class LoginaccountScreen extends StatefulWidget {
  const LoginaccountScreen({super.key});

  @override
  LoginaccountScreenState createState() => LoginaccountScreenState();
}

class LoginaccountScreenState extends State<LoginaccountScreen> {

   Future<void> gotoPage(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }


  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery for responsive design
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      //backgroundColor: const Color.fromARGB(255, 173, 173, 80),
      backgroundColor: const Color(0xFFE8F2F5),
      body: Stack(
        children: [

          // Logo at the top
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Transform.translate(
              offset: Offset(0, -screenHeight * 0.035), // Moves up but prevents cutting
              child: Center(
                child: Image.asset(
                  'assets/logo.png',
                  width:  0.7.sw,
                  height: 0.3.sh,
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
              height: 0.5.sh,

              decoration: const BoxDecoration(
                color: Color.fromRGBO(29, 29, 44, 1.0),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Padding(
              padding: EdgeInsets.only(
                top: 46.h, // Add more space at the top
                left: 40.w,
                right: 40.w,
                bottom: 0.h, // Maintain bottom padding
              ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          SizedBox(
                          width: 0.8.sw, child: 
                          TextFormField(
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
                                color:  Color.fromRGBO(82, 170, 164, 1), // Border color when focused
                                width: 3.0, // Thickness when focused
                              ),
                            ),
                            hintText: 'Username',
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 15.0.h,
                              horizontal: 15.0.w,
                            ),
                            // Clear Icon Logic
                            suffixIcon: _usernameController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _usernameController.clear(); // Clear the input
                                      setState(() {
                                        // Clear `userName` when the icon is pressed
                                      }); 
                                    },
                                  )
                                : null, // No icon if the field is empty
                          ),
                         
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your username';
                            }
                            return null;
                          },
                          )),


                          
                          const SizedBox(height: 20),
                          // Password input
                          SizedBox(
                          width: 0.8.sw, child: 
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
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
                                  color:  Color.fromRGBO(255, 255, 255, 1), // Border color when not focused
                                  width: 2.0, // Thickness when not focused
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: const BorderSide(
                                  color:  Color.fromRGBO(82, 170, 164, 1),// Border color when focused
                                  width: 3.0, // Thickness when focused
                                ),
                              ),
                              hintText: 'Password',
                              contentPadding:  EdgeInsets.symmetric(
                                 vertical: 15.0.h,
                                  horizontal: 15.0.w,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          )),
                        ],
                      ),
                    ),
                     SizedBox(height: screenHeight * 0.04),
                    // Login button

                    ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProgressScreen(
                              username: _usernameController.text,
                              password: _passwordController.text,
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(82, 170, 164, 1),
                      foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      fixedSize: Size( 0.8.sw,  0.069.sh),
                    ),
                    child: Text(
                      "Log In",
                      style: TextStyle(fontSize: 22.0.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
  // Add spacing

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,  // ✅ Ensures proper spacing
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SignupScreen()),
                            );
                          },

                           style: const ButtonStyle(
                             overlayColor: WidgetStatePropertyAll(Colors.transparent),
                             shadowColor: WidgetStatePropertyAll(Colors.transparent),
                             elevation: WidgetStatePropertyAll(0),

                          ),
                          
                          child:  Text(
                            "Sign Up",
                            style: TextStyle(fontSize: 16.0.sp, color: const Color.fromRGBO(82, 170, 164, 1)),
                          ),
                        ),

                        // ✅ Recovery Password Button (properly positioned)
                        TextButton(
                         
                          onPressed: () {
                              Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const EmailScreen()),
                            );
                          },
                          
                           style: const ButtonStyle(
                             overlayColor: WidgetStatePropertyAll(Colors.transparent),
                             shadowColor: WidgetStatePropertyAll(Colors.transparent),
                             elevation: WidgetStatePropertyAll(0),

                          ),

                          child:  Text(
                            "Recovery Password",
                            style: TextStyle(fontSize: 16.0.sp, color:const Color.fromRGBO(82, 170, 164, 1)),
                          ),
                        ),
                      ],
                    ),


                  

                  SizedBox(height: 0.01.sh),

            //        Row(
            //     children: [
            //       Expanded(
            //         child: Divider(
            //           color: const Color.fromRGBO(82, 170, 164, 1),
            //           thickness: 2,
            //           indent: 0.05.w,
            //           endIndent:  0.02.w,
            //         ),
            //       ),
            //        Text(
            //         "OR",
            //         style: TextStyle(
            //           fontSize: 18.sp,
            //           fontWeight: FontWeight.bold,
            //           color:  const Color.fromRGBO(82, 170, 164, 1),
            //           letterSpacing: 1.0,
            //         ),
            //       ),
            //       Expanded(
            //         child: Divider(
            //           color: const Color.fromRGBO(82, 170, 164, 1),
            //           thickness: 2,
            //           indent: 0.02.w,
            //           endIndent: 0.05.w,
            //         ),
            //       ),
            //     ],
            //   ),

            //              Positioned(
            //   bottom: MediaQuery.of(context).padding.bottom + 50.h, // ✅ Adjusted for safe area
            //   left: 0,
            //   right: 0,
            //   child: Column(
            //     mainAxisSize: MainAxisSize.min, // ✅ Prevents unnecessary space usage
            //     children: [
            //       SizedBox(height: 12.h), // ✅ Adds space before icons
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.center,
            //         children: [
            //           // 🔹 Google Logo
            //           InkWell(
            //             onTap: () async {
            //               await gotoPage("https://accounts.google.com/");
            //             },
            //             child: Container(
            //               width: 40.w,  // ✅ Auto-scaled width
            //               height: 40.w, // ✅ Keep it square
            //               decoration: const BoxDecoration(
            //                 shape: BoxShape.circle,
            //               ),
            //               child: ClipOval(
            //                 child: Image.asset(
            //                   'assets/googlelogo.png',
            //                   fit: BoxFit.cover,
            //                 ),
            //               ),
            //             ),
            //           ),
            //           SizedBox(width: 20.w), // ✅ Scaled spacing between icons
                      
            //           // 🔹 Facebook Logo
            //           InkWell(
            //             onTap: () async {
            //               await gotoPage("https://www.facebook.com/");
            //             },
            //             child: Container(
            //               width: 50.w, // ✅ Slightly bigger than Google for proportion
            //               height: 50.w,
            //               decoration: const BoxDecoration(
            //                 shape: BoxShape.circle,
            //               ),
            //               child: ClipOval(
            //                 child: Image.asset(
            //                   'assets/facebooklogo.png',
            //                   fit: BoxFit.cover,
            //                 ),
            //               ),
            //             ),
            //           ),
            //           SizedBox(width: 20.w), // ✅ Scaled spacing between icons
                      
            //           // 🔹 Instagram Logo
            //           InkWell(
            //             onTap: () async {
            //               await gotoPage("https://www.instagram.com/");
            //             },
            //             child: Container(
            //               width: 40.w,  // ✅ Same as Google size
            //               height: 40.w,
            //               decoration: const BoxDecoration(
            //                 shape: BoxShape.circle,
            //               ),
            //               child: ClipOval(
            //                 child: Image.asset(
            //                   'assets/instagramlogo.png',
            //                   fit: BoxFit.cover,
            //                 ),
            //               ),
            //             ),
            //           ),
            //         ],
            //       ),
            //     ],
            //   ),
            // ),

            
       
                  ],
                ),
              ),
            ),

            
          ),

           Positioned(
             top: lerpDouble(122.h, -690.h, keyboardHeight / screenHeight) ?? 124.h,// Move up when keyboard is open // Move it higher to ensure visibility
            left: 0.17.sw, // Adjusts for centering
            child: Container(
              height: 0.35.sh, // Increase size slightly for better visibility
              width: 0.7.sw,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/hidog.png'),
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

void main() => runApp(const MaterialApp(home: LoginaccountScreen()));
