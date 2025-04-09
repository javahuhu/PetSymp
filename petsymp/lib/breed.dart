import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petsymp/symptoms.dart';
import 'package:provider/provider.dart';
import 'userdata.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';

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

class BreedScreen extends StatefulWidget {
  const BreedScreen({super.key});

  @override
  BreedScreenState createState() => BreedScreenState();
}

class BreedScreenState extends State<BreedScreen> with SingleTickerProviderStateMixin {
  bool _isAnimated = false; // Animation toggle
  // Initialize the controller directly instead of using late
  AnimationController? _bubbleAnimationController;
  
  // State to track the selected tab
  final TextEditingController _breedcontroller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Initialize animation controller first
    _bubbleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
    
    // Trigger the animation after the widget builds
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _isAnimated = true;
      });
    });
  }

  @override
  void dispose() {
    // Safely dispose the controller
    _bubbleAnimationController?.dispose();
    super.dispose();
  }

  void navigateToNextPage() {
    if (_formKey.currentState?.validate() ?? false) {
      Provider.of<UserData>(context, listen: false).setpetBreed(_breedcontroller.text);
      // Navigate only if the input is valid
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SymptomsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        // Enhanced background with gradient
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
            // Check that controller is initialized before using it
            if (_bubbleAnimationController != null) ...[
              // Decorative background elements
              // Large wave-like shape at the top
              Positioned(
                top: -screenHeight * 0.2,
                left: -screenWidth * 0.25,
                child: AnimatedBuilder(
                  animation: _bubbleAnimationController!,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        0,
                        _bubbleAnimationController!.value * 10,
                      ),
                      child: Container(
                        width: screenWidth * 1.5,
                        height: screenHeight * 0.5,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(66, 134, 129, 0.07),
                          borderRadius: BorderRadius.circular(screenHeight * 0.25),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Smaller wave-like shape in bottom-right
              Positioned(
                bottom: -screenHeight * 0.1,
                right: -screenWidth * 0.25,
                child: AnimatedBuilder(
                  animation: _bubbleAnimationController!,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        0,
                        -_bubbleAnimationController!.value * 10,
                      ),
                      child: Container(
                        width: screenWidth * 0.9,
                        height: screenHeight * 0.3,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(66, 134, 129, 0.08),
                          borderRadius: BorderRadius.circular(screenHeight * 0.15),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Middle-left floating bubble
              Positioned(
                top: screenHeight * 0.45,
                left: screenWidth * 0.05,
                child: AnimatedBuilder(
                  animation: _bubbleAnimationController!,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        _bubbleAnimationController!.value * 5,
                        _bubbleAnimationController!.value * 8,
                      ),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color.fromRGBO(66, 134, 129, 0.2),
                          border: Border.all(
                            color: const Color.fromRGBO(66, 134, 129, 0.3),
                            width: 1.5,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Middle-right small floating circle
              Positioned(
                top: screenHeight * 0.6,
                right: screenWidth * 0.1,
                child: AnimatedBuilder(
                  animation: _bubbleAnimationController!,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        -_bubbleAnimationController!.value * 8,
                        -_bubbleAnimationController!.value * 6,
                      ),
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Color.fromRGBO(72, 138, 163, 0.3),
                              Color.fromRGBO(72, 138, 163, 0.1),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            
            // Static background elements that don't need the animation controller
            // Small dot pattern top-right
            Positioned(
              top: screenHeight * 0.25,
              right: screenWidth * 0.15,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromRGBO(72, 138, 163, 0.4),
                ),
              ),
            ),
            Positioned(
              top: screenHeight * 0.26,
              right: screenWidth * 0.2,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromRGBO(72, 138, 163, 0.3),
                ),
              ),
            ),
            
            // Back button
            Positioned(
              top: screenHeight * 0.03,
              left: screenWidth * 0.01,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_sharp,
                color: Color.fromRGBO(61, 47, 40, 1),
                size: 40.0,),
                label: const Text(''),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
            
            // AnimatedPositioned for Paw Image
            AnimatedPositioned(
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
              top: _isAnimated ? screenHeight * 0.13 : -100, // From off-screen to final position
              left: screenWidth * 0.1,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: screenWidth * 0.15, // 15% of screen width
                    height: screenWidth * 0.15, // Equal height for circular image
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(66, 134, 129, 0.2),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/paw.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.05), // Spacing between paw and text
                ],
              ),
            ),
            
            // Title and input form
            Positioned(
              top: screenHeight * 0.22, // Text and input below the paw
              left: screenWidth * 0.12,
              right: screenWidth * 0.02,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SlideInLeft(
                    duration: const Duration(milliseconds: 1000),
                    delay: const Duration(milliseconds: 300),
                    from: 100,
                    child: Text(
                      "What is your pet Breed?",
                      style: TextStyle(
                        fontSize: 25.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Oswald',
                        color: const Color.fromRGBO(29, 29, 44, 1.0),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 55.h),
                  FadeIn(
                    duration: const Duration(milliseconds: 800),
                    delay: const Duration(milliseconds: 400),
                    child: SizedBox(
                      width: screenWidth * 0.8,
                      child: Form(
                        key: _formKey,
                        child: TextFormField(
                          controller: _breedcontroller,
                          autofillHints: const [AutofillHints.name],
                          inputFormatters: [
                            FirstLetterUpperCaseTextFormatter(),
                            FilteringTextInputFormatter.deny(RegExp(r'[0-9]')),
                            FilteringTextInputFormatter.deny(RegExp(r'[!@#%^&*(),.?":{}|<>]')),
                          ],
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(
                                color: Color.fromRGBO(82, 170, 164, 1), // Border color when not focused
                                width: 2.0, // Thickness when not focused
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(
                                color: Color.fromRGBO(72, 38, 163, 1),// Border color when focused
                                width: 2.0, // Thickness when focused
                              ),
                            ),
                            hintText: 'Enter your pet breed',
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 20.0,
                              horizontal: 15.0,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the breed of pet';
                            }

                            // ✅ Use directly in validation (fix warning)
                            if (value.trim().length > 20) {
                              return 'Please enter less than 20 characters';
                            }

                            if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
                              return 'Only letters and spaces are allowed';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                  
                  // Example breeds hint
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0, left: 8.0),
                    child: SlideInLeft(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 600),
                      from: 50,
                      child: const Text(
                        "Examples: Golden Retriever, Persian Cat, Labrador",
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Next Button with animation
            Positioned(
              top: screenHeight * 0.9,
              right: screenWidth * 0.02, // Adjust dynamically for right alignment
              child: SlideInUp(
                duration: const Duration(milliseconds: 1000),
                delay: const Duration(milliseconds: 300),
                from: 100,
                child: SizedBox( // Wrap with SizedBox to ensure correct width
                  width: 100, // Adjust as needed
                  child: ElevatedButton(
                    onPressed: navigateToNextPage,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}