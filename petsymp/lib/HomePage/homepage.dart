import 'package:flutter/material.dart';
import 'package:petsymp/Settings/settings.dart';
import 'package:petsymp/SymptomsCatalog/symptomscatalog.dart';
import 'profile.dart';
import 'package:petsymp/Assesment/cardpet.dart';
import '../PetProfile/petprofile.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class HomePageScreen extends StatefulWidget {
  final bool showSuccessDialog;
  const HomePageScreen({super.key, this.showSuccessDialog = false});

  @override
  HomePageScreenState createState() => HomePageScreenState();
}

class HomePageScreenState extends State<HomePageScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isAnimated = false;
  bool _isNavigating = false;
  bool _hasPlayedAnimation = false;
  late final AnimationController _control;

  static const List<Widget> _pages = <Widget>[
    HomePageScreen(),
    Profilescreen(),
    PetProfileScreen(),
    Settingscreen(),
  ];

  Future<bool?> _showTermsDialog(BuildContext context) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final userId = _auth.currentUser?.uid;

    if (userId != null) {
      final doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();
      final data = doc.data();

      if (data != null &&
          data['terms_status'] != null &&
          data['terms_status']['Terms'] == 'accept' &&
          data['terms_status']['dontshow'] == 'Yes') {
        return true;
      }
    }

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const TermsDialogContent(),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color.fromRGBO(36, 36, 55, 1),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 150.w,
                height: 150.w,
                child: Lottie.asset(
                  'assets/checkanimation.json',
                  fit: BoxFit.contain,
                  controller: _control,
                  onLoaded: (composition) {
                    _control.duration = composition.duration;
                    _control.forward();
                  },
                ),
              ),
              Text("Assessment Saved",
                  style: TextStyle(
                      color: const Color.fromRGBO(82, 170, 164, 1),
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 5.h),
              Text("Your assessment has been saved successfully!",
                  style: TextStyle(
                      color: const Color.fromRGBO(82, 170, 164, 1),
                      fontSize: 15.sp),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() => _isAnimated = true);
    });

    if (widget.showSuccessDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showSuccessDialog());
      _control =
          AnimationController(duration: const Duration(seconds: 3), vsync: this)
            ..forward();
    }
  }

  void _navigateToSymptomCatalog() async {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => const SymptomscatalogScreen()));
    setState(() => _isNavigating = false);
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFE8F2F5),
        body: Stack(
          children: [
            if (_selectedIndex == 0) ...[
              Positioned(
                top: 130.h,
                left: 30.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60.w,
                          height: 60.w,
                          decoration:
                              const BoxDecoration(shape: BoxShape.circle),
                          child: Image.asset('assets/paw.png',
                              fit: BoxFit.contain),
                        ),
                        SizedBox(width: 15.w),
                        Padding(
                          padding: EdgeInsets.only(top: 10.h),
                          child: DefaultTextStyle(
                            style: TextStyle(
                              fontSize: 27.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromRGBO(29, 29, 44, 1.0),
                            ),
                            child: _hasPlayedAnimation
                                ? const Text(
                                    "Hi, I'm Etsy") // After animation finishes, just static text
                                : AnimatedTextKit(
                                    animatedTexts: [
                                      TypewriterAnimatedText(
                                        "Hi, I'm Etsy",
                                        speed:
                                            const Duration(milliseconds: 200),
                                        cursor: '|',
                                      ),
                                    ],
                                    totalRepeatCount: 1,
                                    pause: const Duration(milliseconds: 200),
                                    displayFullTextOnTap: true,
                                    stopPauseOnTap: true,
                                    onFinished: () {
                                      setState(() {
                                        _hasPlayedAnimation = true;
                                      });
                                    },
                                  ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Text("I can help you in analyzing your",
                        style: TextStyle(
                            fontSize: 22.sp,
                            color: const Color.fromRGBO(29, 29, 44, 1.0))),
                    Text("Pet's health problems.",
                        style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromRGBO(29, 29, 44, 1.0))),
                    SizedBox(height: 55.h),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          bool? accepted = await _showTermsDialog(context);
                          if (accepted == true) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const CardpetScreen()));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF428682),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100.r)),
                          fixedSize: Size(250.w, 55.h),
                        ),
                        child: Text("Start Assessment",
                            style: TextStyle(
                                fontSize: 22.sp, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedAlign(
                alignment: _isAnimated
                    ? const Alignment(1.0, 0.9)
                    : const Alignment(2, 1),
                duration: const Duration(seconds: 2),
                curve: Curves.easeInOut,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationZ(-6.3 / 4),
                  child: Container(
                    height: 180.h,
                    width: 0.8.sw,
                    margin: EdgeInsets.only(top: 200.h, right: 5.w),
                    child: FittedBox(
                        fit: BoxFit.fill,
                        child: Image.asset("assets/catpeeking.png")),
                  ),
                ),
              ),
            ] else
              Center(child: _pages[_selectedIndex]),
          ],
        ),
        floatingActionButton: Container(
          height: 56.h,
          width: 56.h,
          margin: EdgeInsets.only(top: 20.h),
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
        bottomNavigationBar: _buildFlatBottomNavBar(),
      ),
    );
  }

  Widget _buildFlatBottomNavBar() {
    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(29, 29, 44, 1.0),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -3))
        ],
      ),
      child: Stack(
        children: [
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              child:
                  Container(height: 2, color: Colors.white.withOpacity(0.1))),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded),
              _buildNavItem(1, Icons.person_rounded),
              SizedBox(width: 60.w),
              _buildNavItem(2, Icons.pets_sharp),
              _buildNavItem(3, Icons.settings_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon) {
    final bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              color: isSelected ? const Color(0xFF5DBFB0) : Colors.white,
              size: isSelected ? 28 : 24),
          SizedBox(height: 4.h),
          Container(
            height: 2.h,
            width: 30.w,
            decoration: BoxDecoration(
                color:
                    isSelected ? const Color(0xFF5DBFB0) : Colors.transparent,
                borderRadius: BorderRadius.circular(2)),
          ),
        ],
      ),
    );
  }
}

