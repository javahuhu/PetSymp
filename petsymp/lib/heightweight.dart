import 'package:flutter/material.dart';
import 'package:petsymp/breed.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'userdata.dart';
import 'package:provider/provider.dart';
class MeasureinputScreen extends StatefulWidget {
const MeasureinputScreen({super.key});
  @override
  MeasureinputScreenState createState() => MeasureinputScreenState();
}

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

class MeasureinputScreenState extends State<MeasureinputScreen> {
  bool _isAnimated = false; // Animation toggle // State to track the selected tab

  @override
  void initState() {
    super.initState();
    // Trigger the animation after the widget builds
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimated = true;
      });
    });
  }

  // Helper method to launch external URLs
  Future<void> gotoPage(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
  
  final TextEditingController _sizeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  

  void navigateToNextPage() {
    if (_formKey.currentState?.validate() ?? false) {
      Provider.of<UserData>(context, listen: false).setpetSize(_sizeController.text);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const  BreedScreen()),
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
          
          Positioned(
            top: screenHeight * 0.03,
            left: screenWidth * 0.01,
            child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_sharp,
                  color:  Color.fromRGBO(61, 47, 40, 1),
                  size: 40.0,),
                  label: const Text(''),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                  ),
                ),), // Show this layout only on the first tab
            Stack(
              children: [
                // AnimatedPositioned for Paw Image
                AnimatedPositioned(
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  top: _isAnimated ? screenHeight * 0.13 : -100, // From off-screen to final position
                  left: screenWidth * 0.1,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: screenWidth * 0.15, // 15% of screen width
                        height: screenWidth * 0.15, // Equal height for circular image
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/paw.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.05), // Spacing between paw and text
                    ],
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.22, // Text and input below the paw
                  left: screenWidth * 0.12,
                  right: screenWidth * 0.02,
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "What is the size of your pet",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(29, 29, 44, 1.0),
                        ),
                      ),
                      
                    ],
                  ),
                ),

                Positioned(
                  top: screenHeight * 0.32, // Adjusted position for the form
                  left: screenWidth * 0.12,
                  right: screenWidth * 0.12,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                      
                        const SizedBox(height: 10),
                       TextFormField(
                          controller: _sizeController,
                          autofillHints: const [AutofillHints.name],
                            inputFormatters: [
                              FirstLetterUpperCaseTextFormatter(),
                              FilteringTextInputFormatter.deny(RegExp(r'[0-9]')),
                            ],
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),

                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: const BorderSide(
                                  color: Color.fromRGBO(82, 170, 164, 1), // Border color when not focused
                                  width: 2.0, // Thickness when not focused
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: const BorderSide(
                                  color:  Color.fromRGBO(72, 38, 163, 1),// Border color when focused
                                  width: 2.0, // Thickness when focused
                                ),
                              ),

                            hintText: 'Enter the Size of the Pet',
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 20.0,
                              horizontal: 15.0,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter size of the pet';
                            }
                            return null;
                          },
                        ),

                      ],
                    ),
                  ),
                ),

                 Positioned(
                top: screenHeight * 0.9,
                right: screenWidth * 0.02, // Adjust dynamically for right alignment
                child: SizedBox( // Wrap with SizedBox to ensure correct width
                  width: 100, // Adjust as needed
                  child: ElevatedButton(
                    onPressed: navigateToNextPage,
                    style: ButtonStyle(
                    // Dynamic background color based on button state
                    backgroundColor: WidgetStateProperty.resolveWith(
                      (states) {
                        if (states.contains(WidgetState.pressed)) {
                          return const Color.fromARGB(255, 0, 0, 0); // Background color when pressed
                        }
                        return Colors.transparent; // Default background color
                      },
                    ),
                    // Dynamic text color based on button state
                    foregroundColor: WidgetStateProperty.resolveWith(
                      (states) {
                        if (states.contains(WidgetState.pressed)) {
                          return const Color.fromARGB(255, 255, 255, 255); // Text color when pressed
                        }
                        return const Color.fromRGBO(29, 29, 44, 1.0); // Default text color
                      },
                    ),
                    shadowColor: WidgetStateProperty.all(Colors.transparent),
                    side: WidgetStateProperty.all(
                      const BorderSide(
                        color: Color.fromRGBO(82, 170, 164, 1),
                        width: 2.0,
                      ),
                    ),
                    shape: WidgetStateProperty.all(
                      const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                      ),
                    ),
                    fixedSize: WidgetStateProperty.all(
                      const Size(100, 55),
                    ),
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
              ),

               
              ],
            ),
          
        ],
      ),
      
    );
  }
}
