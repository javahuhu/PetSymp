import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;
import 'dart:async'; // <-- Added for Timer
import 'package:provider/provider.dart';
import '../userdata.dart';
import 'changepassword.dart';
import 'dart:ui'; 

class RecoveryScreen extends StatefulWidget {
  const RecoveryScreen({Key? key}) : super(key: key);

  @override
  RecoveryScreenState createState() => RecoveryScreenState();
}

class RecoveryScreenState extends State<RecoveryScreen> with TickerProviderStateMixin {
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  // Timer and Resend logic
  Timer? _timer;
  int _timeRemaining = 60;
  bool _canResend = false;

  // Bubble Animation
  final List<AnimationController> _bubbleControllers = [];
  final List<Animation<double>> _bubbleAnimations = [];
  final List<BubbleProps> _bubbles = [];
  final int _numberOfBubbles = 15;

  @override
  void initState() {
    super.initState();
    _startTimer(); // Start countdown when screen opens

    for (int i = 0; i < _numberOfBubbles; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 3000 + math.Random().nextInt(5000)),
      );
      _bubbleControllers.add(controller);
      _bubbleAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: controller, curve: Curves.easeInOut),
        ),
      );
    }
    _generateBubbles();
    for (var controller in _bubbleControllers) {
      controller.repeat(reverse: true);
    }
  }

  void _generateBubbles() {
    final random = math.Random();
    for (int i = 0; i < _numberOfBubbles; i++) {
      _bubbles.add(BubbleProps(
        size: 10.0 + random.nextDouble() * 40.0,
        posX: random.nextDouble(),
        posY: random.nextDouble() * 0.6,
        opacity: 0.1 + random.nextDouble() * 0.2,
        color: i % 2 == 0 
            ? const Color(0xFF52AAA4).withOpacity(0.3)
            : const Color(0xFF1D1D2C).withOpacity(0.2),
      ));
    }
  }

  void _startTimer() {
    _timeRemaining = 60;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() {
          _timeRemaining--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        _timer?.cancel();
      }
    });
  }

  void _resendCode() {
    final userData = Provider.of<UserData>(context, listen: false);
    final email = userData.email;
    final newOtp = (math.Random().nextInt(900000) + 100000).toString();
    userData.setOtpCode(newOtp);

    userData.sendOtpToEmail(email, newOtp).then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A new code has been sent to your email!')),
        );
        for (var controller in _otpControllers) {
          controller.clear(); // Clear OTP boxes after resend
        }
        _startTimer();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to resend code. Please try again.')),
        );
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _bubbleControllers) {
      controller.dispose();
    }
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel(); // Cancel timer on dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFE8F2F5),
      body: Stack(
        children: [
          ..._buildBubbles(screenWidth, screenHeight),
          Positioned(
            top: screenHeight * 0.03,
            left: screenWidth * 0.01,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Icons.arrow_back_ios_new, color: const Color.fromRGBO(61, 47, 40, 1), size: 26.sp),
              label: const Text(''),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.transparent),
                elevation: WidgetStateProperty.all(0),
                shadowColor: WidgetStateProperty.all(Colors.transparent),
                overlayColor: WidgetStateProperty.all(Colors.transparent),
              ),
            ),
          ),
          Stack(
            children: [
              Positioned(
                bottom: 0.h,
                left: 0.w,
                right: 0.w,
                child: Container(
                  height: 422.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40.r),
                      topRight: Radius.circular(40.r),
                    ),
                    color: const Color.fromRGBO(29, 29, 44, 1.0),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 50.h),
                      Text(
                        "Validation Code",
                        style: TextStyle(
                          fontFamily: 'Oswald',
                          fontSize: 30.sp,
                          color: const Color.fromARGB(255, 230, 227, 227),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        "Check your email inbox and enter the",
                        style: TextStyle(fontSize: 17.sp, color: const Color.fromARGB(255, 177, 175, 175)),
                      ),
                      Text(
                        "validation code here",
                        style: TextStyle(fontSize: 17.sp, color: const Color.fromARGB(255, 177, 175, 175)),
                      ),
                      SizedBox(height: 30.h),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(6, (index) => _buildOtpBox(index)),
                        ),
                      ),
                      SizedBox(height: 40.h),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            String enteredOtp = _otpControllers.map((c) => c.text).join();
                            final userData = Provider.of<UserData>(context, listen: false);
                            if (enteredOtp == userData.otpCode) {
                              if (enteredOtp.length != 6) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please enter the full 6-digit OTP.')),
                                );
                                return;
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ChangepasswordScreen()),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Incorrect OTP. Please try again.')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(82, 170, 164, 1),
                            foregroundColor: Colors.white,
                            elevation: 4,
                            fixedSize: const Size(350, 55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            "Confirm",
                            style: TextStyle(fontSize: 22.0.sp, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _canResend ? "Didn't receive it?" : "Code expires in $_timeRemaining s",
                              style: TextStyle(fontSize: 16.sp, color: Colors.white),
                            ),
                            SizedBox(width: 8.w),
                            TextButton(
                              onPressed: _canResend ? _resendCode : null,
                              child: Text(
                                "Resend",
                                style: TextStyle(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.bold,
                                  color: _canResend ? const Color.fromRGBO(82, 170, 164, 1) : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: lerpDouble(93.h, -0.9.sh, keyboardHeight / screenHeight) ?? 90.h,
                left: (0.85.sw - 0.87.sw) / 2,
                child: Container(
                  height: 0.37.sh,
                  width: 0.95.sw,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/petwithowner.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: lerpDouble(350.h, -0.6.sh, keyboardHeight / screenHeight) ?? 90.h,
                left: screenWidth * 0.387,
                child: Container(
                  height: 85.w,
                  width: 85.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100.r),
                    color: const Color.fromRGBO(29, 29, 44, 1.0),
                  ),
                  child: Center(
                    child: Container(
                      height: 65.w,
                      width: 65.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100.r),
                        border: Border.all(color: Colors.white, width: 3),
                        color: const Color.fromRGBO(29, 29, 44, 1.0),
                      ),
                      child: Center(
                        child: Container(
                          height: 30.h,
                          width: 30.w,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/scanner.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBubbles(double screenWidth, double screenHeight) {
    List<Widget> bubbleWidgets = [];
    for (int i = 0; i < _bubbles.length; i++) {
      final bubble = _bubbles[i];
      bubbleWidgets.add(
        AnimatedBuilder(
          animation: _bubbleAnimations[i],
          builder: (context, child) {
            final yOffset = _bubbleAnimations[i].value * 20.0;
            return Positioned(
              left: bubble.posX * screenWidth,
              top: (bubble.posY * screenHeight) - yOffset,
              child: Opacity(
                opacity: bubble.opacity,
                child: Container(
                  width: bubble.size,
                  height: bubble.size,
                  decoration: BoxDecoration(
                    color: bubble.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
    return bubbleWidgets;
  }

  Widget _buildOtpBox(int index) {
    return Container(
      width: 50.w,
      margin: EdgeInsets.symmetric(horizontal: 5.w),
      child: TextFormField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: Colors.white),
        decoration: InputDecoration(
          counterText: "",
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color.fromRGBO(82, 170, 164, 1), width: 2),
            borderRadius: BorderRadius.circular(10.r),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color.fromARGB(255, 137, 104, 161), width: 3),
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < _otpControllers.length - 1) {
              FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
            } else {
              FocusScope.of(context).unfocus();
            }
          }
        },
      ),
    );
  }
}

class BubbleProps {
  final double size;
  final double posX;
  final double posY;
  final double opacity;
  final Color color;

  BubbleProps({
    required this.size,
    required this.posX,
    required this.posY,
    required this.opacity,
    required this.color,
  });
}
