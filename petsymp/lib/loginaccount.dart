import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petsymp/getstarted.dart';
import 'package:petsymp/signup.dart';
import 'package:url_launcher/url_launcher.dart';
// Custom TextInputFormatter to capitalize only the first letter
class FirstLetterUpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue; // Return empty value
    }

    // Capitalize the first letter and keep the rest as-is
    final text = newValue.text;
    final firstLetter = text[0].toUpperCase();
    final restOfText = text.substring(1);

    return newValue.copyWith(
      text: firstLetter + restOfText,
      selection: newValue.selection,
    );
  }
}

class LoginaccountScreen extends StatefulWidget {
  const LoginaccountScreen({super.key});

  @override
  LoginaccountScreenState createState() => LoginaccountScreenState();
}

class LoginaccountScreenState extends State<LoginaccountScreen> {

   Future<void> gotoPage(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }


  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery for responsive design
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      //backgroundColor: const Color.fromARGB(255, 173, 173, 80),
      backgroundColor: const Color(0xFFFFDB58),
      body: Stack(
        children: [

           
          // Back Button
          Positioned(
            top: screenHeight * 0.03,
            left: screenWidth * 0.01,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.arrow_back_sharp,
                color: Color.fromRGBO(61, 47, 40, 1),
                size: 40.0,
              ),
              label: const Text(''),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
          // Logo at the top
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.00),
                child: Center(
                  child: Image.asset(
                    'assets/logo.png',
                    width: screenWidth * 0.6,
                    height: screenHeight * 0.3,
                  ),
                ),
              ),
            ],
          ),
          // Rounded container for input fields and button
          Positioned(
            bottom: 0,
            child: Container(
              width: screenWidth,
              height: screenHeight * 0.5,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(255, 255, 255, 1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Padding(
              padding: EdgeInsets.only(
                top: screenHeight * 0.046, // Add more space at the top
                left: screenWidth * 0.08,
                right: screenWidth * 0.08,
                bottom: screenHeight * 0.00, // Maintain bottom padding
              ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Pet breed input
                          TextFormField(
                          controller: _usernameController,
                          autofillHints: const [AutofillHints.name],
                          inputFormatters: [
                            FirstLetterUpperCaseTextFormatter(),
                            FilteringTextInputFormatter.deny(RegExp(r'[0-9]')),
                          ],
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color.fromARGB(255, 255, 255, 255),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 0, 0, 0), // Border color when not focused
                                width: 2.0, // Thickness when not focused
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(
                                color: Color.fromRGBO(61, 47, 40, 1), // Border color when focused
                                width: 3.0, // Thickness when focused
                              ),
                            ),
                            hintText: 'Username',
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 20.0,
                              horizontal: 15.0,
                            ),
                            // Clear Icon Logic
                            suffixIcon: _usernameController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _usernameController.clear(); // Clear the input
                                      setState(() {
                                        // Clear `userName` when the icon is pressed
                                      }); 
                                    },
                                  )
                                : null, // No icon if the field is empty
                          ),
                         
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your username';
                            }
                            return null;
                          },
                        ),


                          
                          const SizedBox(height: 20),
                          // Password input
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color.fromARGB(255, 255, 255, 255),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),

                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 0, 0, 0), // Border color when not focused
                                  width: 2.0, // Thickness when not focused
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: const BorderSide(
                                  color:  Color.fromRGBO(61, 47, 40, 1),// Border color when focused
                                  width: 3.0, // Thickness when focused
                                ),
                              ),
                              hintText: 'Password',
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 20.0,
                                horizontal: 15.0,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                     SizedBox(height: screenHeight * 0.05),
                    // Login button
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                         Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GetstartedScreen(),
                    ),
                    );

                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
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
                    Row( children: [
                      SizedBox(height: screenHeight * 0.04, width: screenWidth * 0.0),
                    TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignupScreen()),
                      );
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(fontSize: 16.0, color: Color.fromRGBO(61, 47, 40, 1),),
                    ),
                  ),

                SizedBox(width: screenWidth * 0.325),
                  TextButton(
                    onPressed: () {
                      // Handle button press
                    },
                    child: const Text(
                      "Recovery Password",
                      style: TextStyle(fontSize: 16.0, color: Color.fromRGBO(61, 47, 40, 1),),
                    ),
                  ),

                  ],),

                  

                  SizedBox(height: screenHeight * 0.01),

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

                  SizedBox(height: screenHeight * 0.02),

              // Clickable Circle Image for external links
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: screenWidth * 0.005),
                  InkWell(
                    onTap: () async {
                      await gotoPage("https://accounts.google.com/");
                    },
                    child: Container(
                      width: screenWidth * 0.10,
                      height: screenWidth * 0.10,
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
                  SizedBox(width: screenWidth * 0.09),
                  InkWell(
                    onTap: () async {
                      await gotoPage("https://www.facebook.com/");
                    },
                    child: Container(
                      width: screenWidth * 0.135,
                      height: screenWidth * 0.135,
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
                  SizedBox(width: screenWidth * 0.09),
                  InkWell(
                    onTap: () async {
                      await gotoPage("https://www.instagram.com/");
                    },
                    child: Container(
                      width: screenWidth * 0.10,
                      height: screenWidth * 0.10,
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
              ),
            ),

            
          ),

          Positioned(
            top: screenHeight * 0.2, // Adjust to control how high it is at the top
            left: (MediaQuery.of(context).size.width - screenWidth * 0.85) / 2, // Center horizontally
            child: Container(
              height: screenHeight * 0.3, // Adjust size as needed
              width: screenWidth * 0.7,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/goldenpet.png'),
                  fit: BoxFit.cover, // Adjust as needed
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() => runApp(const MaterialApp(home: LoginaccountScreen()));
