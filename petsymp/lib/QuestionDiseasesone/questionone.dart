import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:petsymp/userdata.dart';
import 'package:petsymp/anothersymptoms.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:petsymp/symptomscatalog.dart';
import 'package:animate_do/animate_do.dart';

class QoneScreen extends StatefulWidget {
  final String symptom;
  final List<String> questions;
  final List<List<String>> impactChoices;

  const QoneScreen({
    Key? key,
    required this.symptom,
    required this.questions,
    required this.impactChoices,
  }) : super(key: key);

  @override
  _QoneScreenState createState() => _QoneScreenState();
}

class _QoneScreenState extends State<QoneScreen> with SingleTickerProviderStateMixin {
  bool _isAnimated = false;
  bool _isNavigating = false;
  int currentQuestionIndex = 0;
  bool _buttonsVisible = false;
  
  // Animation controller for bubbles
  AnimationController? _bubbleAnimationController;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller first
    _bubbleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
    
    _triggerAnimation();
  }
  
  @override
  void dispose() {
    _bubbleAnimationController?.dispose();
    super.dispose();
  }

  void _triggerAnimation() {
    setState(() {
      _isAnimated = false;
      _buttonsVisible = false;
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _isAnimated = true;
      });
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!mounted) return;
        setState(() {
          _buttonsVisible = true;
        });
      });
    });
  }

  void nextQuestion(BuildContext context, String selectedAnswer) {
    final userData = Provider.of<UserData>(context, listen: false);
    // Check that questions list is not empty and index is valid.
    if (widget.questions.isEmpty || currentQuestionIndex >= widget.questions.length) {
      return;
    }
    final currentQuestion = widget.questions[currentQuestionIndex];
    userData.addSymptomAnswer(widget.symptom, currentQuestion, selectedAnswer);
    print("✅ Question: $currentQuestion");
    print("✅ Answer: $selectedAnswer");

    if (currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
      _triggerAnimation();
    } else {
      userData.fetchDiagnosis().then((_) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AnothersympScreen(),
          ),
        );
      });
    }
  }

  void previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
      _triggerAnimation();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _navigateToSymptomCatalog() {
    if (_isNavigating) return;

    _isNavigating = true;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SymptomscatalogScreen()),
    ).then((_) {
      _isNavigating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Safely get the current question text.
    final String questionText = (widget.questions.isNotEmpty &&
            currentQuestionIndex < widget.questions.length)
        ? widget.questions[currentQuestionIndex]
        : "No questions available";
    // Safely get the current choices.
    List<String> currentChoices = [];
    if (widget.impactChoices.isNotEmpty &&
        currentQuestionIndex < widget.impactChoices.length) {
      currentChoices = widget.impactChoices[currentQuestionIndex];
    }
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: Colors.transparent, // Make transparent to show gradient
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
            // Decorative background elements
            if (_bubbleAnimationController != null) ...[
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
            
            // Back Button
            Positioned(
              top: screenHeight * 0.03,
              left: screenWidth * 0.01,
              child: ElevatedButton.icon(
                onPressed: previousQuestion,
                icon: const Icon(
                  Icons.arrow_back_sharp,
                  color: Color.fromRGBO(61, 47, 40, 1),
                  size: 40.0,
                ),
                label: const Text(''),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
            
            // Animated Header
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
                  SizedBox(width: screenWidth * 0.05),
                ],
              ),
            ),
            
            // Question Text with animations
            Positioned(
              top: screenHeight * 0.22,
              left: screenWidth * 0.05,
              right: screenWidth * 0.05,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 800),
                    from: 30,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                     
                      child: Text(
                        "About the ${widget.symptom}",
                        style: TextStyle(
                          fontSize: 25.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromRGBO(29, 29, 44, 1.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  FadeInLeft(
                    duration: const Duration(milliseconds: 800),
                    delay: const Duration(milliseconds: 900),
                    from: 50,
                    child: Container(
                      padding: EdgeInsets.all(16.sp),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: const Color.fromRGBO(82, 170, 164, 0.3),
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        questionText,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color.fromRGBO(29, 29, 44, 1.0),
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Impact Choices Buttons with animations
            if (_buttonsVisible)
              Positioned(
                top: screenHeight * 0.46,
                left: screenWidth * 0.05,
                right: screenWidth * 0.05,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(currentChoices.length, (index) {
                    return FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      delay: Duration(milliseconds: 1000 + (index * 100)),
                      from: 30,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 6.h),
                        child: ElevatedButton(
                          onPressed: () {
                            nextQuestion(context, currentChoices[index]);
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.resolveWith((states) {
                              if (states.contains(WidgetState.pressed)) {
                                return const Color.fromARGB(255, 0, 0, 0);
                              }
                              return Colors.transparent;
                            }),
                            foregroundColor: WidgetStateProperty.resolveWith((states) {
                              if (states.contains(WidgetState.pressed)) {
                                return const Color.fromARGB(255, 255, 255, 255);
                              }
                              return const Color.fromRGBO(29, 29, 44, 1.0);
                            }),
                            shadowColor: WidgetStateProperty.all(Colors.transparent),
                            side: WidgetStateProperty.all(
                              const BorderSide(
                                color: Color.fromRGBO(82, 170, 164, 1),
                                width: 2.0,
                              ),
                            ),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(100.r)),
                              ),
                            ),
                            fixedSize: WidgetStateProperty.all(
                              Size(double.infinity, 55.h),
                            ),
                            padding: WidgetStateProperty.all(
                              EdgeInsets.symmetric(vertical: 12.h),
                            ),
                          ),
                          child: Text(
                            currentChoices[index],
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

            // Floating action button
            Positioned(
              bottom: 100.h,
              right: 16.w,
              child: FloatingActionButton(
                onPressed: _navigateToSymptomCatalog,
                backgroundColor: const Color.fromRGBO(29, 29, 44, 1.0),
                foregroundColor: const Color(0xFFE8F2F5),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.r),
                ),
                child: const Icon(Icons.menu_book_sharp),
              ),
            ),
            
            // Progress indicator
            Positioned(
              top: screenHeight * 0.05,
              right: screenWidth * 0.05,
              child: FadeIn(
                duration: const Duration(milliseconds: 800),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    "Question ${currentQuestionIndex + 1}/${widget.questions.length}",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromRGBO(66, 134, 129, 1.0),
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