import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:petsymp/userdata.dart';
import 'package:petsymp/report.dart';

class QoneScreen extends StatefulWidget {
  const QoneScreen({super.key});

  @override
  QoneScreenState createState() => QoneScreenState();
}

class QoneScreenState extends State<QoneScreen> {
  bool _isAnimated = false;
  
  int currentQuestionIndex = 0;

  List<bool> _buttonVisible = [false, false];

  @override
  void initState() {
    super.initState();
    _triggerAnimation();
  }

  void _triggerAnimation() {
    setState(() {
      _isAnimated = false;
      _buttonVisible = [false, false]; // Reset buttons visibility
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _isAnimated = true;
      });

      for (int i = 0; i < _buttonVisible.length; i++) {
        Future.delayed(Duration(milliseconds: 200 * i), () {
          setState(() {
            _buttonVisible[i] = true; // Re-trigger button visibility sequentially
          });
        });
      }
    });
  }

  void nextQuestion(BuildContext context) {
    final userData = Provider.of<UserData>(context, listen: false);

    if (currentQuestionIndex < userData.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
      _triggerAnimation(); // Re-trigger animations for new question
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ReportScreen()),
      );
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


  

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final userData = Provider.of<UserData>(context);
    final questions = userData.questions;

    return Scaffold(
      backgroundColor: const Color(0xFFE8F2F5),
      body: Stack(
        children: [
        
            Stack(
              children: [
                Positioned(
                  top: screenHeight * 0.03,
                  left: screenWidth * 0.01,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to the previous question instead of exiting
                      previousQuestion();
                    },
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
                Positioned(
                  top: screenHeight * 0.22,
                  left: screenWidth * 0.12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Question",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(29, 29, 44, 1.0),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        questions.isNotEmpty
                            ? questions[currentQuestionIndex]
                            : "No questions available",
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
                // Yes/No Buttons with Re-Triggered Animation
                buildAnimatedButton(screenHeight * 1.03, screenWidth, 0.8, "Yes", context, 0),
                buildAnimatedButton(screenHeight * 1.03, screenWidth, 0.87, "No", context, 1),
              ],
            ),
          
        ],
      ),
     
    );
  }

  // Yes/No Buttons with Re-Triggered Animation
  Widget buildAnimatedButton(
      double screenHeight, double screenWidth, double topPosition, String label, BuildContext context, int index) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      top: _buttonVisible[index] ? screenHeight * topPosition : screenHeight,
      left: screenWidth * 0.75,
      child: ElevatedButton(
        onPressed: () => nextQuestion(context),
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) {
              if (states.contains(WidgetState.pressed)) {
                return const Color.fromARGB(255, 0, 0, 0);
              }
              return Colors.transparent;
            },
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) {
              if (states.contains(WidgetState.pressed)) {
                return const Color.fromARGB(255, 255, 255, 255);
              }
              return const Color.fromRGBO(29, 29, 44, 1.0)
;
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
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
