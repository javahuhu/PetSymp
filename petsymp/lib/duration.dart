import 'package:flutter/material.dart';
import 'package:petsymp/anothersymptoms.dart';
import 'package:provider/provider.dart';
import 'userdata.dart';

class DurationScreen extends StatefulWidget {
  const DurationScreen({super.key});

  @override
  DurationScreenState createState() => DurationScreenState();
}

class DurationScreenState extends State<DurationScreen> {
  bool _isAnimated = false;
  int _selectedIndex = 0;

  final List<bool> _buttonVisible = [false, false, false, false, false, false];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _isAnimated = true;
      });
      for (int i = 0; i < _buttonVisible.length; i++) {
        Future.delayed(Duration(milliseconds: 300 * i), () {
          setState(() {
            _buttonVisible[i] = true;
          });
        });
      }
    });
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
   
  

    return Scaffold(
      backgroundColor: const Color(0xFFCFCFCC),
      body: Stack(
        children: [
          if (_selectedIndex == 0)
            Stack(
              children: [
                // Back Button
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
                // Title Section
                Positioned(
                  top: screenHeight * 0.22,
                  left: screenWidth * 0.12,
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "How long has this been",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "troubling your pet?",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 50),
                    ],
                  ),
                ),
                // Animated Buttons with Provider
                buildAnimatedButton(
                    screenHeight, screenWidth, 0.35, "Three days", context, 0),
                buildAnimatedButton(
                    screenHeight, screenWidth, 0.42, "Five days", context, 1),
                buildAnimatedButton(
                    screenHeight, screenWidth, 0.49, "One week", context, 2),
                buildAnimatedButton(
                    screenHeight, screenWidth, 0.561, "Two weeks", context, 3),
                buildAnimatedButton(
                    screenHeight, screenWidth, 0.633, "Three weeks", context, 4),
                buildAnimatedButton(
                    screenHeight, screenWidth, 0.706, "One month", context, 5),
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
  Widget buildAnimatedButton(
      double screenHeight, double screenWidth, double topPosition, String label, BuildContext context, int index) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      top: _buttonVisible[index] ? screenHeight * topPosition : screenHeight,
      left: screenWidth * 0.29 - 50,
      child: ElevatedButton(
        onPressed: () {
          // Store selected duration in Provider
          Provider.of<UserData>(context, listen: false).setDuration(label);

          // Navigate to AnothersympScreen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AnothersympScreen(),
            ),
          );
        },
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
              borderRadius: BorderRadius.all(Radius.circular(3)),
            ),
          ),
          fixedSize: WidgetStateProperty.all(
            const Size(300, 55),
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
