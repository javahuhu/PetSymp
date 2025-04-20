import 'package:flutter/material.dart';
import 'package:petsymp/Assesment/mentionsymptoms.dart';
import 'report.dart';
import 'package:provider/provider.dart';
import 'package:petsymp/userdata.dart';
import 'dart:math' as math;
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AnothersympScreen extends StatefulWidget {
  const AnothersympScreen({super.key});

  @override
  AnothersympScreenState createState() => AnothersympScreenState();
}

class AnothersympScreenState extends State<AnothersympScreen> with SingleTickerProviderStateMixin {
  bool _isAnimated = false;
  final List<bool> _buttonVisible = [false, false];
  late AnimationController _bubblesController;
  late List<Bubble> _bubbles;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize bubble animation controller
    _bubblesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    
    // Create random bubbles
    _bubbles = List.generate(12, (index) => Bubble());
    
    // Initialize main UI animation
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _isAnimated = true;
      });
      for (int i = 0; i < _buttonVisible.length; i++) {
        Future.delayed(Duration(milliseconds: 300 * i), () {
          if (!mounted) return;
          setState(() {
            _buttonVisible[i] = true;
          });
        });
      }
    });
  }
  
  @override
  void dispose() {
    _bubblesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final userData = Provider.of<UserData>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFE8F2F5),
      body: Stack(
        children: [
          // Animated Bubbles Background
          AnimatedBuilder(
            animation: _bubblesController,
            builder: (context, child) {
              return Stack(
                children: _bubbles.map((bubble) {
                  final size = bubble.size * screenWidth * 0.15;
                  return Positioned(
                    left: (bubble.position.dx * screenWidth) + 
                           (math.sin((_bubblesController.value * bubble.speed + bubble.offset) * math.pi * 2) * bubble.wobble * screenWidth * 0.05),
                    top: (bubble.position.dy * screenHeight) + 
                         (_bubblesController.value * bubble.speed * screenHeight * 0.3) % screenHeight,
                    child: Opacity(
                      opacity: 0.4 * bubble.opacity,
                      child: Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Color.fromRGBO(82, 170, 164, 0.8),
                              Color.fromRGBO(82, 170, 164, 0.2),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.teal.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          
          // Content Layer
          Stack(
            children: [
              // Back Button
              Positioned(
                top: screenHeight * 0.03,
                left: screenWidth * 0.01,
                child: ElevatedButton(
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(8),
                  ),
                  child: const Icon(Icons.arrow_back, size: 40, color: Colors.black),
                ),
              ),
              
              // Animated Header with Paw Icon
              AnimatedPositioned(
                duration: const Duration(seconds: 1),
                curve: Curves.easeInOut,
                top: _isAnimated ? screenHeight * 0.13 : -100,
                left: screenWidth * 0.1,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: screenWidth * 0.15,
                      height: screenWidth * 0.15,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle, 
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(82, 170, 164, 0.3),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Image.asset('assets/paw.png', fit: BoxFit.contain),
                    ),
                    SizedBox(width: screenWidth * 0.05),
                  ],
                ),
              ),
              
              // Title with enhanced styling
              Positioned(
                top: screenHeight * 0.22,
                left: screenWidth * 0.12,
                right: screenWidth * 0.02,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Does she/he have another symptoms?",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(29, 29, 44, 1.0),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Subtle subtitle
                    Text(
                      "Add all relevant symptoms for an accurate diagnosis",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Current Symptoms display - Bubble design
                    if (userData.finalizedSymptoms.isNotEmpty || userData.pendingSymptoms.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Current Symptoms:",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color.fromRGBO(29, 29, 44, 0.8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: screenWidth * 0.8,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ...userData.finalizedSymptoms.map((symptom) => _buildSymptomBubble(symptom, true)),
                                ...userData.pendingSymptoms.map((symptom) => _buildSymptomBubble(symptom, false)),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              
              // Yes Button (adds another symptom)
              buildAnimatedButton(
                screenHeight,
                screenWidth,
                0.55,
                "Yes, Add Another Symptom",
                const MentionsympScreen(),
                0,
                shouldFinalizeAndSend: false,
                iconData: Icons.add_circle_outline,
              ),
              
              // No Button (finalize all and fetch diagnosis)
              buildAnimatedButton(
                screenHeight,
                screenWidth,
                0.66,
                "No, Get Diagnosis",
                const ReportScreen(),
                1,
                shouldFinalizeAndSend: true,
                iconData: Icons.check_circle_outline,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Symptom bubble design
  Widget _buildSymptomBubble(String symptom, bool isFinalized) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isFinalized 
          ? const Color.fromRGBO(82, 170, 164, 0.2) 
          : const Color.fromRGBO(255, 215, 64, 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFinalized 
            ? const Color.fromRGBO(82, 170, 164, 1.0) 
            : const Color.fromRGBO(255, 193, 7, 1.0),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFinalized ? Icons.check_circle : Icons.pending,
            size: 16,
            color: isFinalized 
              ? const Color.fromRGBO(82, 170, 164, 1.0) 
              : const Color.fromRGBO(255, 152, 0, 1.0),
          ),
          const SizedBox(width: 6),
          Text(
            symptom,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isFinalized 
                ? const Color.fromRGBO(29, 29, 44, 1.0) 
                : const Color.fromRGBO(29, 29, 44, 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAnimatedButton(
    double screenHeight,
    double screenWidth,
    double topPosition,
    String label,
    Widget destination,
    int index, {
    bool shouldFinalizeAndSend = false,
    IconData? iconData,
  }) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      top: _buttonVisible[index] ? screenHeight * topPosition : screenHeight,
      left: screenWidth * 0.5 - 150, // Center the button
      child: Container(
        width: 325.w,
        height: 55.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () async {
            if (shouldFinalizeAndSend) {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  title: const Text("Are you sure?"),
                  content: const Text(
                      "Once you proceed, you won't be able to go back and edit previous answers."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(82, 170, 164, 1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Confirm"),
                    ),
                  ],
                ),
              );

              if (confirm != true) return;

              final userData = Provider.of<UserData>(context, listen: false);

              // ✅ Finalize all pending symptoms
              for (final sym in userData.pendingSymptoms.toList()) {
                userData.finalizeSymptom(sym);
              }

              // ✅ Send to backend after finalizing
              await userData.fetchDiagnosis();
            }

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => destination),
            );
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return const Color.fromRGBO(82, 170, 164, 1);
              }
              return shouldFinalizeAndSend 
                ? const Color.fromRGBO(82, 170, 164, 0.1)
                : Colors.white.withOpacity(0.9);
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return Colors.white;
              }
              return const Color.fromRGBO(29, 29, 44, 1.0);
            }),
            shadowColor: MaterialStateProperty.all(Colors.transparent),
            side: MaterialStateProperty.all(
              BorderSide(
                color: shouldFinalizeAndSend
                  ? const Color.fromRGBO(82, 170, 164, 1)
                  : const Color.fromRGBO(82, 170, 164, 0.8),
                width: 2.0
              ),
            ),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            elevation: MaterialStateProperty.all(0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (iconData != null) ...[
                Icon(iconData, size: 22),
                const SizedBox(width: 10),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 18.0, 
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Bubble class for background animation
class Bubble {
  Offset position;
  double size;
  double speed;
  double wobble;
  double opacity;
  double offset;

  Bubble()
      : position = Offset(
          math.Random().nextDouble(),
          math.Random().nextDouble(),
        ),
        size = 0.15 + math.Random().nextDouble() * 0.4,
        speed = 0.1 + math.Random().nextDouble() * 0.3,
        wobble = 0.5 + math.Random().nextDouble() * 1.5,
        opacity = 0.3 + math.Random().nextDouble() * 0.7,
        offset = math.Random().nextDouble();
}