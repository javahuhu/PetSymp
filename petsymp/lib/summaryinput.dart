import 'package:flutter/material.dart';
import 'package:petsymp/recommendationone.dart';
import 'userdata.dart';
import 'package:provider/provider.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  SummaryScreenState createState() => SummaryScreenState();
}

class SummaryScreenState extends State<SummaryScreen> {
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

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final userData = Provider.of<UserData>(context);
    String allSymptoms = [
  if (userData.selectedSymptom.isNotEmpty) userData.selectedSymptom, 
  if (userData.anotherSymptom.isNotEmpty) userData.anotherSymptom
  ].where((element) => element.isNotEmpty).join(" + ");

    return Scaffold(
      backgroundColor: const Color(0xFFCFCFCC),
      body: Stack(
        children: [
          if (_selectedIndex == 0)
            Stack(
              children: [
                // 🦴 Bones Background Image - **Placed at the Bottom**
                Positioned(
                  top: screenHeight * 0.2, // Adjusted so it's below yellow background
                  left: -screenWidth * 0.2,
                  child: Image.asset(
                    'assets/bonesbg.png',
                    height: 700,
                    width: 750,
                    fit: BoxFit.fill,
                  ),
                ),

                // 🟡 Yellow Background - Positioned **Above the Bones**
                Positioned(
                  top: 0, // Set at the **topmost** of the screen
                  left: 0,
                  right: 0,
                  child: Container(
                    width: screenWidth,
                    height: screenHeight * 0.25,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFDB58),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(100.0),
                        bottomRight: Radius.circular(100.0),
                      ),
                    ),
                    child: Stack(
                      children: [
                        // 🐾 Paw Image Inside Yellow Background
                        Positioned(
                          top: 40,
                          left: screenWidth * 0.17,
                          child: AnimatedOpacity(
                            duration: const Duration(seconds: 1),
                            opacity: _isAnimated ? 1.0 : 0.0,
                            child: Container(
                              width: screenWidth * 0.12,
                              height: screenWidth * 0.12,
                              decoration: const BoxDecoration(shape: BoxShape.circle),
                              child: Image.asset('assets/paw.png', fit: BoxFit.contain),
                            ),
                          ),
                        ),

                        // 📌 "Summary of Input" Title Inside Yellow Background
                        Positioned(
                          top: 60,
                          left: screenWidth * 0.35,
                          child: const Text(
                            "Summary of Input",
                            style: TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ⚫ Username Box - Positioned Above the Bones
                Positioned(
                  top: screenHeight * 0.13,
                  left: screenWidth * 0.12,
                  child: Container(
                    width: screenWidth * 0.76,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(223, 255, 255, 255),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 25,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        userData.userName,
                        style: const TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                  ),
                ),

                 Positioned(
                  top: screenHeight * 0.25,
                  left: screenWidth * 0.085,
                  child: Container(
                    width: 400,
                    height: screenHeight * 0.58,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(131, 255, 255, 255), // Set Background Color
                      borderRadius: BorderRadius.circular(15), // Optional rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1), // Light shadow
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10), // Add padding inside container
                      child: ListView(
                        children: [
                          _buildInputCard("🎂", "Age", ""),
                          _buildInputCard("📏", "Height", userData.height.toString()),
                          _buildInputCard("⚖️", "Weight", userData.weight.toString()),
                          _buildInputCard("🐶", "Breed", userData.breed),
                          _buildInputCard("🤕", "Symptoms", allSymptoms),
                        ],
                      ),
                    ),
                  ),
),


                // ✅ Proceed Button (Same Style & Position)
                buildAnimatedButton(
                  screenHeight * 1.02,
                  screenWidth,
                  0.85,
                  "Proceed",
                  const RecommendationoneScreen(),
                  1,
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromRGBO(61, 47, 40, 1),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
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

  Widget _buildInputCard(String emoji, String label, String value) {
  return Card(
    elevation: 3,
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Aligns text and trailing
        children: [
          // Leading Icon & Text
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ],
              ),
            ],
          ),
          
          // **Trailing Icon (Example: Edit Icon)**
          const Icon(Icons.check, color:  Color.fromARGB(255, 21, 180, 0)),
        ],
      ),
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
      left: screenWidth * 0.45 - 50,
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
                          return const Color.fromARGB(255, 255, 255, 255); // Background color when pressed
                        }
                        return const Color.fromRGBO(61, 47, 40, 1); // Default background color
                      },
                    ),
                    // Dynamic text color based on button state
                    foregroundColor: WidgetStateProperty.resolveWith(
                      (states) {
                        if (states.contains(WidgetState.pressed)) {
                          return const Color.fromARGB(255, 0, 0, 0); // Text color when pressed
                        }
                        return const Color.fromARGB(255, 255, 255, 255); // Default text color
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
                      const Size(155, 55),
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
