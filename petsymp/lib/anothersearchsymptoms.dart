import 'package:flutter/material.dart';
import 'package:petsymp/QuestionDiseasesone/questionone.dart';
import 'package:provider/provider.dart';
import 'userdata.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'symptomscatalog.dart';
import 'package:animate_do/animate_do.dart';

class AnothersearchsymptomsScreen extends StatefulWidget {
  const AnothersearchsymptomsScreen({super.key});

  @override
  AnothersearchsymptomsScreenState createState() =>
      AnothersearchsymptomsScreenState();
}

class AnothersearchsymptomsScreenState extends State<AnothersearchsymptomsScreen> with SingleTickerProviderStateMixin {
  bool _isAnimated = false;
  bool _isNavigating = false;
  final List<bool> _buttonVisible = [false, false, false, false, false, false];
  
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
    
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _isAnimated = true;
      });
      for (int i = 0; i < _buttonVisible.length; i++) {
        final int index = i;
        Future.delayed(Duration(milliseconds: 300 * index), () {
          if (!mounted) return;
          setState(() {
            _buttonVisible[index] = true;
          });
        });
      }
    });
  }
  
  @override
  void dispose() {
    _bubbleAnimationController?.dispose();
    super.dispose();
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
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final userData = Provider.of<UserData>(context);

    // Instead of checking the temporary anotherSymptom field,
    // use the last element in pendingSymptoms.
    String displayedSymptom = "";
    if (userData.pendingSymptoms.isNotEmpty) {
      displayedSymptom = userData.pendingSymptoms.last;
    } else if (userData.selectedSymptom.isNotEmpty) {
      displayedSymptom = userData.selectedSymptom;
    } else {
      displayedSymptom = "Select Another Symptoms";
    }

    return Scaffold(
      backgroundColor: Colors.transparent, // Make scaffold transparent for gradient
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
            
            // Main content
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Back Button
                    SizedBox(
                      height: screenHeight * 0.1,
                      child: Stack(
                        children: [
                          Positioned(
                            top: screenHeight * 0.03,
                            left: -screenWidth * 0.05,
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.of(context).pop(),
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
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    // Animated Header
                    AnimatedOpacity(
                      duration: const Duration(seconds: 1),
                      opacity: _isAnimated ? 1 : 0,
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
                          Expanded(
                            child: SlideInLeft(
                              duration: const Duration(milliseconds: 1000),
                              delay: const Duration(milliseconds: 300),
                              from: 50,
                              child: AutoSizeText(
                                "Select Another Symptoms",
                                maxLines: 1,
                                minFontSize: 12,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.08,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromRGBO(29, 29, 44, 1.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 70.h),
                    
                    // Container that shows the latest symptom (from pendingSymptoms)
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 100),
                      child: Column(
                        children: [
                          buildSymptomsContainer(
                            screenWidth,
                            displayedSymptom,
                            ["Tap to select and answer questions for new symptoms"],
                          ),
                          SizedBox(height: 15.h),
                        ],
                      ),
                    ),
                    
                    // Additional hardcoded symptom containers (if needed)
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 200),
                      child: Column(
                        children: [
                          buildSymptomsContainer(
                            screenWidth,
                            "Frequent Bowel Movements",
                            ["Loose, watery stools."],
                          ),
                          SizedBox(height: 15.h),
                        ],
                      ),
                    ),
                    
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 300),
                      child: Column(
                        children: [
                          buildSymptomsContainer(
                            screenWidth,
                            "Frequent Episodes",
                            ["Repeated vomiting over a short period"],
                          ),
                          SizedBox(height: 15.h),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 80.h),
                  ],
                ),
              ),
            ),
            
            // Floating action button
            Positioned(
              bottom: 15.h,
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
          ],
        ),
      ),
    );
  }

  Widget buildSymptomsContainer(
      double screenWidth, String title, List<String> details) {
    return Container(
      padding: EdgeInsets.all(16.sp),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(29, 29, 44, 1.0),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
        border: Border.all(
          color: const Color.fromRGBO(66, 134, 129, 0.3),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: const Color.fromRGBO(255, 255, 255, 1),
            ),
          ),
          SizedBox(height: 8.h),
          for (String detail in details)
            Text(
              detail,
              style: TextStyle(
                fontSize: 16.sp,
                color: const Color.fromRGBO(210, 216, 216, 1),
              ),
            ),
          SizedBox(height: 16.h),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final userData =
                      Provider.of<UserData>(context, listen: false);
                  // Add this symptom and set it as the selected symptom.
                  userData.addNewPetSymptom(title);
                  userData.setSelectedSymptom(title);
                  // Update the questions for the selected symptom.
                  userData.updateQuestions();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QoneScreen(
                        symptom: title,
                        questions: List<String>.from(userData.questions),
                        impactChoices:
                            List<List<String>>.from(userData.impactChoices),
                      ),
                    ),
                  );
                });
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.pressed)) {
                    return const Color.fromRGBO(66, 134, 130, 1.0);
                  }
                  return Colors.transparent;
                }),
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.pressed)) {
                    return Colors.white;
                  }
                  return Colors.white;
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
                    borderRadius: BorderRadius.all(Radius.circular(6.r)),
                  ),
                ),
                padding: WidgetStateProperty.all(
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                ),
                fixedSize: WidgetStateProperty.all(Size(120.w, 45.h)),
              ),
              child: const Text(
                "Select",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}