import 'package:flutter/material.dart';
import 'package:petsymp/settings.dart';
import 'package:petsymp/symptomscatalog.dart';
import 'profile.dart';
import 'cardpet.dart';
import 'petprofile.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  HomePageScreenState createState() => HomePageScreenState();
}

class HomePageScreenState extends State<HomePageScreen> {
  int _selectedIndex = 0; // State to track the selected tab
  bool _isAnimated = false; // Animation toggle
  bool _isNavigating = false; // Added for the navigation handling

  // Pages corresponding to each tab
  static const List<Widget> _pages = <Widget>[
    HomePageScreen(),
    Profilescreen(),
    PetProfileScreen(),
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

  // Method for symptom catalog navigation
  void _navigateToSymptomCatalog() async {
    if (_isNavigating) return;

    setState(() {
      _isNavigating = true;
    });

    // Navigate first, delay heavy loading AFTER the page transition begins
    Future.delayed(Duration.zero, () async {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SymptomscatalogScreen()),
      );

      setState(() {
        _isNavigating = false;
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
    return PopScope(
      canPop: false, // Prevent back navigation
      child: Scaffold(
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
                            "Hi, I'm Etsy",
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
                            MaterialPageRoute(builder: (context) => const CardpetScreen()),
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
              alignment: _isAnimated ? const Alignment(1.0, 0.9) : const Alignment(2, 1), 
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
        
        // Floating action button in the center of the bottom navigation
        floatingActionButton: Container(
          height: 56.h,
          width: 56.h,
          margin: EdgeInsets.only(top: 20.h), // Push it up to create overlap
          child: FloatingActionButton(
            onPressed: _navigateToSymptomCatalog,
            backgroundColor: const Color(0xFF5DBFB0),
            foregroundColor: Colors.black87,
            elevation: 4,
            shape: const CircleBorder(),
            child: const Icon(Icons.menu_book_sharp, size: 26),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        
        // Custom flat bottom navigation bar
        bottomNavigationBar: _buildFlatBottomNavBar(),
      ),
    );
  }
  
  // Custom bottom navigation bar with flat design
  Widget _buildFlatBottomNavBar() {
    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(29, 29, 44, 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // This creates the white line at the top of the navbar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Home
              _buildNavItem(0, Icons.home_rounded),
              
              // Profile
              _buildNavItem(1, Icons.person_rounded),
              
              // Center empty space for FAB
              SizedBox(width: 60.w),

              // Pets
              _buildNavItem(2, Icons.pets_sharp),
              
              // Settings
              _buildNavItem(3, Icons.settings_rounded),
            ],
          ),
        ],
      ),
    );
  }
  
  // Helper method to build a navigation item
  Widget _buildNavItem(int index, IconData icon) {
    final bool isSelected = _selectedIndex == index;
    
    return InkWell(
      onTap: () => _onItemTapped(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF5DBFB0) : Colors.white,
            size: isSelected ? 28 : 24,
          ),
          SizedBox(height: 4.h),
          Container(
            height: 2.h,
            width: 30.w,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF5DBFB0) : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}