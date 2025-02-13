import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:petsymp/permission.dart';
import 'userdata.dart';

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

    final text = newValue.text;
    final firstLetter = text[0].toUpperCase();
    final restOfText = text.substring(1);

    return newValue.copyWith(
      text: firstLetter + restOfText,
      selection: newValue.selection,
    );
  }
}

class AssesmentScreen extends StatefulWidget {
  const AssesmentScreen({super.key});

  @override
  AssesmentScreenState createState() => AssesmentScreenState();
}

class AssesmentScreenState extends State<AssesmentScreen> {
  bool _isAnimated = false; // Animation toggle// State to track the selected tab
  final TextEditingController _usernamecontroller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _isAnimated = true;
      });
    });
  }

  void navigateToNextPage(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      // Save userName globally using Provider
      Provider.of<UserData>(context, listen: false).setUserName(_usernamecontroller.text);

      // Navigate to PermissionScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PermissionScreen()),
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
          // Show this layout only on the first tab
            Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  top: _isAnimated ? screenHeight * 0.13 : -100,
                  left: screenWidth * 0.1,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: screenWidth * 0.15,
                        height: screenWidth * 0.15,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/paw.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.05),
                    ],
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.22,
                  left: screenWidth * 0.12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Before we start your assessment,",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.normal,
                          color: Color.fromRGBO(29, 29, 44, 1.0),
                        ),
                      ),
                      const Text(
                        "input your USERNAME first.",
                        style: TextStyle(
                          color: Color.fromRGBO(29, 29, 44, 1.0),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: screenWidth * 0.8,
                        child: Form(
                          key: _formKey,
                          child: TextFormField(
                            controller: _usernamecontroller,
                            autofillHints: const [AutofillHints.name],
                            inputFormatters: [
                              FirstLetterUpperCaseTextFormatter(),
                            ],
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: const BorderSide(
                                  color: Color.fromRGBO(66, 134, 130, 1.0),
                                  width: 2.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: const BorderSide(
                                  color: Color.fromRGBO(72, 38, 163, 1),
                                  width: 2.0,
                                ),
                              ),
                              hintText: 'Enter your name',
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 20.0,
                                horizontal: 15.0,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your username';
                              }
                              if (value.length < 8) {
                                return "Username must contain at least 8 letters";
                              }
                              if (value.length != 8) {
                                return "Username must be exactly 8 characters";
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.9,
                  left: screenWidth * 0.75,
                  child: ElevatedButton(
                    onPressed: () => navigateToNextPage(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(82, 170, 164, 1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      fixedSize: const Size(100, 55),
                    ),
                    child: const Text(
                      "Next",
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            
            
        ],
      ),
    
    );
  }
}
