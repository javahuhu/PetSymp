import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:petsymp/permission.dart';
import 'userdata.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Custom TextInputFormatter remains unchanged
class FirstLetterUpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue; // Return empty value
    }

    final text = newValue.text;
    final firstLetter = text[0].toUpperCase();
    final restOfText = text.substring(1);

    return newValue.copyWith(
      text: firstLetter + restOfText,
      selection: newValue.selection,
    );
  }
}

class AssesmentScreen extends StatefulWidget {
  const AssesmentScreen({super.key});

  @override
  AssesmentScreenState createState() => AssesmentScreenState();
}

class AssesmentScreenState extends State<AssesmentScreen> {
  bool _isAnimated = false; // Animation toggle
  final TextEditingController _usernamecontroller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _isAnimated = true;
      });
    });
  }

  void navigateToNextPage(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      // Save userName globally using Provider
      Provider.of<UserData>(context, listen: false).setUserName(_usernamecontroller.text);

      // Navigate to PermissionScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PermissionScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        // Enhanced gradient background
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
            // Decorative bubble elements
            
            // Large bubble top-right
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
            
            // Medium bubble bottom-left
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
            
            // Small circle top-left
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
            
            // Middle-right medium circle
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
            
            // Bottom-center small dot
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
            
            // Middle-left small dot
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
            
            // Your original UI unchanged
            Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  top: _isAnimated ? screenHeight * 0.13 : -200,
                  left: screenWidth * 0.05,      
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: screenWidth * 1,
                        height: screenWidth * 0.15,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Text("Who's your Pet?", 
                        style: TextStyle(fontFamily: 'Oswald', fontSize: 35.sp, color: const Color.fromARGB(255, 0, 0, 0) ),
                        )
                      ),
                      SizedBox(width: screenWidth * 0.05),
                    ],
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.25,
                  left: screenWidth * 0.12,
                  right: screenWidth * 0.02,
                  child: SlideInLeft(
                          duration:const Duration(milliseconds: 1000),
                          delay: const Duration(milliseconds: 300),
                        from: 400,
                  child:
                   Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Before we start your assessment, input your PET USERNAME first.",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.normal,
                          fontFamily: 'Inter',
                          color: Color.fromRGBO(29, 29, 44, 1.0),
                        ),
                      ),
                     
                      const SizedBox(height: 22),
                      SizedBox(
                        width: screenWidth * 0.8,
                        child: Form(
                          key: _formKey,
                          child: TextFormField(
                            controller: _usernamecontroller,
                            autofillHints: const [AutofillHints.name],
                            inputFormatters: [
                              FirstLetterUpperCaseTextFormatter(),
                            ],
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: const BorderSide(
                                  color: Color.fromRGBO(66, 134, 130, 1.0),
                                  width: 2.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: const BorderSide(
                                  color: Color.fromRGBO(72, 38, 163, 1),
                                  width: 2.0,
                                ),
                              ),
                              hintText: 'Enter your name',
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 20.0,
                                horizontal: 15.0,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your username';
                              }
                              if (value.length > 20) {
                                return "Username must contain at least 20 letters Only";
                              }
                              
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                Positioned(
                top: screenHeight * 0.9,
                right: screenWidth * 0.02, // Adjust dynamically for right alignment
                child:
                SlideInUp(
                          duration:const Duration(milliseconds: 1000),
                          delay: const Duration(milliseconds: 300),
                        from: 400,
                  child:
                 SizedBox( // Wrap with SizedBox to ensure correct width
                  width: 100, // Adjust as needed
                  child: ElevatedButton(
                    onPressed: () => navigateToNextPage(context),
                    style: ButtonStyle(
                    // Dynamic background color based on button state
                    backgroundColor: WidgetStateProperty.resolveWith(
                      (states) {
                        if (states.contains(WidgetState.pressed)) {
                          return const Color.fromARGB(255, 0, 0, 0); // Background color when pressed
                        }
                        return Colors.transparent; // Default background color
                      },
                    ),
                    // Dynamic text color based on button state
                    foregroundColor: WidgetStateProperty.resolveWith(
                      (states) {
                        if (states.contains(WidgetState.pressed)) {
                          return const Color.fromARGB(255, 255, 255, 255); // Text color when pressed
                        }
                        return const Color.fromRGBO(29, 29, 44, 1.0); // Default text color
                      },
                    ),
                    shadowColor: WidgetStateProperty.all(Colors.transparent),
                    side: WidgetStateProperty.all(
                      const BorderSide(
                        color: Color.fromRGBO(82, 170, 164, 1),
                        width: 2.0,
                      ),
                    ),
                    shape: WidgetStateProperty.all(
                      const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                      ),
                    ),
                    fixedSize: WidgetStateProperty.all(
                      const Size(100, 55),
                    ),
                  ),
                    child: const Text(
                      "Next",
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}