import 'package:flutter/material.dart';
import 'QuestionDiseasesone/questionone.dart';
import 'package:provider/provider.dart';
import 'userdata.dart';

class AnothersearchsymptomsScreen extends StatefulWidget {
  const AnothersearchsymptomsScreen({super.key});

  @override
  AnothersearchsymptomsScreenState createState() =>
      AnothersearchsymptomsScreenState();
}

class AnothersearchsymptomsScreenState extends State<AnothersearchsymptomsScreen> {
  bool _isAnimated = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _isAnimated = true;
      });
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
    final userData = Provider.of<UserData>(context);

  String allSymptoms = [
  if (userData.selectedSymptom.isNotEmpty) userData.selectedSymptom, // ✅ Correct: selectedSymptom is a string
  if (userData.anotherSymptom.isNotEmpty) userData.anotherSymptom
].where((element) => element.isNotEmpty).join(" + "); // ✅ Prevents empty strings
 // Avoid empty strings

    return Scaffold(
      backgroundColor: const Color(0xFFCFCFCC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: screenHeight + 25,
              width: screenWidth,
              child: Stack(
                children: [
                  if (_selectedIndex == 0) ...[
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
                          SizedBox(width: screenWidth * 0.02),
                          Padding(
                            padding: EdgeInsets.only(top: screenHeight * 0.03),
                            child: const Text(
                              "Select Another Symptoms",
                              style: TextStyle(
                                fontSize: 27,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Symptoms List
                    Positioned(
                      top: screenHeight * 0.25,
                      left: screenWidth * 0.05,
                      right: screenWidth * 0.05,
                      child: buildSymptomsContainer(
                        screenWidth,
                        allSymptoms.isNotEmpty ? allSymptoms : "Select Another Symptoms",
                        ["Drooling or licking lips excessively before", "or after vomiting."],
                        const QoneScreen(),
                      ),
                    ),
                    Positioned(
                      top: screenHeight * 0.45,
                      left: screenWidth * 0.05,
                      right: screenWidth * 0.05,
                      child: buildSymptomsContainer(
                        screenWidth,
                        "Frequent Bowel Movements",
                        ["Loose, watery stools."],
                        const QoneScreen(),
                      ),
                    ),
                    Positioned(
                      top: screenHeight * 0.628,
                      left: screenWidth * 0.05,
                      right: screenWidth * 0.05,
                      child: buildSymptomsContainer(
                        screenWidth,
                        "Frequent Episodes",
                        ["Repeated vomiting over a short period"],
                        const QoneScreen(),
                      ),
                    ),
                  ],
                  if (_selectedIndex != 0)
                    Center(
                      child: _pages.elementAt(_selectedIndex),
                    ),
                ],
              ),
            ),
          ],
        ),
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

  Widget buildSymptomsContainer(double screenWidth, String title,
      List<String> details, Widget navigate) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 250, 249, 249),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          for (String detail in details)
            Text(
              detail,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => navigate),
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
                  const Size(120, 45),
                ),
              ),
              child: const Text(
                "Select",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
