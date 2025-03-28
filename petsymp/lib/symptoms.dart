import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petsymp/searchsymptoms.dart';
import 'package:provider/provider.dart';
import 'userdata.dart';

/// Custom TextInputFormatter to capitalize only the first letter.
class FirstLetterUpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final text = newValue.text;
    final firstLetter = text[0].toUpperCase();
    final restOfText = text.substring(1);
    return newValue.copyWith(
      text: firstLetter + restOfText,
      selection: newValue.selection,
    );
  }
}

class SymptomsScreen extends StatefulWidget {
  const SymptomsScreen({super.key});

  @override
  SymptomsScreenState createState() => SymptomsScreenState();
}

class SymptomsScreenState extends State<SymptomsScreen> {
  bool _isAnimated = false;
  final TextEditingController _symptomsController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Trigger the animation after the widget builds.
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _isAnimated = true;
      });
    });
  }

 void navigateToNextPage() {
  if (_formKey.currentState?.validate() ?? false) {
    final userData = Provider.of<UserData>(context, listen: false);
    final inputText = _symptomsController.text.trim().toLowerCase();

    // 1) Mark it as a pending symptom (instead of permanently adding to petSymptoms)
    userData.addPendingSymptom(inputText);

    // 2) Also store it if you want "anotherSymptom," etc.
    userData.setAnotherSymptom(inputText);

    // Then navigate
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchsymptomsScreen(symptoms: [inputText]),
      ),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    // Get predefined symptoms from UserData (the keys from the map).
    final List<String> predefinedSymptoms =
        Provider.of<UserData>(context, listen: false).getPredefinedSymptoms();

    return Scaffold(
      backgroundColor: const Color(0xFFE8F2F5),
      body: Stack(
        children: [
          // Back Button.
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
          // Animated Header.
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
          // Form for symptom input.
          Positioned(
            top: screenHeight * 0.22,
            left: screenWidth * 0.12,
            right: screenWidth * 0.02,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Enter a single symptom that troubles your pet",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(29, 29, 44, 1.0),
                  ),
                ),
                const SizedBox(height: 50),
                SizedBox(
                  width: screenWidth * 0.8,
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _symptomsController,
                      autofillHints: const [AutofillHints.name],
                      inputFormatters: [
                        FirstLetterUpperCaseTextFormatter(),
                        FilteringTextInputFormatter.deny(RegExp(r'[0-9]')),
                      ],
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(
                            color: Color.fromRGBO(82, 170, 164, 1),
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
                        // Updated hint to show only one symptom.
                        hintText: 'e.g., Vomiting',
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 20.0,
                          horizontal: 15.0,
                        ),
                      ),
                      validator: (value) {
  if (value == null || value.isEmpty) {
    return 'Please enter the symptom of the pet';
  }
  // Single-symptom check as you had:
  if (value.trim().split(RegExp(r'\s+')).length > 1) {
    return 'Please enter only one symptom at a time';
  }

  final userData = Provider.of<UserData>(context, listen: false);
  final inputLower = value.trim().toLowerCase();

  // Make sure it exists in your predefinedSymptoms...
  final List<String> predefLower = userData.getPredefinedSymptoms().map((s) => s.toLowerCase()).toList();
  if (!predefLower.contains(inputLower)) {
    return 'No such symptom found';
  }

  // **NEW**: If it's in the finalized list, block it:
  if (userData.finalizedSymptoms.contains(inputLower)) {
    return 'This symptom is already finalized';
  }

  return null;
},

                    ),
                  ),
                ),
              ],
            ),
          ),
          // Next Button.
          Positioned(
            top: screenHeight * 0.9,
            right: screenWidth * 0.02,
            child: SizedBox(
              width: 100,
              child: ElevatedButton(
                onPressed: navigateToNextPage,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.pressed)) {
                      return const Color.fromARGB(255, 0, 0, 0);
                    }
                    return Colors.transparent;
                  }),
                  foregroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.pressed)) {
                      return const Color.fromARGB(255, 255, 255, 255);
                    }
                    return const Color.fromRGBO(29, 29, 44, 1.0);
                  }),
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
                  fixedSize: WidgetStateProperty.all(const Size(100, 55)),
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
    );
  }
}
