import 'package:flutter/material.dart';
import 'package:petsymp/anothersymptoms.dart';
import 'package:provider/provider.dart';
import 'package:petsymp/userdata.dart';

class QoneScreen extends StatefulWidget {
  const QoneScreen({super.key});

  @override
  QoneScreenState createState() => QoneScreenState();
}

class QoneScreenState extends State<QoneScreen> {
  bool _isAnimated = false;
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

    // Use questionSymptoms for the current question label if available;
    // fall back to selectedSymptom if not.
    final String questionSymptom = userData.questionSymptoms.isNotEmpty &&
            currentQuestionIndex < userData.questionSymptoms.length
        ? userData.questionSymptoms[currentQuestionIndex]
        : userData.selectedSymptom;

    final currentQuestion = userData.questions[currentQuestionIndex];

    // Save the answer for this symptom question.
    userData.setSymptomDuration(questionSymptom, selectedAnswer);

    print("✅ Question: $currentQuestion");
    print("✅ Answer: $selectedAnswer");

    // Move to the next question if there is one; otherwise finalize the symptom.
    if (currentQuestionIndex < userData.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
      _triggerAnimation();
    } else {
      // All questions answered. Finalize the symptom to block re-entry:
      _finalizeSymptom(userData, questionSymptom);

      // Then fetch diagnosis if needed and navigate onwards.
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

  void _finalizeSymptom(UserData userData, String symptom) {
    // A new method that marks this symptom as "finalized" so the user can't re-enter it.
    // We'll define finalizeSymptom in your userData, which moves from pending → finalized.
    // e.g.: userData.finalizeSymptom(symptom);

    // If your userData does not yet have finalizeSymptom(...), add it:
    // 
    //   void finalizeSymptom(String symptom) {
    //     final normalized = symptom.trim().toLowerCase();
    //     _pendingSymptoms.remove(normalized);
    //     if (!_finalizedSymptoms.contains(normalized)) {
    //       _finalizedSymptoms.add(normalized);
    //     }
    //     notifyListeners();
    //   }
    // 
    // If you're not using that approach, see prior instructions for the "pending vs. finalized" logic.

    userData.finalizeSymptom(symptom);
    print("✅ Finalized Symptom: $symptom");
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
    final impactChoices = userData.impactChoices;

    // Current label for the question
    final String questionSymptom = userData.questionSymptoms.isNotEmpty &&
            currentQuestionIndex < userData.questionSymptoms.length
        ? userData.questionSymptoms[currentQuestionIndex]
        : userData.selectedSymptom;

    return Scaffold(
      backgroundColor: const Color(0xFFE8F2F5),
      body: Stack(
        children: [
          Stack(
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

              // Animated Paw
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

              // Question UI
              Positioned(
                top: screenHeight * 0.22,
                left: screenWidth * 0.03,
                right: screenWidth * 0.02,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "About the $questionSymptom",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(29, 29, 44, 1.0),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      questions.isNotEmpty && currentQuestionIndex < questions.length
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

              // Buttons for answers
              if (_buttonsVisible)
                buildImpactButtons(
                  screenHeight * 0.5,
                  screenWidth,
                  context,
                  impactChoices,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildImpactButtons(
    double top,
    double screenWidth,
    BuildContext context,
    List<List<String>> impactChoices,
  ) {
    List<String> currentChoices = [];
    if (currentQuestionIndex < impactChoices.length) {
      currentChoices = impactChoices[currentQuestionIndex];
    }
    return Positioned(
      top: top,
      left: screenWidth * 0.05,
      right: screenWidth * 0.05,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: currentChoices.map((choice) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: ElevatedButton(
              onPressed: () {
                print("✅ Selected Impact Choice: $choice");
                nextQuestion(context, choice); // Save answer and move on
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
                  const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                  ),
                ),
                fixedSize: WidgetStateProperty.all(const Size(double.infinity, 55)),
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
    );
  }
}
