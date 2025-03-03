import 'package:flutter/material.dart';
import 'package:petsymp/settings.dart';
import 'assesment.dart';
import 'profile.dart';

class HomePageScreen extends StatefulWidget {
   const HomePageScreen({super.key});


  @override
  HomePageScreenState createState() => HomePageScreenState();
}

class HomePageScreenState extends State<HomePageScreen> {
  int _selectedIndex = 0; // State to track the selected tab
  bool _isAnimated = false; // Animation toggle



  // Pages corresponding to each tab
  static const List<Widget> _pages = <Widget>[
    Icon(Icons.home, size: 150), // First page content
    Profilescreen(), // Second page content
    Settingscreen(), // Third page content
  ];

  @override
  void initState() {
    super.initState();
    // Start the animation after a short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _isAnimated = true; // Trigger animation
      });
    });
  }

  // Method to handle bottom navigation tab changes
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    // Screen dimensions
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
       backgroundColor: const Color(0xFFE8F2F5),
      body: Stack(
        children: [
          // Circular Image and Texts
          if (_selectedIndex == 0) // Only show this layout when on the first tab
            Positioned(
              top: screenHeight * 0.13, // 20% from the top of the screen
              left: screenWidth * 0.1, // 10% from the left of the screen
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Aligns all text to the left
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Circular Image
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
                      SizedBox(width: screenWidth * 0.05), // 5% of screen width for spacing

                      // Text beside the image
                      Padding(
                        padding: EdgeInsets.only(top: screenHeight * 0.03), // Relative padding
                        child: const Text(
                          "Hi, I’m Etsy",
                          style: TextStyle(
                            fontSize: 27, // Fixed font size for readability
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(29, 29, 44, 1.0) // Make the text bold
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02), // 2% of screen height for spacing

                  // Long Text Below the Image and First Text
                  const Text(
                    "I can help you to analyze your pet ",
                    style: TextStyle(
                      fontSize: 22, // Adjust font size
                      fontWeight: FontWeight.normal,
                      color: Color.fromRGBO(29, 29, 44, 1.0), // Normal font weight for description
                    ),
                  ),
                  const Text(
                    "health issues.",
                    style: TextStyle(
                      color: Color.fromRGBO(29, 29, 44, 1.0), // Text color
                      fontSize: 22, // Adjust font size
                      fontWeight: FontWeight.bold, // Normal font weight for description
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 55.0),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AssesmentScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF428682),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          fixedSize: const Size(250, 55), // Button width and height
                        ),
                        child: const Text(
                          "Start Assesment",
                          style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Rotated Image Positioned at the Bottom with Animation
          if (_selectedIndex == 0)
            AnimatedAlign(
              alignment: _isAnimated
                  ? const Alignment(0.5, 0.9) // Final position
                  : const Alignment(5, 1), // Start position
              duration: const Duration(seconds: 2), // Duration of animation
              curve: Curves.easeInOut, // Smooth transition
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationZ(-6.3 / 4), // Rotation angle
                child: Container(
                  height: screenHeight * 0.20, // 20% of screen height
                  width: screenWidth * 0.8, // 80% of screen width
                  margin: EdgeInsets.only(top: screenHeight * 0.23), // Margin from bottom
                  child: FittedBox(
                    fit: BoxFit.fill, // Forces the image to fill the container
                    child: Image.asset(
                      "assets/catpeeking.png", // Update this path to your cat image
                    ),
                  ),
                ),
              ),
            ),

          // Placeholder for other tabs
          if (_selectedIndex != 0)
            Center(
              child: _pages.elementAt(_selectedIndex), // Display corresponding content for other tabs
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
        selectedItemColor: const Color.fromRGBO(82, 170, 164, 1),
        unselectedItemColor: const Color.fromARGB(255, 255, 255, 255),
        onTap: _onItemTapped,
        backgroundColor: const Color.fromRGBO(29, 29, 44, 1.0),
      ),
    );
  }
}
