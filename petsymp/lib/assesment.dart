import 'package:flutter/material.dart';

class AssesmentScreen extends StatefulWidget {
  const AssesmentScreen({super.key});

  @override
  AssesmentScreenState createState() => AssesmentScreenState();
}

class AssesmentScreenState extends State<AssesmentScreen> {
  int _selectedIndex = 0; // State to track the selected tab

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
    // Screen dimensions
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFCFCFCC),
      body: Stack(
        children: [
          // Circular Image and Texts
          if (_selectedIndex == 0) // Only show this layout when on the first tab
            Positioned(
              top: screenHeight * 0.13, // 13% from the top of the screen
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
                            fontWeight: FontWeight.bold, // Make the text bold
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02), // 2% of screen height for spacing

                  // Long Text Below the Image and First Text
                  const Text(
                    "Before we start your assessment,",
                    style: TextStyle(
                      fontSize: 22, // Adjust font size
                      fontWeight: FontWeight.normal,
                      color: Colors.black, // Normal font weight for description
                    ),
                  ),
                  const Text(
                    "input your USERNAME first.",
                    style: TextStyle(
                      color: Colors.black, // Text color
                      fontSize: 22, // Adjust font size
                      fontWeight: FontWeight.bold, // Normal font weight for description
                    ),
                  ),

                  // TextField for input
                  Padding(
                    padding: EdgeInsets.only(top: screenHeight * 0.03), // Add spacing above the TextField
                    child: SizedBox(
                      width: screenWidth * 0.8, // 80% of screen width
                      child: TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          hintText: 'Enter your username',
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 10.0),
                        ),
                      ),
                    ),
                  ),



                 // Positioned Elevated Button
          Padding(
                    padding: const EdgeInsets.fromLTRB(300, 520, 0, 0), // Add padding for spacing
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
                        backgroundColor: Colors.transparent, // Transparent background
                        foregroundColor: Colors.black, // Text color
                        shadowColor: Colors.transparent, // No shadow
                        side: const BorderSide( // Border properties
                          color: Colors.black, // Border color
                          width: 2.0, // Border width
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100), // Rounded corners
                        ),
                        fixedSize: const Size(100, 55), // Button size
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
        unselectedItemColor: Colors.grey, // Unselected tab color
        onTap: _onItemTapped, // Handles tab selection
      ),
    );
  }
}
