import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:petsymp/userdata.dart';
import 'package:petsymp/Assesment/anothersymptoms.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:petsymp/SymptomsCatalog/symptomscatalog.dart';
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

class _QoneScreenState extends State<QoneScreen>
    with SingleTickerProviderStateMixin {
  bool _isAnimated = false;
  bool _isNavigating = false;
  int currentQuestionIndex = 0;
  bool _buttonsVisible = false;

  AnimationController? _bubbleAnimationController;

  @override
  void initState() {
    super.initState();
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
    if (widget.questions.isEmpty ||
        currentQuestionIndex >= widget.questions.length) {
      return;
    }
    final currentQuestion = widget.questions[currentQuestionIndex];
    userData.addSymptomAnswer(widget.symptom, currentQuestion, selectedAnswer);
    debugPrint("✅ Question: $currentQuestion");
    debugPrint("✅ Answer: $selectedAnswer");

    if (currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
      _triggerAnimation();
    } else {
      userData.addPendingSymptom(widget.symptom);
      userData.fetchDiagnosis().then((_) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AnothersympScreen()),
        );
      });
    }
  }

  void previousQuestion() {
    final userData = Provider.of<UserData>(context, listen: false);
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
      _triggerAnimation();
    } else {
      userData.removePendingSymptom(widget.symptom);
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
    final String questionText = (widget.questions.isNotEmpty &&
            currentQuestionIndex < widget.questions.length)
        ? widget.questions[currentQuestionIndex]
        : "No questions available";
    List<String> currentChoices = [];
    if (widget.impactChoices.isNotEmpty &&
        currentQuestionIndex < widget.impactChoices.length) {
      currentChoices = widget.impactChoices[currentQuestionIndex];
    }
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
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
            Positioned(
              top: screenHeight * 0.03,
              left: screenWidth * 0.01,
              child: ElevatedButton.icon(
                onPressed: previousQuestion,
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: const Color.fromRGBO(61, 47, 40, 1),
                  size: 26.sp,
                ),
                label: const Text(''),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.transparent), // Changed from WidgetStateProperty
                  elevation: MaterialStateProperty.all(0), // Changed from WidgetStateProperty
                  shadowColor: MaterialStateProperty.all(Colors.transparent), // Changed from WidgetStateProperty
                  overlayColor: MaterialStateProperty.all(Colors.transparent), // Changed from WidgetStateProperty
                ),
              ),
            ),

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
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
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
                  SizedBox(height: 20.h),
                  if (_buttonsVisible && currentChoices.isNotEmpty)
                    Column(
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
                                backgroundColor:
                                    MaterialStateProperty.resolveWith((states) { // Changed from WidgetStateProperty
                                  if (states.contains(MaterialState.pressed)) { // Changed from WidgetState.pressed
                                    return const Color.fromARGB(255, 0, 0, 0);
                                  }
                                  return Colors.transparent;
                                }),
                                foregroundColor:
                                    MaterialStateProperty.resolveWith((states) { 
                                  if (states.contains(MaterialState.pressed)) { 
                                    return const Color.fromARGB(
                                        255, 255, 255, 255);
                                  }
                                  return const Color.fromRGBO(29, 29, 44, 1.0);
                                }),
                                shadowColor:
                                    MaterialStateProperty.all(Colors.transparent),
                                side: MaterialStateProperty.all( 
                                  const BorderSide(
                                    color: Color.fromRGBO(82, 170, 164, 1),
                                    width: 2.0,
                                  ),
                                ),
                                shape: MaterialStateProperty.all( 
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(100.r)),
                                  ),
                                ),
                                fixedSize: MaterialStateProperty.all( // Changed from WidgetStateProperty
                                  Size(double.infinity, 55.h),
                                ),
                                padding: MaterialStateProperty.all( // Changed from WidgetStateProperty
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
                ],
              ),
            ),
            
            // Floating catalog button.
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
            // Progress indicator.
            Positioned(
              top: screenHeight * 0.05,
              right: screenWidth * 0.05,
              child: FadeIn(
                duration: const Duration(milliseconds: 800),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
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