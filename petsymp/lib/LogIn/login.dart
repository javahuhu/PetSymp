import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:petsymp/LogIn/loginaccount.dart';
import 'package:petsymp/SignUp/signup.dart';

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
        
          Positioned.fill(
            child: Image.asset(
              'assets/catlogin.jpg',
              fit: BoxFit.cover,
            ),
          ),

        
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Logo Image (Auto-Scaled)
              Padding(
                padding: EdgeInsets.only(left: 0.w), 
                child: Image.asset(
                  'assets/logo.png',
                  width: 0.7.sw, 
                  height: 0.3.sh, 
                ),
              ),
              SizedBox(height: 0.161.sh), 

              // ✅ Welcome Text (Auto-Scaled)
              Padding(
              padding: EdgeInsets.only(
                left: 0.05.sw, 
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

              SizedBox(height: 0.27.sh), 

              SizedBox(height: 0.03.sh), 

              
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
                      fontSize: 22.sp, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 0.01.sh),

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
                      borderRadius: BorderRadius.circular(50.r), 
                    ),
                    fixedSize: Size(0.9.sw, 0.068.sh), 
                  ),
                  child: Text(
                    "Create your account",
                    style: TextStyle(
                      fontSize: 22.sp, 
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