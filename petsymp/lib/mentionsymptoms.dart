import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petsymp/anothersearchsymptoms.dart';
import 'package:provider/provider.dart';
import 'userdata.dart';
import 'package:petsymp/symptomscatalog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'symptomsquestions.dart';

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

class MentionsympScreenState extends State<MentionsympScreen> with SingleTickerProviderStateMixin {
  bool _isAnimated = false;
  bool _isNavigating = false;
  final TextEditingController _symptomController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // For suggested symptoms
  List<String> _suggestedSymptoms = [];
  bool _showSuggestions = false;
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
    
    // Add listener to update suggested symptoms
    _symptomController.addListener(_updateSuggestedSymptoms);
    
    // Add focus listener to show/hide suggestions
    _focusNode.addListener(() {
      setState(() {
        _showSuggestions = _focusNode.hasFocus && _symptomController.text.isNotEmpty && _suggestedSymptoms.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _symptomController.removeListener(_updateSuggestedSymptoms);
    _symptomController.dispose();
    _focusNode.dispose();
    _bubbleAnimationController?.dispose();
    super.dispose();
  }
  
  void _updateSuggestedSymptoms() {
    final query = _symptomController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _showSuggestions = false;
        _suggestedSymptoms = [];
      } else {
        _suggestedSymptoms = symptomQuestions.keys
            .where((symptom) => 
              symptom.toLowerCase().replaceAll(RegExp(r'\s+'), '')
              .contains(query.replaceAll(RegExp(r'\s+'), '')))
            .toList();
        _showSuggestions = _focusNode.hasFocus && _suggestedSymptoms.isNotEmpty;
      }
    });
  }

  void navigateToNextPage() async {
    if (_formKey.currentState?.validate() ?? false) {
      final userData = Provider.of<UserData>(context, listen: false);
      final inputText = _symptomController.text.trim().toLowerCase();

      // 1. Add to pending temporarily
      userData.addPendingSymptom(inputText);
      userData.setAnotherSymptom(inputText);

      // 2. Navigate and wait for result
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AnothersearchsymptomsScreen()),
      );

      // 3. Cleanup if user backed out without selecting
      if (userData.pendingSymptoms.contains(inputText)) {
        userData.removePendingSymptom(inputText);
        debugPrint("🗑️ Removed $inputText from pending (user backed out)");
      }
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
    final List<String> predefinedSymptoms =
        Provider.of<UserData>(context, listen: false).getPredefinedSymptoms();

    return PopScope(
      canPop: false,
      child: GestureDetector(
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
            // Enhanced background with gradient
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
                // Decorative background elements
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

                Positioned(
                  top: screenHeight * 0.03,
                  left: screenWidth * 0.01,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_sharp,
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
                      SlideInLeft(
                        duration: const Duration(milliseconds: 1000),
                        delay: const Duration(milliseconds: 300),
                        from: 100,
                        child: const Text(
                          "Mention another sign or behavior that is unusual for your pet",
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
                                  controller: _symptomController,
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

                                    // Check if it's in the list of predefined symptoms
                                    final List<String> predefinedLower =
                                        userData.getPredefinedSymptoms().map((s) => s.toLowerCase()).toList();
                                    if (!predefinedLower.contains(inputLower)) {
                                      return 'No such symptom found';
                                    }

                                    // Prevent duplicates (already inputted but not finalized)
                                    if (userData.pendingSymptoms.contains(inputLower)) {
                                      return 'This symptom is already pending';
                                    }

                                    // Already finalized check
                                    if (userData.finalizedSymptoms.contains(inputLower)) {
                                      return 'This symptom is already added/finalized';
                                    }

                                    return null;
                                  }
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
                                          _symptomController.text = _suggestedSymptoms[index];
                                          // Move cursor to the end
                                          _symptomController.selection = TextSelection.fromPosition(
                                            TextPosition(offset: _symptomController.text.length),
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

                Positioned(
                  bottom: 100.h,
                  right: 16.w,
                  child: AnimatedContainer(
                    duration: Duration.zero, // disables the slide-in animation
                    child: FloatingActionButton(
                      onPressed: _navigateToSymptomCatalog,
                      backgroundColor: const Color.fromRGBO(29, 29, 44, 1.0),
                      foregroundColor: const Color(0xFFE8F2F5),
                      elevation: 4,
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
      ),
    );
  }
}