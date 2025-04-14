import 'package:flutter/material.dart';
import 'dart:async';
import 'LogIn/login.dart'; // For Timer and Future
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to the HomeScreen after 3 seconds
    Timer(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    });

    
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(decoration: const BoxDecoration(
          image: DecorationImage(
        fit: BoxFit.cover,
        image: AssetImage('assets/logindog.jpg',),
      )), 
      child: Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      // Logo Image (Adjusts with screen size)
      Image.asset(
        'assets/logo.png',
        width: screenWidth * 0.7,  // Adjust 70% of screen width
        height: screenHeight * 0.4, // Adjust height based on screen
      ),

      // Spacer to push progress indicator down dynamically
      const Spacer(),

      // Circular Progress Indicator - Responsive
      SizedBox(
        width: screenWidth * 0.12, // Make progress indicator responsive
        height: screenWidth * 0.12,
        child: const CircularProgressIndicator(
          strokeWidth: 4, // Responsive thickness
          valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 255, 255, 255)),
        ),
      ),

      // Small space before text
      const SizedBox(height: 10),

      // Loading Text
      const Text(
        'Loading',
        style: TextStyle(
          fontSize: 20,
          color: Color.fromARGB(255, 255, 255, 255),
        ),
      ),

      // Spacer to balance layout and avoid bottom overflow
      SizedBox(height: screenHeight * 0.02), 
    ],
  ),
),
),
    );
  }
}