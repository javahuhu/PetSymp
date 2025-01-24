import 'package:flutter/material.dart';
import 'package:petsymp/QuestionDiseasesone/questionthree.dart';



class QtwoScreen extends StatefulWidget {
  const QtwoScreen({super.key});

  @override
  QtwoScreenState createState() =>QtwoScreenState();
}

class QtwoScreenState extends State<QtwoScreen> {
  bool _isAnimated = false; // Animation toggle
  int _selectedIndex = 0; // State to track the selected tab

  // Control the visibility of buttons
  final List<bool> _buttonVisible = [false, false, false, false, false, false];

  @override
  void initState() {
    super.initState();
    // Trigger the animation for each button with a delay
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _isAnimated = true;
      });
      for (int i = 0; i < _buttonVisible.length; i++) {
        Future.delayed(Duration(milliseconds: 300 * i), () {
          setState(() {
            _buttonVisible[i] = true; // Make each button visible sequentially
          });
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
                        "Is the diarrhea watery or loose,",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                       Text(
                        "and does it have an unusual",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      Text(
                        "color or odor?",
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
                // Animated Buttons
                buildAnimatedButton(
                    screenHeight, screenWidth,  0.8, "Yes", const QthreeScreen(), 0),
                buildAnimatedButton(
                    screenHeight, screenWidth, 0.87, "No", const QthreeScreen(),1),
              
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
      double topPosition,String label, Widget destination, int index) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      top: _buttonVisible[index] ? screenHeight * topPosition : screenHeight,
      left: screenWidth * 0.75,
      child: ElevatedButton(
        onPressed: () {
          
         Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => destination),
      );
        },
        style: ButtonStyle(
                    // Dynamic background color based on button state
                    backgroundColor: WidgetStateProperty.resolveWith(
                      (states) {
                        if (states.contains(WidgetState.pressed)) {
                          return const Color.fromARGB(255, 0, 0, 0); // Background color when pressed
                        }
                        return Colors.transparent; // Default background color
                      },
                    ),
                    // Dynamic text color based on button state
                    foregroundColor: WidgetStateProperty.resolveWith(
                      (states) {
                        if (states.contains(WidgetState.pressed)) {
                          return const Color.fromARGB(255, 255, 255, 255); // Text color when pressed
                        }
                        return Colors.black; // Default text color
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
