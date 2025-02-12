import 'package:flutter/material.dart';
import 'package:petsymp/getstarted.dart';
import 'package:petsymp/loginaccount.dart';
// Ensure this imports your login screen file

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
          setState(() {
            _isSuccessful = _checkLoginCredentials();
          });
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
        }
      });

    _progressController.forward();
  }

  bool _checkLoginCredentials() {
    return widget.username == "Admin" && widget.password == "Password"; // Sample check
  }

  @override
  Widget build(BuildContext context) {
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
                          : (_isSuccessful ? Colors.green : Colors.red),
                    ),
                    backgroundColor: Colors.grey[300],
                  );
                },
              ),
            ),
            Icon(
              _progressController.isAnimating
                  ? Icons.more_horiz
                  : (_isSuccessful ? Icons.check : Icons.close),
              size: 100,
              color: _progressController.isAnimating ? Colors.blue : (_isSuccessful ? Colors.green : Colors.red),
            ),
            
          ],
        ),

        
      ),

      const Positioned(
              top: 650,
              left: 160,
              child: 
             Text( 'Validating...', style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold), )
             ),
    ]));
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _progressController.dispose();
    super.dispose();
  }
}
