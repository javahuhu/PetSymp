import 'package:flutter/material.dart';
import 'package:petsymp/heightweight.dart';
import 'userdata.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
class AgeinputScreen extends StatefulWidget {
  const AgeinputScreen({super.key});
  @override
  AgeinputScreenState createState() => AgeinputScreenState();
}

class AgeinputScreenState extends State<AgeinputScreen> with SingleTickerProviderStateMixin {
  bool _isAnimated = false; // Animation toggle
  // State to track the selected tab
  int value = 0; // Counter value
  late AnimationController _bubbleAnimationController;
  
  // Animation for slider handle
  bool _isDragging = false;
  
  @override
  void initState() {
    super.initState();
    // Initialize animation controller first
    _bubbleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
    
    // Trigger the animation after the widget builds
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimated = true;
      });
    });
  }

  @override
  void dispose() {
    _bubbleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    // Calculate the proper slider width to fit within the screen
    final double sliderWidth = screenWidth * 0.8; // 80% of screen width
    final double sliderStartX = (screenWidth - sliderWidth) / 2; // Center the slider

    return Scaffold(
      body: Container(
        // Enhanced background with custom decoration
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
            // Decorative background elements
            
            // Large wave-like shape at the top
            Positioned(
              top: -screenHeight * 0.2,
              left: -screenWidth * 0.25,
              child: AnimatedBuilder(
                animation: _bubbleAnimationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      0,
                      _bubbleAnimationController.value * 10,
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
                animation: _bubbleAnimationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      0,
                      -_bubbleAnimationController.value * 10,
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
                animation: _bubbleAnimationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      _bubbleAnimationController.value * 5,
                      _bubbleAnimationController.value * 8,
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
                animation: _bubbleAnimationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      -_bubbleAnimationController.value * 8,
                      -_bubbleAnimationController.value * 6,
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
            Positioned(
              top: screenHeight * 0.28,
              right: screenWidth * 0.17,
              child: Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromRGBO(72, 138, 163, 0.3),
                ),
              ),
            ),
            
            // Small dot pattern bottom-left
            Positioned(
              bottom: screenHeight * 0.15,
              left: screenWidth * 0.2,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromRGBO(66, 134, 129, 0.5),
                ),
              ),
            ),
            Positioned(
              bottom: screenHeight * 0.14,
              left: screenWidth * 0.25,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromRGBO(66, 134, 129, 0.4),
                ),
              ),
            ),
            Positioned(
              bottom: screenHeight * 0.16,
              left: screenWidth * 0.22,
              child: Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromRGBO(66, 134, 129, 0.4),
                ),
              ),
            ),
            
            // Original UI elements with subtle enhancements
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
            
            Positioned(
              top: screenHeight * 0.22, // Text and input below the paw
              left: screenWidth * 0.12,
              right: screenWidth * 0.02,
              child: SlideInLeft(
                duration: const Duration(milliseconds: 800),
                from: 50,
                child:  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "How old is your pet?",
                      style: TextStyle(
                        fontSize: 25.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Oswald',
                        color: const Color.fromRGBO(29, 29, 44, 1.0),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Age display
            Positioned(
              top: screenHeight * 0.32,
              left: 0,
              right: 0,
              child: Center(
                child: FadeIn(
                  duration: const Duration(milliseconds: 800),
                  child: Text(
                    "$value years",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromRGBO(66, 134, 129, 1.0),
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // FIXED SLIDER SECTION
            Positioned(
              top: screenHeight * 0.4,
              left: 0,
              right: 0,
              child: FadeIn(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 200),
                child: Column(
                  children: [
                    // Enhanced Slider
                    Container(
                      height: 60,
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      width: sliderWidth,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Slider number indicators
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(6, (index) {
                                // Show only 0, 2, 4, 6, 8, 10 for better spacing
                                final int displayIndex = index * 2;
                                return Text(
                                  '$displayIndex',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: displayIndex == value ? FontWeight.bold : FontWeight.normal,
                                    color: displayIndex == value 
                                        ? const Color.fromRGBO(29, 29, 44, 1.0)
                                        : const Color.fromRGBO(29, 29, 44, 0.5),
                                  ),
                                  textAlign: TextAlign.center,
                                );
                              }),
                            ),
                          ),
                          
                          // Slider track background
                          Positioned(
                            top: 10,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 10,
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(82, 170, 164, 0.2),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                          
                          // Slider track filled part
                          Positioned(
                            top: 10,
                            left: 0,
                            child: Container(
                              height: 10,
                              width: sliderWidth * (value / 10),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color.fromRGBO(82, 170, 164, 0.8),
                                    Color.fromRGBO(66, 134, 129, 1.0),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromRGBO(66, 134, 129, 0.3),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Slider handle
                          Positioned(
                            top: 0,
                            left: (sliderWidth - 28) * (value / 10),
                            child: GestureDetector(
                              onHorizontalDragStart: (_) {
                                setState(() {
                                  _isDragging = true;
                                });
                              },
                              onHorizontalDragEnd: (_) {
                                setState(() {
                                  _isDragging = false;
                                });
                              },
                              onHorizontalDragUpdate: (details) {
                                final double localPosition = details.localPosition.dx;
                                final double percentage = ((details.globalPosition.dx - sliderStartX) / sliderWidth).clamp(0.0, 1.0);
                                
                                setState(() {
                                  value = (percentage * 10).round();
                                  Provider.of<UserData>(context, listen: false).setpetAge(value);
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: _isDragging ? 32 : 28,
                                height: _isDragging ? 32 : 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color.fromRGBO(29, 29, 44, 1.0),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color.fromRGBO(29, 29, 44, 0.3),
                                      blurRadius: _isDragging ? 12 : 8,
                                      offset: const Offset(0, 4),
                                      spreadRadius: _isDragging ? 2 : 0,
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.pets,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Add age description
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: Text(
                        _getAgeDescription(value),
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Color.fromRGBO(66, 134, 129, 0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    // Enhanced increment/decrement buttons
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Decrement button
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (value > 0) {
                                  value--;
                                  Provider.of<UserData>(context, listen: false).setpetAge(value);
                                }
                              });
                            },
                            child: Container(
                              width: 60,
                              height: 60,
                              margin: const EdgeInsets.symmetric(horizontal: 15),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color.fromRGBO(29, 29, 44, 1.0),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.2),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.remove,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                          
                          // Increment button
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (value < 10) {
                                  value++;
                                  Provider.of<UserData>(context, listen: false).setpetAge(value);
                                }
                              });
                            },
                            child: Container(
                              width: 60,
                              height: 60,
                              margin: const EdgeInsets.symmetric(horizontal: 15),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color.fromRGBO(29, 29, 44, 1.0),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.2),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Next Button at the previous position
            Positioned(
              top: screenHeight * 0.9,
              right: screenWidth * 0.02, // Adjust dynamically for right alignment
              child: SlideInUp(
                duration: const Duration(milliseconds: 800),
                from: 50,
                child: SizedBox( // Wrap with SizedBox to ensure correct width
                  width: 100, // Adjust as needed
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MeasureinputScreen()),
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
                      elevation: WidgetStateProperty.all(0),
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
  
  // Helper method to get age description
  String _getAgeDescription(int age) {
    switch (age) {
      case 0:
        return "Puppy / Kitten";
      case 1:
        return "Young";
      case 2:
      case 3:
        return "Young Adult";
      case 4:
      case 5:
      case 6:
        return "Adult";
      case 7:
      case 8:
        return "Mature Adult";
      case 9:
        return "Senior";
      case 10:
        return "Elder";
      default:
        return "";
    }
  }
}