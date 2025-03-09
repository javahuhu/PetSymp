import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:petsymp/userdata.dart';
import 'package:petsymp/report.dart';
import 'package:auto_size_text/auto_size_text.dart';

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
      _buttonVisible = [false, false]; // Reset button visibility
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _isAnimated = true;
      });

      for (int i = 0; i < _buttonVisible.length; i++) {
        Future.delayed(Duration(milliseconds: 800 * i), () {
          setState(() {
            _buttonVisible[i] = true; // Show buttons sequentially
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
      _triggerAnimation();
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
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight * 0.03),

            // ✅ Back Button
            Align(
              alignment: Alignment.centerLeft,
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

            // ✅ Animated Header (paw icon)
            AnimatedOpacity(
              duration: const Duration(seconds: 1),
              opacity: _isAnimated ? 1 : 0,
              child: Column(
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
                  SizedBox(height: screenHeight * 0.02),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.03),

            // ✅ Dynamic Question Text
            Expanded(
              child: Center(
                child: AutoSizeText(
                  questions.isNotEmpty
                      ? questions[currentQuestionIndex]
                      : "No questions available",
                  maxLines: 3,
                  minFontSize: 14,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.07,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromRGBO(29, 29, 44, 1.0),
                  ),
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.02),

            // ✅ Buttons Row (Yes/No)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // ✅ Yes Button
                buildAnimatedButton(screenWidth, "Yes", context, 0),
                // ✅ No Button
                buildAnimatedButton(screenWidth, "No", context, 1),
              ],
            ),

            SizedBox(height: screenHeight * 0.05),
          ],
        ),
      ),
    );
  }

  // ✅ Yes/No Buttons with Animation
  Widget buildAnimatedButton(double screenWidth, String label, BuildContext context, int index) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 800),
      opacity: _buttonVisible[index] ? 1 : 0,
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
              return const Color.fromRGBO(29, 29, 44, 1.0);
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
            Size(screenWidth * 0.3, 55), // ✅ Button width is now dynamic
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: screenWidth * 0.05, // ✅ Dynamic text size
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
