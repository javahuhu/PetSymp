import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petsymp/SymptomQuestions/CatQuestions.dart';
import 'package:petsymp/SymptomQuestions/DogQuestions.dart';
import 'package:petsymp/SymptomQuestions/NLPSymptom.dart';
import 'package:petsymp/searchsymptoms.dart';
import 'package:provider/provider.dart';
import 'package:petsymp/symptomscatalog.dart';
import 'userdata.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'SymptomQuestions/symptomsquestions.dart';
import 'package:animate_do/animate_do.dart';

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

class SymptomsScreenState extends State<SymptomsScreen> with SingleTickerProviderStateMixin {
  bool _isAnimated = false;
  bool _isNavigating = false;
  bool _showSuggestions = false;
  final TextEditingController _symptomsController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<String> _suggestedSymptoms = [];
  final FocusNode _focusNode = FocusNode();
  
  // Animation controller for bubbles
  AnimationController? _bubbleAnimationController;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller first
    _bubbleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
    
    // Trigger the animation after the widget builds.
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _isAnimated = true;
      });
    });

    // Add listener to update suggested symptoms
    _symptomsController.addListener(_updateSuggestedSymptoms);
    
    // Add focus listener to show/hide suggestions
    _focusNode.addListener(() {
      setState(() {
        _showSuggestions = _focusNode.hasFocus && _symptomsController.text.isNotEmpty && _suggestedSymptoms.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _symptomsController.removeListener(_updateSuggestedSymptoms);
    _symptomsController.dispose();
    _focusNode.dispose();
    _bubbleAnimationController?.dispose();
    super.dispose();
  }

  String resolveNlpSymptom(String input) {
  final lower = input.toLowerCase();
  for (final entry in symptomNLPMap.entries) {
    if (lower.contains(entry.key)) {
      return entry.value;
    }
  }
  return lower;
}


  void _updateSuggestedSymptoms() {
    final query = _symptomsController.text.trim().toLowerCase();
    final userData = Provider.of<UserData>(context, listen: false);
    final petType = userData.selectedPetType;
    final Set<String> smartInput = {};

    symptomNLPMap.forEach((phrase, symptom) {
      if(query.contains(phrase)) {
        smartInput.add(symptom);
      }
    });



    final Map<String, dynamic> petSymptoms = {
      ...symptomQuestions,
      if(petType == 'Dog') ...symptomQuestionsDog,
      if(petType == 'Cat') ...symptomQuestionsCat
    };

    setState(() {
        if (query.isEmpty) {
          _showSuggestions = false;
          _suggestedSymptoms = [];
        } else {
          // This only includes direct matches
          final symptomMatches = petSymptoms.keys
              .where((symptom) =>
                  symptom.toLowerCase().replaceAll(RegExp(r'\s+'), '').contains(
                      query.replaceAll(RegExp(r'\s+'), '')))
              .toList();

          // 👇 Combine NLP-based smartInput and direct matches
          _suggestedSymptoms = [
            ...smartInput.where((s) => petSymptoms.containsKey(s)),
            ...symptomMatches.where((s) => !smartInput.contains(s))
          ];

          _showSuggestions =
              _focusNode.hasFocus && _suggestedSymptoms.isNotEmpty;
        }
      });

  }

  void navigateToNextPage() async {
  if (_formKey.currentState?.validate() ?? false) {
    final userData = Provider.of<UserData>(context, listen: false);
    final inputText = _symptomsController.text.trim().toLowerCase();
    
    final resolvedSymptom = resolveNlpSymptom(inputText);
    userData.setAnotherSymptom(resolvedSymptom);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchsymptomsScreen(symptoms: [resolvedSymptom]),
      ),
    );

  }
}

  void _navigateToSymptomCatalog() {
    if (_isNavigating) return;

    _isNavigating = true;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SymptomscatalogScreen()),
    ).then((_) {
      _isNavigating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    // Get predefined symptoms from UserData (the keys from the map).
    final List<String> predefinedSymptoms =
        Provider.of<UserData>(context, listen: false).getPredefinedSymptoms();

    return GestureDetector(
      // Add a GestureDetector to dismiss suggestions when tapping outside
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() {
          _showSuggestions = false;
        });
      },
      child: Scaffold(
        backgroundColor: Colors.transparent, // Make transparent to show gradient
        body: Container(
          // Enhanced background with gradient like in BreedScreen
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(225, 240, 243, 1.0),
                Color.fromRGBO(201, 229, 231, 1.0),
                Color(0xFFE8F2F5),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Decorative background elements like in BreedScreen
              if (_bubbleAnimationController != null) ...[
                // Large wave-like shape at the top
                Positioned(
                  top: -screenHeight * 0.2,
                  left: -screenWidth * 0.25,
                  child: AnimatedBuilder(
                    animation: _bubbleAnimationController!,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                          0,
                          _bubbleAnimationController!.value * 10,
                        ),
                        child: Container(
                          width: screenWidth * 1.5,
                          height: screenHeight * 0.5,
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(66, 134, 129, 0.07),
                            borderRadius: BorderRadius.circular(screenHeight * 0.25),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Smaller wave-like shape in bottom-right
                Positioned(
                  bottom: -screenHeight * 0.1,
                  right: -screenWidth * 0.25,
                  child: AnimatedBuilder(
                    animation: _bubbleAnimationController!,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                          0,
                          -_bubbleAnimationController!.value * 10,
                        ),
                        child: Container(
                          width: screenWidth * 0.9,
                          height: screenHeight * 0.3,
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(66, 134, 129, 0.08),
                            borderRadius: BorderRadius.circular(screenHeight * 0.15),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Middle-left floating bubble
                Positioned(
                  top: screenHeight * 0.45,
                  left: screenWidth * 0.05,
                  child: AnimatedBuilder(
                    animation: _bubbleAnimationController!,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                          _bubbleAnimationController!.value * 5,
                          _bubbleAnimationController!.value * 8,
                        ),
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color.fromRGBO(66, 134, 129, 0.2),
                            border: Border.all(
                              color: const Color.fromRGBO(66, 134, 129, 0.3),
                              width: 1.5,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Middle-right small floating circle
                Positioned(
                  top: screenHeight * 0.6,
                  right: screenWidth * 0.1,
                  child: AnimatedBuilder(
                    animation: _bubbleAnimationController!,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                          -_bubbleAnimationController!.value * 8,
                          -_bubbleAnimationController!.value * 6,
                        ),
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Color.fromRGBO(72, 138, 163, 0.3),
                                Color.fromRGBO(72, 138, 163, 0.1),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              
              // Static background elements
              Positioned(
                top: screenHeight * 0.25,
                right: screenWidth * 0.15,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromRGBO(72, 138, 163, 0.4),
                  ),
                ),
              ),
              Positioned(
                top: screenHeight * 0.26,
                right: screenWidth * 0.2,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromRGBO(72, 138, 163, 0.3),
                  ),
                ),
              ),
              
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
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(66, 134, 129, 0.2),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
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
                    SlideInLeft(
                      duration: const Duration(milliseconds: 1000),
                      delay: const Duration(milliseconds: 300),
                      from: 100,
                      child: const Text(
                        "Enter a single symptom that troubles your pet",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(29, 29, 44, 1.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 50.h),
                    FadeIn(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 400),
                      child: SizedBox(
                        width: screenWidth * 0.8,
                        child: Column(
                          children: [
                            Form(
                              key: _formKey,
                              child: TextFormField(
                                controller: _symptomsController,
                                focusNode: _focusNode,
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
                                  // Only check for commas or plus signs
                                  if (value.contains(',') || value.contains('+')) {
                                    return 'Please enter only one symptom at a time';
                                  }

                                  final userData = Provider.of<UserData>(context, listen: false);
                                  
                                  final inputLower = value.trim().toLowerCase();

                                  // Check if it's in the list of predefined symptoms
                                  final petType = userData.selectedPetType;
                                  final Map<String, dynamic> petSymptoms = {
                                    ...symptomQuestions,
                                    if (petType == "Cat") ...symptomQuestionsCat,
                                    if (petType == "Dog") ...symptomQuestionsDog,
                                  };

                                  final resolvedSymptom = resolveNlpSymptom(inputLower);

                                  if (!petSymptoms.containsKey(resolvedSymptom)) {
                                    return 'This symptom is not available for ${petType.toLowerCase()}';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            // Suggested Symptoms List - Only show when _showSuggestions is true
                            if (_showSuggestions)
                              Container(
                                width: screenWidth * 0.8,
                                constraints: const BoxConstraints(maxHeight: 300),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _suggestedSymptoms.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text(_suggestedSymptoms[index]),
                                      onTap: () {
                                        // Set the selected symptom in the text field
                                        _symptomsController.text = _suggestedSymptoms[index];
                                        // Move cursor to the end
                                        _symptomsController.selection = TextSelection.fromPosition(
                                          TextPosition(offset: _symptomsController.text.length),
                                        );
                                        // Hide suggestions after selection
                                        setState(() {
                                          _showSuggestions = false;
                                        });
                                        // Unfocus to hide keyboard
                                        FocusScope.of(context).unfocus();
                                      },
                                    );
                                  },
                                ),
                              ),
                          ],
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
                child: SlideInUp(
                  duration: const Duration(milliseconds: 1000),
                  delay: const Duration(milliseconds: 300),
                  from: 100,
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
              ),

              // Catalog button
              Positioned(
                bottom: 100.h,
                right: 16.w,
                child: AnimatedContainer(
                  duration: Duration.zero, // disables the slide-in animation
                  child: FloatingActionButton(
                    onPressed: _navigateToSymptomCatalog,
                    backgroundColor: const Color.fromRGBO(29, 29, 44, 1.0),
                    foregroundColor: const Color(0xFFE8F2F5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100.r),
                    ),
                    child: const Icon(Icons.menu_book_sharp),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}