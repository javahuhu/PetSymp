import 'package:flutter/material.dart';
import 'package:petsymp/settings.dart';
import 'assesment.dart';
import 'profile.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    Icon(Icons.home, size: 150),
    Profilescreen(),
    Settingscreen(),
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _isAnimated = true;
      });
    });
  }

  // Method to handle bottom navigation tab changes
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F2F5),
      body: Stack(
        children: [
          // Circular Image and Texts
          if (_selectedIndex == 0)
            Positioned(
              top: 130.h, // Responsive height
              left: 30.w, // Responsive width
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Circular Image
                      Container(
                        width: 60.w, // Responsive width
                        height: 60.w, // Keep square
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: Image.asset('assets/paw.png', fit: BoxFit.contain),
                      ),
                      SizedBox(width: 15.w), // Responsive spacing

                      // Text beside the image
                      Padding(
                        padding: EdgeInsets.only(top: 10.h),
                        child: Text(
                          "Hi, I’m Etsy",
                          style: TextStyle(
                            fontSize: 27.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromRGBO(29, 29, 44, 1.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h), // Responsive spacing

                  // Long Text Below the Image and First Text
                  Text(
                    "I can help you to analyze your pet ",
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.normal,
                      color: const Color.fromRGBO(29, 29, 44, 1.0),
                    ),
                  ),
                  Text(
                    "health issues.",
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromRGBO(29, 29, 44, 1.0),
                    ),
                  ),

                  SizedBox(height: 55.h), // Adjusted spacing
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AssesmentScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF428682),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.r),
                        ),
                        fixedSize: Size(250.w, 55.h),
                      ),
                      child: Text(
                        "Start Assessment",
                        style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Rotated Image Positioned at the Bottom with Animation
          if (_selectedIndex == 0)
              AnimatedAlign(
            alignment: _isAnimated ? Alignment(1.0, 0.9) : Alignment(2, 1), 
            // 🔹 Moves the image further right when animated
            
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationZ(-6.3 / 4),
              child: Container(
                height: 180.h, // Responsive height
                width: 0.8.sw, // 80% of screen width
                margin: EdgeInsets.only(top: 200.h, right: 5.w), 
                // 🔹 Adds small right margin to prevent it from overflowing
                
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Image.asset("assets/catpeeking.png"),
                ),
              ),
            ),
          ),


          // Placeholder for other tabs
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
        selectedItemColor: const Color.fromRGBO(82, 170, 164, 1),
        unselectedItemColor: const Color.fromARGB(255, 255, 255, 255),
        onTap: _onItemTapped,
        backgroundColor: const Color.fromRGBO(29, 29, 44, 1.0),
      ),
    );
  }
}
