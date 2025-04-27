import 'package:flutter/material.dart';
import 'package:petsymp/Assesment/ageinput.dart';
import '../userdata.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  PermissionScreenState createState() => PermissionScreenState();
}

class PermissionScreenState extends State<PermissionScreen> {
  bool _isAnimated = false; // Animation toggle

  @override
  void initState() {
    super.initState();
    // Trigger the animation after the widget builds
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimated = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final userName = Provider.of<UserData>(context).userName;

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
                        ),
                        child: Image.asset(
                          'assets/paw.png',
                          fit: BoxFit.contain,
                        ),
                      ),

                      SizedBox(width: screenWidth * 0.05), // 5% of screen width for spacing

                      // Text beside the image
                      Padding(
                        padding: EdgeInsets.only(top: screenHeight * 0.03), // Relative padding
                        child:   
                        Text(
                          "Hi, $userName",
                          style:  const TextStyle(
                            fontSize: 27, // Fixed font size for readability
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(29, 29, 44, 1.0), // Make the text bold
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  top: screenHeight * 0.22, // Text and input below the paw
                  left: screenWidth * 0.12,
                  right: screenWidth * 0.02,
                  child:  
                  SlideInLeft(
                    duration: Duration(milliseconds: 1000),
                    delay: Duration(milliseconds: 300),
                    from: 100,
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Please provide the following basic information Regarding to your pet",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.normal,
                            color: Color.fromRGBO(29, 29, 44, 1.0),
                          ),
                        ),
                      ],
                    ),
                  )
                ),

                // Next Button at the previous position
                Positioned(
                  top: screenHeight * 0.9,
                  right: screenWidth * 0.05, // Adjust dynamically for right alignment
                  child: 
                  SlideInUp(
                    duration: Duration(milliseconds: 1000),
                    delay: Duration(milliseconds: 300),
                    from: 100,
                    child: SizedBox( // Wrap with SizedBox to ensure correct width
                      width: 150, // Adjust as needed
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AgeinputScreen()),
                          );
                        },
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
                            const Size(110, 55),
                          ),
                        ),
                        child: const Text(
                          "CONFIRM",
                          style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}