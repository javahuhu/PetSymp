import 'package:flutter/material.dart';
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
    // Use MediaQuery for responsive design
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Background Image
          Container(
            height: screenHeight,
            width: screenWidth,
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/catlogin.jpg'),
              ),
            ),
          ),
          // Content on top of the image
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Spacing at the top
              Padding(
                padding: EdgeInsets.only(left: screenWidth * 0.0),
                child: Image.asset(
                  'assets/logo.png',
                  width: screenWidth * 0.7,
                  height: screenHeight * 0.3,
                ),
              ),
              SizedBox(height: screenHeight * 0.1645), // Responsive spacing
              Padding(
                padding: EdgeInsets.only(left: screenWidth * 0.09),
                child: const Text(
                  'Welcome!',
                  style: TextStyle(
                    fontSize: 35.0,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.27), // Responsive spacing
            
              SizedBox(height: screenHeight * 0.03),
              Center(
                child: ElevatedButton(
                  onPressed: (){
                    Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginaccountScreen()),
                          );
                  } ,// Validation is handled here
                  style: ElevatedButton.styleFrom(
                    backgroundColor:  const Color.fromARGB(255, 0, 0, 0),  
                    foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      
                    ),
                    fixedSize: Size(screenWidth * 0.9, screenHeight * 0.06),
                  ),
                  child: const Text(
                    "Log In",
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            
            SizedBox(height: screenHeight * 0.01), // Responsive spacing
          
              Center(
                child: ElevatedButton(
                  onPressed: (){
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignupScreen()),
                      );
                  } ,// Validation is handled here
                  style: ElevatedButton.styleFrom(
                    backgroundColor:  const Color.fromARGB(255, 0, 0, 0),
                    foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    fixedSize: Size(screenWidth * 0.9, screenHeight * 0.06),
                  ),
                  child: const Text(
                    "Create your account",
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Divider + "OR" + Divider
             

              
            ],
          ),
        ],
      ),
    );
  }
}
