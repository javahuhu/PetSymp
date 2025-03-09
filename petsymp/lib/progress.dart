import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:petsymp/getstarted.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'loginaccount.dart';
import 'package:responsive_framework/responsive_framework.dart';
class ProgressScreen extends StatefulWidget {
  final String username;
  final String password;

  const ProgressScreen({super.key, required this.username, required this.password});

  @override
  ProgressScreenState createState() => ProgressScreenState();
}

class ProgressScreenState extends State<ProgressScreen> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _progressController;
  String? firestorePassword;
  bool _isSuccessful = false;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _loginuser(); // ✅ Call login validation directly
        }
      });

    _progressController.forward(); // Start animation
  }


  Future<void> _loginuser() async {
  try {
    // ✅ Step 1: Find the user by Username in Firestore
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection("Users")
        .where("Username", isEqualTo: widget.username.trim()) // Trim for safety
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

      // ✅ Redirect back to login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginaccountScreen()),
      );
      return;
    }

    // ✅ Step 2: Get the user's email from Firestore
    var userDoc = query.docs.first;
    String email = userDoc["Email"];
    String userId = userDoc.id;

    // ✅ Step 3: Authenticate using Firebase Auth
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: widget.password.trim(),
    );

    // ✅ Step 4: Ensure authenticated user matches Firestore user
    if (userCredential.user != null && userCredential.user!.uid == userId) {
      setState(() {
        _isSuccessful = true;
      });

      // ✅ Redirect to GetStartedScreen after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GetstartedScreen()),
      );
    } 
  } on FirebaseAuthException catch (e) {
    setState(() {
      _isSuccessful = false;
    });

    // ✅ Handle Wrong Password
    if (e.code == 'wrong-password') {
      Fluttertoast.showToast(
        msg: "Incorrect password",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } 
    // ✅ Handle User Not Found (Email not in Firebase Auth)
    else if (e.code == 'user-not-found') {
      Fluttertoast.showToast(
        msg: "User not found",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } 
    // ✅ Handle Other FirebaseAuth Errors
    else {
      Fluttertoast.showToast(
        msg: "Login Failed Wrong Username or Password",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }

    // ✅ Redirect back to login screen after failed login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginaccountScreen()),
    );
  }
}




  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFE8F2F5),
      body: Stack(
        children: [
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: AnimatedBuilder(
                    animation: _rotationController,
                    builder: (context, child) {
                      return CircularProgressIndicator(
                        value: _progressController.value,
                        strokeWidth: 15,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _progressController.isAnimating
                              ? HSLColor.fromAHSL(1.0, _rotationController.value * 360, 1.0, 0.5).toColor()
                              : (_isSuccessful ? Colors.green : Colors.red), // ✅ Correct color updates
                        ),
                        backgroundColor: Colors.grey[300],
                      );
                    },
                  ),
                ),
                Icon(
                  _progressController.isAnimating
                      ? Icons.more_horiz
                      : (_isSuccessful ? Icons.check : Icons.close), // ✅ Change based on success
                  size: 100,
                  color: _progressController.isAnimating
                      ? Colors.blue
                      : (_isSuccessful ? Colors.green : Colors.red),
                ),
              ],
            ),
          ),
           Positioned(
            top: screenHeight * 0.65, // Default height: 50% of screen height
            left: 0,
            right: 0,
            child: const Center( 
            child:  Column(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
              'Validating',
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
            ),

            ],))


            

          ),
          
        ],
      ),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _progressController.dispose();
    super.dispose();
  }
}
