import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../userdata.dart';
import 'heightweight.dart';

class AgeinputScreen extends StatefulWidget {
  const AgeinputScreen({super.key});
  @override
  State<AgeinputScreen> createState() => _AgeinputScreenState();
}

class _AgeinputScreenState extends State<AgeinputScreen>
    with SingleTickerProviderStateMixin {
  bool _isAnimated = false;
  late AnimationController _bubbleAnimationController;
  DateTime selectedDate = DateTime.now();
  int ageInYears = 0;

  @override
  @override
  void initState() {
    super.initState();
    _bubbleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    // ✅ Trigger the animation after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isAnimated = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _bubbleAnimationController.dispose();
    super.dispose();
  }

  int _calculateAge(DateTime birthDate) {
    DateTime now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context, listen: false);
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(225, 240, 243, 1.0),
              Color.fromRGBO(201, 229, 231, 1.0),
              Color(0xFFE8F2F5),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // ⬇ Decorative bubbles here (same as your previous code)
            // Example bubble:
            // Large wave-like shape at the top
            Positioned(
              top: -screenHeight * 0.2,
              left: -screenWidth * 0.25,
              child: AnimatedBuilder(
                animation: _bubbleAnimationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      0,
                      _bubbleAnimationController.value * 10,
                    ),
                    child: Container(
                      width: screenWidth * 1.5,
                      height: screenHeight * 0.5,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(66, 134, 129, 0.07),
                        borderRadius:
                            BorderRadius.circular(screenHeight * 0.25),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Smaller wave-like shape in bottom-right
            Positioned(
              bottom: -screenHeight * 0.1,
              right: -screenWidth * 0.25,
              child: AnimatedBuilder(
                animation: _bubbleAnimationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      0,
                      -_bubbleAnimationController.value * 10,
                    ),
                    child: Container(
                      width: screenWidth * 0.9,
                      height: screenHeight * 0.3,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(66, 134, 129, 0.08),
                        borderRadius:
                            BorderRadius.circular(screenHeight * 0.15),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Middle-left floating bubble
            Positioned(
              top: screenHeight * 0.45,
              left: screenWidth * 0.05,
              child: AnimatedBuilder(
                animation: _bubbleAnimationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      _bubbleAnimationController.value * 5,
                      _bubbleAnimationController.value * 8,
                    ),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color.fromRGBO(66, 134, 129, 0.2),
                        border: Border.all(
                          color: const Color.fromRGBO(66, 134, 129, 0.3),
                          width: 1.5,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Middle-right small floating circle
            Positioned(
              top: screenHeight * 0.6,
              right: screenWidth * 0.1,
              child: AnimatedBuilder(
                animation: _bubbleAnimationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      -_bubbleAnimationController.value * 8,
                      -_bubbleAnimationController.value * 6,
                    ),
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Color.fromRGBO(72, 138, 163, 0.3),
                            Color.fromRGBO(72, 138, 163, 0.1),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Small dot pattern top-right
            Positioned(
              top: screenHeight * 0.25,
              right: screenWidth * 0.15,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromRGBO(72, 138, 163, 0.4),
                ),
              ),
            ),
            Positioned(
              top: screenHeight * 0.26,
              right: screenWidth * 0.2,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromRGBO(72, 138, 163, 0.3),
                ),
              ),
            ),
            Positioned(
              top: screenHeight * 0.28,
              right: screenWidth * 0.17,
              child: Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromRGBO(72, 138, 163, 0.3),
                ),
              ),
            ),

            // Small dot pattern bottom-left
            Positioned(
              bottom: screenHeight * 0.15,
              left: screenWidth * 0.2,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromRGBO(66, 134, 129, 0.5),
                ),
              ),
            ),
            Positioned(
              bottom: screenHeight * 0.14,
              left: screenWidth * 0.25,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromRGBO(66, 134, 129, 0.4),
                ),
              ),
            ),
            Positioned(
              bottom: screenHeight * 0.16,
              left: screenWidth * 0.22,
              child: Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromRGBO(66, 134, 129, 0.4),
                ),
              ),
            ),

            AnimatedPositioned(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              top: _isAnimated ? screenHeight * 0.12 : -100, // From off-screen
              left: screenWidth * 0.04,
              child: Container(
                width: screenWidth * 0.15,
                height: screenWidth * 0.15,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(66, 134, 129, 0.2),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/paw.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.2),
                  Text(
                    "When was your pet born?",
                    style: TextStyle(
                      fontSize: 25.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Oswald',
                      color: const Color.fromRGBO(29, 29, 44, 1.0),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Cupertino Date Picker
                  SizedBox(
                    height: 300.h,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime:
                          DateTime.now().subtract(const Duration(days: 365)),
                      maximumDate: DateTime.now(),
                      onDateTimeChanged: (DateTime newDate) {
                        setState(() {
                          selectedDate = newDate;
                          ageInYears = _calculateAge(newDate);
                          userData.setpetAge(ageInYears);
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Center(
                      child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 60),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.pets_rounded,
                          color: const Color.fromRGBO(66, 134, 129, 1.0),
                          size: 24.sp,
                        ),
                        SizedBox(width: 12.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: 4),
                            Text(
                              "$ageInYears years",
                              style: TextStyle(
                                fontSize: 20.sp,
                                color: const Color.fromRGBO(66, 134, 129, 1.0),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ))
                ],
              ),
            ),

            Positioned(
              top: screenHeight * 0.9,
              right: screenWidth * 0.03, 
              child: SlideInUp(
                duration: const Duration(milliseconds: 1000),
                delay: const Duration(milliseconds: 300),
                from: 400,
                child: SizedBox(
                  width: 125.w, 
                  child: GestureDetector(
                    onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MeasureinputScreen()),
                  );
                },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 60.h,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromRGBO(82, 170, 164, 1),
                            Color.fromRGBO(82, 170, 164, 1)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30.r),
                        
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                              padding: EdgeInsets.only(left: 5.w),
                              child: Text(
                                "Next",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              )),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 22.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
