import 'package:flutter/material.dart';
import 'dart:async';
import 'login.dart'; // For Timer and Future

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
            Image.asset('assets/logo.png', width: 350, height: 350),
              const SizedBox(height: 450), // Your splash image
            const CircularProgressIndicator( // Optional loading spinner
              valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 0, 0, 0)),
            ),
             const SizedBox(height: 7),
             const Text(
              'Loading', // App title text
              style: TextStyle(
                fontSize: 20,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ],
        ),
      )),
    );
  }
}