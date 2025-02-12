import 'package:flutter/material.dart';
import 'package:petsymp/homepage.dart';

class RecommendationtwoScreen extends StatefulWidget {
  const RecommendationtwoScreen({super.key});

  @override
  RecommendationtwoScreenState createState() => RecommendationtwoScreenState();
}

class RecommendationtwoScreenState extends State<RecommendationtwoScreen> {
  bool _isAnimated = false;
  int _selectedIndex = 0;// Animation toggle
  final List<bool> _buttonVisible = [false, false, false, false, false, false];
  bool _animationTriggered = false; // Prevents redundant animation triggers

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_animationTriggered) {
      _triggerAnimation();
      _animationTriggered = true; // Ensures animation only runs once per back navigation
    }
  }

  void _triggerAnimation() {
    if (!mounted) return; // Prevents triggering animation if widget is removed

    setState(() {
      _isAnimated = false;
      _buttonVisible.fillRange(0, _buttonVisible.length, false);
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;

      setState(() {
        _isAnimated = true;
      });

      for (int i = 0; i < _buttonVisible.length; i++) {
        Future.delayed(Duration(milliseconds: 300 * i), () {
          if (mounted) {
            setState(() {
              _buttonVisible[i] = true;
            });
          }
        });
      }
    });
  }

  // Pages corresponding to each tab
  static const List<Widget> _pages = <Widget>[
    Icon(Icons.home, size: 150), // First page content
    Icon(Icons.person, size: 150), // Second page content
    Icon(Icons.settings, size: 150), // Third page content
  ];

  // Method to handle bottom navigation tab changes
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
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
                child: ElevatedButton.icon(
                  onPressed: () {
                    _animationTriggered = false; // Reset animation flag
                    Navigator.of(context).pop();
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
                      child: Image.asset(
                        'assets/paw.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.05),
                    Padding(
                      padding: EdgeInsets.only(top: screenHeight * 0.03),
                      child: const Text(
                        "Recommendation",
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(29, 29, 44, 1.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Title Section
              Positioned(
                top: screenHeight * 0.22,
                left: screenWidth * 0.12,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Part 2",
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
              // Animated Buttons
              buildAnimatedButton(
                screenHeight,
                screenWidth,
                0.8,
                "Finish",
                const HomePageScreen(),
                0, // ✅ Ensure unique index to prevent animation conflicts
              ),
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

  // Method to create an animated button
  Widget buildAnimatedButton(double screenHeight, double screenWidth,
      double topPosition, String label, Widget destination, int index) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      top: _buttonVisible[index] ? screenHeight * topPosition : screenHeight,
      left: screenWidth * 0.45 - 50,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          ).then((_) {
            _animationTriggered = false; // ✅ Reset animation when returning
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromRGBO(29, 29, 44, 1.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          fixedSize: const Size(155, 55),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
