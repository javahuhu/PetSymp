import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:petsymp/loginaccount.dart';
import 'package:petsymp/signup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ✅ Background Image (Auto-Scaled)
          Positioned.fill(
            child: Image.asset(
              'assets/catlogin.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // ✅ Content Layer (on top of the background)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Logo Image (Auto-Scaled)
              Padding(
                padding: EdgeInsets.only(left: 0.w), // Auto-scaled left padding
                child: Image.asset(
                  'assets/logo.png',
                  width: 0.7.sw, // Auto-scale width (70% of screen width)
                  height: 0.3.sh, // Auto-scale height (30% of screen height)
                ),
              ),
              SizedBox(height: 0.161.sh), // Auto-scaled spacing

              // ✅ Welcome Text (Auto-Scaled)
              Padding(
              padding: EdgeInsets.only(
                left: 0.05.sw, // Auto-scaled left padding
               // Adjusts how high the text is (increase for more top)
              ),
              child: Text(
                'Welcome!',
                style: TextStyle(
                  fontSize: 32.sp, // Auto-scaled font size
                  fontWeight: FontWeight.bold,
                  color: const Color.fromRGBO(29, 29, 44, 1.0),
                ),
              ),
            ),

              SizedBox(height: 0.27.sh), // Auto-scaled spacing

              SizedBox(height: 0.03.sh), // Auto-scaled spacing

              // ✅ Log In Button (Auto-Scaled)
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginaccountScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(66, 134, 130, 1.0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.r), // Auto-scaled border radius
                    ),
                    fixedSize: Size(0.9.sw, 0.068.sh), // Auto-scaled size
                  ),
                  child: Text(
                    "Log In",
                    style: TextStyle(
                      fontSize: 22.sp, // Auto-scaled font size
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 0.01.sh), // Auto-scaled spacing

              // ✅ Create Account Button (Auto-Scaled)
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignupScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(66, 134, 130, 1.0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.r), // Auto-scaled border radius
                    ),
                    fixedSize: Size(0.9.sw, 0.068.sh), // Auto-scaled size
                  ),
                  child: Text(
                    "Create your account",
                    style: TextStyle(
                      fontSize: 22.sp, // Auto-scaled font size
                      fontWeight: FontWeight.bold,
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
}