class TermsDialogContent extends StatefulWidget {
  const TermsDialogContent({super.key});

  @override
  State<TermsDialogContent> createState() => _TermsDialogContentState();
}

class _TermsDialogContentState extends State<TermsDialogContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showTermsDialog());
  }

  Future<void> _showTermsDialog() async {
    bool localAccepted = false;
    bool localDontShowAgain = false;

    final FirebaseAuth auth = FirebaseAuth.instance;
    final userId = auth.currentUser?.uid;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Terms and Agreement"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 20.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Welcome!",
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 35.sp,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 25.h),
                          Text(
                              "These Terms and Conditions ('Terms') govern your use of the PetSymp mobile application and services. By accessing or using PetSymp, you agree to these Terms. If you do not agree, please do not use the app.",
                              style: TextStyle(
                                  fontFamily: 'Inter', fontSize: 13.sp)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 50.w, right: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Acceptance of Terms",
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 5.h),
                          Text(
                              "By using PetSymp, you confirm that you have read, understood, and agree to comply with these Terms.",
                              style: TextStyle(
                                  fontFamily: 'Inter', fontSize: 13.sp)),
                          SizedBox(height: 25.h),
                          Text("Description of Service",
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 5.h),
                          Text(
                              "PetSymp provides symptom analysis for pets based on user input. The app generates possible conditions and follow-up questions to refine the assessment. PetSymp does not provide medical diagnoses and should not replace professional veterinary advice.",
                              style: TextStyle(
                                  fontFamily: 'Inter', fontSize: 13.sp)),
                          SizedBox(height: 25.h),
                          Text("User Responsibilities",
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 5.h),
                          Text("By using PetSymp, you agree to:",
                              style: TextStyle(
                                  fontFamily: 'Inter', fontSize: 13.sp)),
                          SizedBox(height: 20.h),
                          _buildBullet(
                              "Provide accurate and truthful symptom information."),
                          SizedBox(height: 15.h),
                          _buildBullet(
                              "Use the app only for personal, non-commercial purposes."),
                          SizedBox(height: 15.h),
                          _buildBullet(
                              "Acknowledge that results are for informational purposes only and consult a veterinarian for medical concerns."),
                          SizedBox(height: 30.h),
                        ],
                      ),
                    ),
                    CheckboxListTile(
                      value: localAccepted,
                      onChanged: (val) =>
                          setState(() => localAccepted = val ?? false),
                      title: const Text("I agree to the Terms and Conditions"),
                      controlAffinity: ListTileControlAffinity.trailing,
                    ),
                    CheckboxListTile(
                      value: localDontShowAgain,
                      onChanged: (val) =>
                          setState(() => localDontShowAgain = val ?? false),
                      title: const Text("Don't Show This Again"),
                      controlAffinity: ListTileControlAffinity.trailing,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: localAccepted
                      ? () async {
                          if (userId != null) {
                            await FirebaseFirestore.instance
                                .collection('Users')
                                .doc(userId)
                                .set({
                              "terms_status": {
                                "Terms": "accept",
                                "dontshow": localDontShowAgain ? "Yes" : "No",
                              }
                            }, SetOptions(merge: true));
                          }
                          Navigator.of(context).pop(true);
                        }
                      : null,
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
    ).then((result) {
      Navigator.of(context).pop(result);
    });
  }

  Widget _buildBullet(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.arrow_forward, size: 20.sp, color: Colors.black),
        SizedBox(width: 8.w),
        Flexible(
            child: Text(text,
                style: TextStyle(fontFamily: 'Inter', fontSize: 13.sp))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
