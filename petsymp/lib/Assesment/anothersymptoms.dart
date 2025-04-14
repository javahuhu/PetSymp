import 'package:flutter/material.dart';
import 'package:petsymp/Assesment/mentionsymptoms.dart';
import 'report.dart';
import 'package:provider/provider.dart';
import 'package:petsymp/userdata.dart';

class AnothersympScreen extends StatefulWidget {
  const AnothersympScreen({super.key});

  @override
  AnothersympScreenState createState() => AnothersympScreenState();
}

class AnothersympScreenState extends State<AnothersympScreen> {
  bool _isAnimated = false;
  final List<bool> _buttonVisible = [false, false];

  @override
  void initState() {
    super.initState();
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
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

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
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: Image.asset('assets/paw.png', fit: BoxFit.contain),
                    ),
                    SizedBox(width: screenWidth * 0.05),
                  ],
                ),
              ),
              // Title
              Positioned(
                top: screenHeight * 0.22,
                left: screenWidth * 0.12,
                right: screenWidth * 0.02,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Does she/he have another symptoms?",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(29, 29, 44, 1.0),
                      ),
                    ),
                    SizedBox(height: 50),
                  ],
                ),
              ),
              // Yes Button (adds another symptom)
              buildAnimatedButton(
                screenHeight,
                screenWidth,
                0.35,
                "Yes",
                const MentionsympScreen(),
                0,
                shouldFinalizeAndSend: false,
              ),
              // No Button (finalize all and fetch diagnosis)
              buildAnimatedButton(
                screenHeight,
                screenWidth,
                0.42,
                "No",
                const ReportScreen(),
                1,
                shouldFinalizeAndSend: true,
              ),
            ],
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
  }) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      top: _buttonVisible[index] ? screenHeight * topPosition : screenHeight,
      left: screenWidth * 0.29 - 50,
      child: ElevatedButton(
        onPressed: () async {
          if (shouldFinalizeAndSend) {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
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
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return const Color.fromARGB(255, 0, 0, 0);
            }
            return Colors.transparent;
          }),
          foregroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return const Color.fromARGB(255, 255, 255, 255);
            }
            return const Color.fromRGBO(29, 29, 44, 1.0);
          }),
          shadowColor: MaterialStateProperty.all(Colors.transparent),
          side: MaterialStateProperty.all(
            const BorderSide(color: Color.fromRGBO(82, 170, 164, 1), width: 2.0),
          ),
          shape: MaterialStateProperty.all(
            const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(3)),
            ),
          ),
          fixedSize: MaterialStateProperty.all(const Size(300, 55)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
