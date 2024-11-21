import 'package:flutter/material.dart';




class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Background Image
          Container(
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
              const SizedBox(height: 50.0), // Spacing at the top
              Padding(
                padding: const EdgeInsets.only(left: 50.0),
                child: Image.asset(
                  'assets/petlogo.png',
                  width: 270,
                  height: 270,
                ), // Your splash image
              ),
              const SizedBox(height: 168.0), // Spacing between logo and text
              const Padding(
                padding: EdgeInsets.only(left: 35.0),
                child: Text(
                  'Welcome!',
                  style: TextStyle(
                    fontSize: 35.0,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ),
              const SizedBox(height: 120.0), // Spacing between text and text field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35.0),
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    label: Center(
                    child: Text("Enter your phone number"),),
                  labelStyle: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold, 
                  color: Color(0xFF000000), // Black color
                    ),
                    
                  ),
                ),
              ),

              const SizedBox(height: 25.0),
              Center( child: 
              Container(
                height: 65,
                width: 400,
            decoration:  BoxDecoration(
             color: const Color(0xFFCFCFCF),
             borderRadius: BorderRadius.circular(100),
            ),
            child: const Center (child: Text("Log In", style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),)),
              )),

            ],
          ),
        ],
      ),
    );
  }
}

