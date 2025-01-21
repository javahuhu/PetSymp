import 'package:flutter/material.dart';
import 'package:petsymp/homepage.dart';
import 'package:flutter/services.dart';

// Custom TextInputFormatter to capitalize only the first letter
class FirstLetterUpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue; // Return empty value
    }

    // Capitalize the first letter and keep the rest as-is
    final text = newValue.text;
    final firstLetter = text[0].toUpperCase();
    final restOfText = text.substring(1);

    return newValue.copyWith(
      text: firstLetter + restOfText,
      selection: newValue.selection,
    );
  }
}

class AssesmentScreen extends StatefulWidget {
  const AssesmentScreen({super.key});

  @override
  AssesmentScreenState createState() => AssesmentScreenState();
}

class AssesmentScreenState extends State<AssesmentScreen> {
  bool _isAnimated = false; // Animation toggle
  int _selectedIndex = 0; // State to track the selected tab
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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

  void navigateToNextPage() {
    if (_formKey.currentState?.validate() ?? false) {
      // Navigate only if the input is valid
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomePageScreen()),
      );
    }
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
                  duration: const Duration(seconds: 2),
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
                      const Text(
                        "Hi, I’m Etsy",
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.2, // Text and input below the paw
                  left: screenWidth * 0.12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Before we start your assessment,",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                      const Text(
                        "input your USERNAME first.",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: screenWidth * 0.8,
                        child: Form(
                          key: _formKey,
                          child: TextFormField(
                            controller: _controller,
                            autofillHints: const [AutofillHints.name],
                            inputFormatters: [
                              FirstLetterUpperCaseTextFormatter(),
                            ],
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              hintText: 'Enter your name',
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 20.0,
                                horizontal: 15.0,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your username';
                              }
                              if (value.length < 8) {
                                return "Username must contain at least 8 letters";
                              }
                              if (value.length != 8) {
                                return "Username must be exactly 8 characters";
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Next Button at the previous position
                Positioned(
                  top: 900,
                  left: 350,
                  child: ElevatedButton(
                    onPressed: navigateToNextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.black,
                      shadowColor: Colors.transparent,
                      side: const BorderSide(
                        color: Colors.black,
                        width: 2.0,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                      ),
                      fixedSize: const Size(100, 55),
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
