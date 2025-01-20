import 'package:flutter/material.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  _HomePageScreen createState() => _HomePageScreen();
}

class _HomePageScreen extends State<HomePageScreen> {
  int _selectedIndex = 0; // State to track the selected tab

  // Pages corresponding to each tab
  static const List<Widget> _pages = <Widget>[
    Icon(Icons.call, size: 150), // First page content
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
    return Scaffold(
      backgroundColor: const Color(0xFFCFCFCC),
      body: Stack(
        children: [
          // Circular Image and Texts
          if (_selectedIndex == 0) // Only show this layout when on the first tab
            Positioned(
              top: MediaQuery.of(context).size.height * 0.2, // Adjust to position near the middle
              left: 50, // Adjust horizontal positioning
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Aligns all text to the left
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Circular Image
                      Container(
                        width: 70,
                        height: 70,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/paw.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 25), // Space between image and text

                      const Padding(
                        padding: EdgeInsets.only(top: 30),
                        child: Text(
                          "Hi, I’m Etsy",
                          style: TextStyle(
                            fontSize: 27, // Adjust the font size
                            fontWeight: FontWeight.bold, // Make the text bold
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10), // Space between rows

                  // Long Text Below the Image and First Text
                  const Text(
                    "I can help you to analyze your pet ",
                    style: TextStyle(
                      fontSize: 22, // Adjust the font size for smaller text
                      fontWeight: FontWeight.normal,
                      color: Colors.black, // Normal font weight for description
                    ),
                  ),
                  const Text(
                    "health issues.",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22, // Adjust the font size for smaller text
                      fontWeight: FontWeight.bold, // Normal font weight for description
                    ),
                  ),
                ],
              ),
            ),

          // Rotated Image Positioned at the Bottom
          if (_selectedIndex == 0) // Only show this layout when on the first tab
            Align(
              alignment: Alignment.bottomCenter, // Align the image at the bottom
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationZ(-6.3 / 4), // Rotation angle
                child: Container(
                  height: 200.0, // Image height
                  width: 400.0, // Image width
                  margin: const EdgeInsets.only(top: 280.0, left: 100), // Position the image
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
        currentIndex: _selectedIndex, // Highlights the selected tab
        selectedItemColor: const Color.fromRGBO(61, 47, 40, 1), // Highlight color for the selected item
        onTap: _onItemTapped, // Handles tap events
      ),
    );
  }
}
