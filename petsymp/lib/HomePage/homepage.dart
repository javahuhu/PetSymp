import 'package:flutter/material.dart';
import 'package:petsymp/Settings/settings.dart';
import 'package:petsymp/SymptomsCatalog/symptomscatalog.dart';
import 'profile.dart';
import 'package:petsymp/Assesment/cardpet.dart';
import '../PetProfile/petprofile.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<bool?> _showTermsDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const TermsDialogContent(),
  );
}


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
                        onPressed: () async {
                          bool? accepted = await _showTermsDialog(context);

                          if(accepted == true) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CardpetScreen()),
                          ); }

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



class TermsDialogContent extends StatefulWidget {
  const TermsDialogContent({Key? key}) : super(key: key);
  @override
  _TermsDialogContentState createState() => _TermsDialogContentState();
}

class _TermsDialogContentState extends State<TermsDialogContent> {
  bool accepted1 = false;
 
  
  @override
  void initState() {
    super.initState();
    _CheckDontShowAgain();
  }

    @override
  Widget build(BuildContext context) {
    return const SizedBox(); 
  }


 Future<void> _CheckDontShowAgain() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? dontShowAgain = prefs.getBool('dontShowAgain') ?? false;

  if (dontShowAgain != true) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bool? accepted = await _showTermsAgain(context);
      Navigator.of(context).pop(accepted); // ✅ send result back to HomePageScreen
    });
  } else {
    Navigator.of(context).pop(true); // ✅ Auto-accept if don'tShowAgain is true
  }
}
    

  Future<bool?> _showTermsAgain(BuildContext context) async {
  bool localAccepted = false;
  bool localDontShowAgain = false;

  return await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text("Terms and Agreement"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                   Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h), // responsive left/right padding
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // ⬅️ aligns text to the left
                        children: [
                          Text(
                            "Welcome!",
                            style: TextStyle(fontFamily: 'Inter', fontSize: 35.sp, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 25.h),
                          Text(
                            "These Terms and Conditions ('Terms') govern your use of the PetSymp mobile application and services. By accessing or using PetSymp, you agree to these Terms. If you do not agree, please do not use the app.",
                            style: TextStyle(fontFamily: 'Inter', fontSize: 13.sp),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 50.w, right: 20.w), // responsive left/right padding
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // ⬅️ aligns text to the left
                        children: [
                          Text(
                            "Acceptance of Terms",
                            style: TextStyle(fontFamily: 'Inter', fontSize: 18.sp, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            "By using PetSymp, you confirm that you have read, understood, and agree to comply with these Terms.",
                            style: TextStyle(fontFamily: 'Inter', fontSize: 13.sp),
                          ),
                          SizedBox(height: 25.h),
                          Text(
                            "Description of Service",
                            style: TextStyle(fontFamily: 'Inter', fontSize: 18.sp, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            "PetSymp provides symptom analysis for pets based on user input. The app generates possible conditions and follow-up questions to refine the assessment. PetSymp does not provide medical diagnoses and should not replace professional veterinary advice.",
                            style: TextStyle(fontFamily: 'Inter', fontSize: 13.sp),
                          ),
                          SizedBox(height: 25.h),
                          Text(
                            "User Responsibilities",
                            style: TextStyle(fontFamily: 'Inter', fontSize: 18.sp, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            "By using PetSymp, you agree to:",
                            style: TextStyle(fontFamily: 'Inter', fontSize: 13.sp),
                          ),

                          SizedBox(height: 20.h),
                          Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.arrow_forward,
                          size: 20.sp,
                          color: Colors.black,
                        ),
                        SizedBox(width: 8.w), // spacing between icon and text
                        Flexible(
                          child: Text(
                            "Provide accurate and truthful symptom information.",
                            style: TextStyle(fontFamily: 'Inter', fontSize: 13.sp),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Icon(
                          Icons.arrow_forward,
                          size: 20.sp,
                          color: Colors.black,
                        ),
                        SizedBox(width: 8.w), // spacing between icon and text
                        Flexible(
                          child: Text(
                            "Use the app only for personal, non-commercial purposes.",
                            style: TextStyle(fontFamily: 'Inter', fontSize: 13.sp),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.arrow_forward,
                          size: 20.sp,
                          color: Colors.black,
                        ),
                        SizedBox(width: 8.w), // spacing between icon and text
                        Flexible(
                          child: Text(
                            "Acknowledge that results are for informational purposes only and consult a veterinarian for medical concerns.",
                            style: TextStyle(fontFamily: 'Inter', fontSize: 13.sp),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30.h),
                      ],
                      ),
                    ),

                  CheckboxListTile(
                    value: localAccepted,
                    onChanged: (val) => setState(() => localAccepted = val ?? false),
                    title: const Text("I agree to the Terms and Conditions"),
                  ),
                  CheckboxListTile(
                    value: localDontShowAgain,
                    onChanged: (val) => setState(() => localDontShowAgain = val ?? false),
                    title: const Text("Don't Show This Again"),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (localAccepted) {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('dontShowAgain', localDontShowAgain);
                    Navigator.of(context).pop(true); // ✅ Returns true!
                  }
                },
                child: const Text("Proceed"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancel"),
              ),
            ],
          );
        },
      );
    },
  );
}

}

