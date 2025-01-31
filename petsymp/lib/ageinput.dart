import 'package:flutter/material.dart';
import 'package:petsymp/heightweight.dart';


class AgeinputScreen extends StatefulWidget {
 
const AgeinputScreen({super.key});
  @override
  AgeinputScreenState createState() => AgeinputScreenState();
}

class AgeinputScreenState extends State<AgeinputScreen> {
  bool _isAnimated = false; // Animation toggle
  int _selectedIndex = 0; // State to track the selected tab
  int value = 0; // Counter value

  @override
  void initState() {
    super.initState();
    // Trigger the animation after the widget builds
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimated = true;
      });
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
          if (_selectedIndex == 0) // Show this layout only on the first tab
            Stack(
              children: [
                // AnimatedPositioned for Paw Image
                AnimatedPositioned(
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  top: _isAnimated ? screenHeight * 0.13 : -100, // From off-screen to final position
                  left: screenWidth * 0.1,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: screenWidth * 0.15, // 15% of screen width
                        height: screenWidth * 0.15, // Equal height for circular image
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/paw.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.05), // Spacing between paw and text
                      
                    ],
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.22, // Text and input below the paw
                  left: screenWidth * 0.12,
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "How old is your pet?",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),

                // Position for CounterSlider and Buttons
                 Positioned(
                  top: screenHeight * 0.35, // Adjust position below the "How old is your pet" text
                  left: screenWidth * 0.12,
                  right: screenWidth * 0.12,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Circle and Line in a Stack for Proper Alignment
                      Stack(
                        clipBehavior: Clip.none, // Ensure the circle can overflow without being clipped
                        alignment: Alignment.centerLeft,
                        children: [
                          // Thin Line
                          Container(
                            height: 4,
                            width: screenWidth * 0.72,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(2)),
                            ),
                          ),
                          // Circle Positioned on the Line
                          Positioned(
                            left: (screenWidth * 0.72 - 40) * (value / 10), // Dynamic position along the line
                            top: -20, // Raise the circle above the line
                            child: GestureDetector(
                              onHorizontalDragUpdate: (details) {
                                setState(() {
                                  // Update position based on drag
                                  double newPosition =
                                      (value + details.delta.dx / (screenWidth * 0.72) * 10).clamp(0, 10);
                                  value = newPosition.round();
                                });
                              },
                              child: Container(
                                width: 40, // Circle size
                                height: 40,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black, // Circle color
                                ),
                                child: Center(
                                  child: Text( 
                                    "$value", // Display value inside the circle
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40), // Space between slider and buttons
                      // + and - Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // + Button
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (value < 10) value++; // Increment value and move circle right
                              });
                            },
                            child: const CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.black,
                              child:  Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                          // - Button
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (value > 0) value--; // Decrement value and move circle left
                              });
                            },
                            child: const CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.black,
                              child:  Icon(
                                Icons.remove,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )

                ),

                // Next Button at the previous position
                Positioned(
                  top: screenHeight * 0.87,
                  left: screenWidth * 0.75,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>  const MeasureinputScreen()),
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
                    child: const Text(
                      "Next",
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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
}
