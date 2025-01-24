import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petsymp/loginaccount.dart';
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

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  SignupScreenState createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPass = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  Future<void> gotoPage(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool isPasswordVisible,
    required VoidCallback onVisibilityToggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isPasswordVisible,
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
            color: Color.fromRGBO(61, 47, 40, 1), // Border color when focused
            width: 3.0, // Thickness when focused
          ),
        ),
        hintText: hintText,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 20.0,
          horizontal: 15.0,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: onVisibilityToggle,
        ),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                padding: EdgeInsets.only(top: screenHeight * 0.037),
                child: const Center(
                  child:  Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                        ),
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
              height: screenHeight * 0.65,
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
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Username Input
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
                                      setState(() {}); // Trigger a rebuild to hide the icon
                                    },
                                  )
                                : null, // No icon if the field is empty
                          ),
                          onChanged: (value) {
                            setState(() {}); // Trigger a rebuild to show/hide the clear icon
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your username';
                            }
                            return null;
                          },
                        ),
                          const SizedBox(height: 20),

                          TextFormField(
                          controller: _emailController,
                          autofillHints: const [AutofillHints.name],
                          
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
                            hintText: 'Email',
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 20.0,
                              horizontal: 15.0,
                            ),
                            // Clear Icon Logic
                            suffixIcon: _emailController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _emailController.clear(); // Clear the input
                                      setState(() {}); // Trigger a rebuild to hide the icon
                                    },
                                  )
                                : null, // No icon if the field is empty
                          ),
                          onChanged: (value) {
                            setState(() {}); // Trigger a rebuild to show/hide the clear icon
                          },
                              validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }

                              if(value.isEmpty || !value.contains('@') || !value.contains('.')){
                                return 'Invalid Email';
                              }
                              return null;
                            },
                        ),
                          
                          
                          const SizedBox(height: 20),

                          // Password Input
                          _buildPasswordField(
                            controller: _passwordController,
                            hintText: 'Password',
                            isPasswordVisible: _isPasswordVisible,
                            onVisibilityToggle: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
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
                          const SizedBox(height: 20),

                          // Confirm Password Input
                          _buildPasswordField(
                            controller: _confirmPass,
                            hintText: 'Confirm Password',
                            isPasswordVisible: _isConfirmPasswordVisible,
                            onVisibilityToggle: () {
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                     SizedBox(height: screenHeight * 0.15),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginaccountScreen()),
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
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: screenHeight * 0.15, // Adjust to control how high it is at the top
            left: (MediaQuery.of(context).size.width - screenWidth * 0.85) / 2, // Center horizontally
            child: Container(
              height: screenHeight * 0.2, // Adjust size as needed
              width: screenWidth * 0.85,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/catsit.png'),
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
