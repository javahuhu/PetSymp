import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:petsymp/LogIn/getstarted.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart'; // Add Lottie package
import 'loginaccount.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProgressScreen extends StatefulWidget {
  final String username;
  final String password;

  const ProgressScreen({super.key, required this.username, required this.password});

  @override
  ProgressScreenState createState() => ProgressScreenState();
}

class ProgressScreenState extends State<ProgressScreen> with TickerProviderStateMixin {
  late AnimationController _lottieController;
  late AnimationController _progressController;

  bool _isAnimating = true;

  @override
  void initState() {
    super.initState();

    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..repeat(); // Repeat the animation

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _loginuser();
        }
      });

    _progressController.forward();
  }

  Future<void> _loginuser() async {
    try {
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection("Users")
          .where("Username", isEqualTo: widget.username.trim())
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        Fluttertoast.showToast(
          msg: "Username not found",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginaccountScreen()),
        );
        return;
      }

      var userDoc = query.docs.first;
      String email = userDoc["Email"];
      String userId = userDoc.id;

      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: widget.password.trim(),
      );

      if (userCredential.user != null && userCredential.user!.uid == userId) {
        setState(() {
         
          _isAnimating = false;
        });

        // Stop the animation
        _lottieController.stop();
        
        // Delay navigation to show success state
        Future.delayed(const Duration(milliseconds: 100), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const GetstartedScreen()),
          );
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        
        _isAnimating = false;
      });

      // Stop the animation
      _lottieController.stop();

      // Handle Wrong Password
      if (e.code == 'wrong-password') {
        Fluttertoast.showToast(
          msg: "Incorrect password",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
      // Handle User Not Found (Email not in Firebase Auth)
      else if (e.code == 'user-not-found') {
        Fluttertoast.showToast(
          msg: "User not found",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
      // Handle Other FirebaseAuth Errors
      else {
        Fluttertoast.showToast(
          msg: "Login Failed Wrong Username or Password",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }

      // Delay navigation to show error state
      Future.delayed(const Duration(milliseconds: 800), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginaccountScreen()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFE8F2F5),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Display runcat.lottie while animating, otherwise show success or error icon
                _isAnimating 
                  ? SizedBox(
                      width: 280.w,
                      height: 280.w,
                      child: Lottie.asset(
                        'assets/catcat.json',
                        controller: _lottieController,
                        fit: BoxFit.contain,
                      ),
                    )
                    : Text(""),
                
              
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _lottieController.dispose();
    _progressController.dispose();
    super.dispose();
  }
}