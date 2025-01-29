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
  int _selectedIndex = 0;
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

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimated = true;
      });

      for (int i = 0; i < _buttonVisible.length; i++) {
        Future.delayed(Duration(milliseconds: 500 * i), () {
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

  static const List<Widget> _pages = <Widget>[
    Icon(Icons.home, size: 150),
    Icon(Icons.person, size: 150),
    Icon(Icons.settings, size: 150),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final userData = Provider.of<UserData>(context);
    final questions = userData.questions;

    return Scaffold(
      backgroundColor: const Color(0xFFCFCFCC),
      body: Stack(
        children: [
          if (_selectedIndex == 0)
            Stack(
              children: [
                Positioned(
                  top: screenHeight * 0.03,
                  left: screenWidth * 0.01,
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
                          color: Colors.black,
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
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
                // Yes/No Buttons with Re-Triggered Animation
                buildAnimatedButton(screenHeight, screenWidth, 0.8, "Yes", context, 0),
                buildAnimatedButton(screenHeight, screenWidth, 0.87, "No", context, 1),
              ],
            ),
          if (_selectedIndex != 0)
            Center(
              child: _pages.elementAt(_selectedIndex),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromRGBO(61, 47, 40, 1),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
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
              return Colors.black;
            },
          ),
          shadowColor: WidgetStateProperty.all(Colors.transparent),
          side: WidgetStateProperty.all(
            const BorderSide(
              color: Colors.black,
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
