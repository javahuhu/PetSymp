import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petsymp/anothersearchsymptoms.dart';
import 'package:provider/provider.dart';
import 'userdata.dart';

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

class MentionsympScreen extends StatefulWidget {
  const MentionsympScreen({super.key});

  @override
  MentionsympScreenState createState() => MentionsympScreenState();
}

class MentionsympScreenState extends State<MentionsympScreen> {
  bool _isAnimated = false;
  final TextEditingController _symptomController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

 @override
void initState() {
  super.initState();
  
  // Use a post-frame callback to safely update the state
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) { // Safety check to ensure widget is still in the tree
      Provider.of<UserData>(context, listen: false).clearNewSymptoms();
    }
  });
  
  Future.delayed(const Duration(milliseconds: 200), () {
    setState(() {
      _isAnimated = true;
    });
  });
}


  void navigateToNextPage() {
  if (_formKey.currentState?.validate() ?? false) {
    final userData = Provider.of<UserData>(context, listen: false);
    final inputText = _symptomController.text.trim().toLowerCase();

    // 1) Mark the typed symptom as "pending" (not finalized):
    userData.addPendingSymptom(inputText);

    // 2) Optionally store it in "anotherSymptom," if that’s your logic:
    userData.setAnotherSymptom(inputText);

    // Then proceed to your AnothersearchsymptomsScreen:
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AnothersearchsymptomsScreen()),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final List<String> predefinedSymptoms =
        Provider.of<UserData>(context, listen: false).getPredefinedSymptoms();

    return PopScope(
    canPop: false, 
    child: Scaffold(
      backgroundColor: const Color(0xFFE8F2F5),
      body: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            top: _isAnimated ? screenHeight * 0.13 : -100,
            left: screenWidth * 0.1,
            child: Row(
              children: [
                Container(
                  width: screenWidth * 0.15,
                  height: screenWidth * 0.15,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: Image.asset('assets/paw.png', fit: BoxFit.contain),
                ),
                SizedBox(width: screenWidth * 0.05),
              ],
            ),
          ),
          Positioned(
            top: screenHeight * 0.22,
            left: screenWidth * 0.12,
            right: screenWidth * 0.02,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Mention another sign or behavior that is unusual for your pet",
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
                      controller: _symptomController,
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
                        hintText: 'Enter a single symptom (e.g., Vomiting)',
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 20.0,
                          horizontal: 15.0,
                        ),
                      ),
                      validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the symptom of the pet';
                      }
                      if (value.contains(',') || value.contains('+')) {
                        return 'Please enter only one symptom at a time';
                      }

                      final inputLower = value.trim().toLowerCase();
                      final userData = Provider.of<UserData>(context, listen: false);

                      // Check if it’s a recognized (predefined) symptom:
                      final List<String> predefinedLower =
                          userData.getPredefinedSymptoms().map((s) => s.toLowerCase()).toList();
                      if (!predefinedLower.contains(inputLower)) {
                        return 'No such symptom found';
                      }

                      // **NEW**: If it’s in the finalizedSymptoms list, block it:
                      if (userData.finalizedSymptoms.contains(inputLower)) {
                        return 'This symptom is already added/finalized';
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
    ));
  }
}
