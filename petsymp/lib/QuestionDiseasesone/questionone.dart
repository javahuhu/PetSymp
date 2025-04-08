import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:petsymp/userdata.dart';
import 'package:petsymp/anothersymptoms.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:petsymp/symptomscatalog.dart';
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

class _QoneScreenState extends State<QoneScreen> {
  bool _isAnimated = false;
    bool _isNavigating = false;
  int currentQuestionIndex = 0;
  bool _buttonsVisible = false;

  @override
  void initState() {
    super.initState();
    _triggerAnimation();
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
      backgroundColor: const Color(0xFFE8F2F5),
      body: Stack(
        children: [
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
          // Question Text
          Positioned(
            top: screenHeight * 0.22,
            left: screenWidth * 0.03,
            right: screenWidth * 0.02,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "About the ${widget.symptom}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(29, 29, 44, 1.0),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  questionText,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(29, 29, 44, 1.0),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
          // Impact Choices Buttons
          if (_buttonsVisible)
            Positioned(
              top: screenHeight * 0.5,
              left: screenWidth * 0.05,
              right: screenWidth * 0.05,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: currentChoices.map((choice) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: ElevatedButton(
                      onPressed: () {
                        nextQuestion(context, choice);
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.pressed)) {
                            return const Color.fromARGB(255, 0, 0, 0);
                          }
                          return Colors.transparent;
                        }),
                        foregroundColor:
                            WidgetStateProperty.resolveWith((states) {
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
                          const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(100)),
                          ),
                        ),
                        fixedSize: WidgetStateProperty.all(
                          const Size(double.infinity, 55),
                        ),
                      ),
                      child: Text(
                        choice,
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            Positioned(
            bottom: 100.h,
            right: 16.w,
            child: FloatingActionButton(
              onPressed: _navigateToSymptomCatalog,
              backgroundColor: const Color.fromRGBO(29, 29, 44, 1.0),
              foregroundColor: const Color(0xFFE8F2F5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100.r),
              ),
              child: const Icon(Icons.menu_book_sharp),
            )),
        ],
      ),
    );
  }
}
