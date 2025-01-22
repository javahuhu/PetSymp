import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'getstarted.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  // Helper method to launch external URLs
  Future<void> gotoPage(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void navigateToNextPage() {
    if (_formKey.currentState?.validate() ?? false) {
      // Navigate only if the input is valid
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const GetstartedScreen()),
      );
    }
  }

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
              SizedBox(height: screenHeight * 0.16), // Responsive spacing
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
              SizedBox(height: screenHeight * 0.1), // Responsive spacing
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.09),
                child: Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: "Enter your phone number",
                      labelStyle: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF000000),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (value.length != 11) {
                        return "Phone Number must be 11 digits";
                      }
                      return null;
                    },
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Center(
                child: ElevatedButton(
                  onPressed: navigateToNextPage, // Validation is handled here
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCFCFCF),
                    foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    fixedSize: Size(screenWidth * 0.9, screenHeight * 0.07),
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
              SizedBox(height: screenHeight * 0.03),

              // Divider + "OR" + Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.black,
                      thickness: 2,
                      indent: screenWidth * 0.05,
                      endIndent: screenWidth * 0.02,
                    ),
                  ),
                  const Text(
                    "OR",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.black,
                      thickness: 2,
                      indent: screenWidth * 0.02,
                      endIndent: screenWidth * 0.05,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),

              // Clickable Circle Image for external links
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: screenWidth * 0.01),
                  InkWell(
                    onTap: () async {
                      await gotoPage("https://accounts.google.com/");
                    },
                    child: Container(
                      width: screenWidth * 0.13,
                      height: screenWidth * 0.13,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/googlelogo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.05),
                  InkWell(
                    onTap: () async {
                      await gotoPage("https://www.facebook.com/");
                    },
                    child: Container(
                      width: screenWidth * 0.18,
                      height: screenWidth * 0.18,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/facebooklogo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.05),
                  InkWell(
                    onTap: () async {
                      await gotoPage("https://www.instagram.com/");
                    },
                    child: Container(
                      width: screenWidth * 0.13,
                      height: screenWidth * 0.13,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/instagramlogo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
