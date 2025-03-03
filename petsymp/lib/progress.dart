import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:petsymp/getstarted.dart';
import 'package:petsymp/loginaccount.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection("Users")
          .where("Username", isEqualTo: widget.username)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        setState(() {
          _isSuccessful = false; 
        });
      } else {
        firestorePassword = query.docs.first["Password"];
        setState(() {
          _isSuccessful = _checkLoginCredentials(); 
        });
      }

      _rotationController.stop(); 

      Future.delayed(const Duration(seconds: 1), () {
        if (_isSuccessful) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const GetstartedScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginaccountScreen()),
          );
        }
      });
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Log in Failed")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  bool _checkLoginCredentials() {
    return firestorePassword != null && widget.password == firestorePassword;
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
            top: screenHeight * 0.62,
            left: screenWidth  * 0.325,
            child:  const 
              Text(
              'Validating...',
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
            ),

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
