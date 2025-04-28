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
  final ScrollController _scrollController = ScrollController();
  
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
    _scrollController.dispose();
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
                          gradient: const RadialGradient(
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
          
          SafeArea(
            child: Column(
              children: [
                // Back Button
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.arrow_back, size: 28, color: Colors.black),
                    padding: const EdgeInsets.all(16),
                  ),
                ),
                
                // Paw Icon centered
                Padding(
                  padding: EdgeInsets.only(right: 225.w),
                  child: 
                AnimatedOpacity(
                  duration: const Duration(seconds: 1),
                  opacity: _isAnimated ? 1.0 : 0.0,
                  child: Center(
                    child: Container(
                      width: screenWidth * 0.15,
                      height: screenWidth * 0.15,
                      margin: const EdgeInsets.only(top: 8, bottom: 16),
                      child: Image.asset('assets/paw.png', fit: BoxFit.contain),
                    ),
                  ),
                )),
                
                // Question and Subtitle
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 5, 20, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Does He/She have another symptoms?",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(29, 29, 44, 1.0),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Add all relevant symptoms for an accurate diagnosis",
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.black54,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Symptoms Display (if any)
                if (userData.finalizedSymptoms.isNotEmpty || userData.pendingSymptoms.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: Column(
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
                          constraints: BoxConstraints(
                            maxHeight: screenHeight * 0.3, // Set a maximum height
                          ),
                          width: double.infinity,
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
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.all(12),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ...userData.finalizedSymptoms.map((symptom) => _buildSymptomBubble(symptom, true)),
                                ...userData.pendingSymptoms.map((symptom) => _buildSymptomBubble(symptom, false)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                SizedBox(height: 50.h,),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  child: Column(
                    children: [
                      // Yes, Add Another Button
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 800),
                        opacity: _buttonVisible[0] ? 1.0 : 0.0,
                        child: Container(
                          width: double.infinity,
                          height: 55.h,
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const MentionsympScreen()),
                              );
                            },
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.pressed)) {
                                  return const Color.fromRGBO(82, 170, 164, 1);
                                }
                                return Colors.white.withOpacity(0.9);
                              }),
                              foregroundColor: WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.pressed)) {
                                  return Colors.white;
                                }
                                return const Color.fromRGBO(29, 29, 44, 1.0);
                              }),
                              shadowColor: MaterialStateProperty.all(Colors.transparent),
                              side: MaterialStateProperty.all(
                                const BorderSide(
                                  color: Color.fromRGBO(82, 170, 164, 0.8),
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
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  "Yes, Add Another",
                                  style: TextStyle(
                                    fontSize: 16.0, 
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // No, Get Diagnosis Button
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 800),
                        opacity: _buttonVisible[1] ? 1.0 : 0.0,
                        child: Container(
                          width: double.infinity,
                          height: 55.h,
                          child: ElevatedButton(
                            onPressed: () async {
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

                              // Finalize all pending symptoms
                              for (final sym in userData.pendingSymptoms.toList()) {
                                userData.finalizeSymptom(sym);
                              }

                              // Send to backend after finalizing
                              await userData.fetchDiagnosis();
                              
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const ReportScreen()),
                              );
                            },
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.pressed)) {
                                  return const Color.fromRGBO(82, 170, 164, 1);
                                }
                                return const Color.fromRGBO(82, 170, 164, 0.1);
                              }),
                              foregroundColor: WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.pressed)) {
                                  return Colors.white;
                                }
                                return const Color.fromRGBO(29, 29, 44, 1.0);
                              }),
                              shadowColor: MaterialStateProperty.all(Colors.transparent),
                              side: MaterialStateProperty.all(
                                const BorderSide(
                                  color: Color.fromRGBO(82, 170, 164, 1),
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
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  "No, Get Diagnosis",
                                  style: TextStyle(
                                    fontSize: 16.0, 
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.2,
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
              ],
            ),
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