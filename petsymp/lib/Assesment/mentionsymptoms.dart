// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:petsymp/SymptomQuestions/CatQuestions.dart';
// import 'package:petsymp/SymptomQuestions/DogQuestions.dart';
// import 'package:petsymp/Assesment/anothersearchsymptoms.dart';
// import 'package:provider/provider.dart';
// import '../userdata.dart';
// import 'package:petsymp/SymptomsCatalog/symptomscatalog.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:animate_do/animate_do.dart';
// import '../SymptomQuestions/symptomsquestions.dart';
// import '../SymptomQuestions/NLPSymptom.dart';
// import 'anothersymptoms.dart';
// import 'package:petsymp/searchdescription.dart';

// class FirstLetterUpperCaseTextFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//       TextEditingValue oldValue, TextEditingValue newValue) {
//     if (newValue.text.isEmpty) return newValue;
//     final text = newValue.text;
//     final firstLetter = text[0].toUpperCase();
//     final restOfText = text.substring(1);
//     return newValue.copyWith(
//       text: firstLetter + restOfText,
//       selection: newValue.selection,
//     );
//   }
// }

// class MentionsympScreen extends StatefulWidget {
//   const MentionsympScreen({super.key});

//   @override
//   MentionsympScreenState createState() => MentionsympScreenState();
// }

// class MentionsympScreenState extends State<MentionsympScreen>
//     with SingleTickerProviderStateMixin {
//   bool _isAnimated = false;
//   bool _isNavigating = false;
//   final TextEditingController _symptomController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   // For suggested symptoms
//   List<String> _suggestedSymptoms = [];
//   bool _showSuggestions = false;
//   final FocusNode _focusNode = FocusNode();

//   // Animation controller for decorative bubbles.
//   AnimationController? _bubbleAnimationController;

//   @override
// void initState() {
//   super.initState();

//   _bubbleAnimationController = AnimationController(
//     vsync: this,
//     duration: const Duration(seconds: 5),
//   )..repeat(reverse: true);

//   Future.delayed(const Duration(milliseconds: 200), () {
//     setState(() {
//       _isAnimated = true;
//     });
//   });

//   _symptomController.addListener(_updateSuggestedSymptoms);
//   _focusNode.addListener(() {
//     setState(() {
//       _showSuggestions = _focusNode.hasFocus &&
//           _symptomController.text.isNotEmpty &&
//           _suggestedSymptoms.isNotEmpty;
//     });
//   });
// }


//   @override
//   void dispose() {
//     _symptomController.removeListener(_updateSuggestedSymptoms);
//     _symptomController.dispose();
//     _focusNode.dispose();
//     _bubbleAnimationController?.dispose();
//     super.dispose();
//   }


//   String resolveNlpSymptom(String input) {
//   final lower = input.toLowerCase();
//   for (final entry in symptomNLPMap.entries) {
//     if (lower.contains(entry.key)) {
//       return entry.value;
//     }
//   }
//   return lower;
// }


//   void _updateSuggestedSymptoms() {
//     final query = _symptomController.text.trim().toLowerCase();
//     final userData = Provider.of<UserData>(context, listen: false);
//     final petType = userData.selectedPetType;
//     final Set<String> smartInput = {};

//      symptomNLPMap.forEach((phrase, symptom) {
//       if(query.contains(phrase)) {
//         smartInput.add(symptom);
//       }
//     });


//     final Map<String, dynamic> petSymptoms = {
//       // ...symptomQuestions,
//       if (petType == "Dog") ...symptomQuestionsDog,
//       if (petType == "Cat") ...symptomQuestionsCat,
//     };
//      setState(() {
//         if (query.isEmpty) {
//           _showSuggestions = false;
//           _suggestedSymptoms = [];
//         } else {
//           // This only includes direct matches
//           final symptomMatches = petSymptoms.keys
//               .where((symptom) =>
//                   symptom.toLowerCase().replaceAll(RegExp(r'\s+'), '').contains(
//                       query.replaceAll(RegExp(r'\s+'), '')))
//               .toList();

//           // 👇 Combine NLP-based smartInput and direct matches
//           _suggestedSymptoms = [
//             ...smartInput.where((s) => petSymptoms.containsKey(s)),
//             ...symptomMatches.where((s) => !smartInput.contains(s))
//           ];

//           _showSuggestions =
//               _focusNode.hasFocus && _suggestedSymptoms.isNotEmpty;
//         }
//       });
//   }


  
//   String resolveCanonicalSymptom(String input, Map<String, dynamic> symptomMap, Map<String, String> descriptionMap) {
//   final query = input.trim().toLowerCase();

//   // Step 1: Match against actual symptom keys (strict match)
//   if (symptomMap.containsKey(query)) {
//     return query;
//   }


//     final fallback = symptomDescriptions.entries.firstWhere(
//     (entry) => entry.value.toLowerCase().contains(query),
//     orElse: () => const MapEntry("", ""),
//   );
//   return fallback.key.isNotEmpty ? fallback.key : query;
// }


// String resolveFinalSymptom({
//   required String userInput,
//   required Map<String, dynamic> symptomMap,
//   required Map<String, String> descriptionMap,
//   required Map<String, String> nlpMap,
// }) {
//   final query = userInput.trim().toLowerCase();

//   // 1. Exact key match
//   if (symptomMap.containsKey(query)) {
//     return query;
//   }

//   // 2. NLP match
//   for (final entry in nlpMap.entries) {
//     if (query.contains(entry.key) && symptomMap.containsKey(entry.value)) {
//       return entry.value;
//     }
//   }

//   // 3. Description fallback
//   final descMatch = descriptionMap.entries.firstWhere(
//     (entry) => entry.value.toLowerCase().contains(query),
//     orElse: () => const MapEntry("", ""),
//   );
//   return descMatch.key.isNotEmpty ? descMatch.key : query;
// }




//   void navigateToNextPage() async {
//   if (_formKey.currentState?.validate() ?? false) {
//     final userData = Provider.of<UserData>(context, listen: false);
//     final inputText = _symptomController.text.trim();

//     final petType = userData.selectedPetType;
//     final Map<String, dynamic> symptomMap = {
//       if (petType == 'Dog') ...symptomQuestionsDog,
//       if (petType == 'Cat') ...symptomQuestionsCat,
//     };

//     final resolvedSymptom = resolveFinalSymptom(
//       userInput: inputText,
//       symptomMap: symptomMap,
//       descriptionMap: symptomDescriptions,
//       nlpMap: symptomNLPMap,
//     );

//     userData.setAnotherSymptom(resolvedSymptom);

//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AnothersearchsymptomsScreen(symptoms: [resolvedSymptom]),
//       ),
//     );
//   }
// }


//   void _navigateToSymptomCatalog() {
//     if (_isNavigating) return;
//     _isNavigating = true;
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const SymptomscatalogScreen()),
//     ).then((_) {
//       _isNavigating = false;
//     });
//   }

//    String _capitalizeEachWord(String text) {
//   return text
//       .split(' ')
//       .map((word) => word.isNotEmpty
//           ? word[0].toUpperCase() + word.substring(1)
//           : '')
//       .join(' ');
// }


//   @override
//   Widget build(BuildContext context) {
//     final double screenHeight = MediaQuery.of(context).size.height;
//     final double screenWidth = MediaQuery.of(context).size.width;

//     return WillPopScope(
//       onWillPop: () async => false,
//       child: GestureDetector(
//         onTap: () {
//           FocusScope.of(context).unfocus();
//           setState(() {
//             _showSuggestions = false;
//           });
//         },
//         child: Scaffold(
//           resizeToAvoidBottomInset: false, 
//           backgroundColor: Colors.transparent,
//           body: Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   Color.fromRGBO(225, 240, 243, 1.0),
//                   Color.fromRGBO(201, 229, 231, 1.0),
//                   Color(0xFFE8F2F5),
//                 ],
//                 stops: [0.0, 0.5, 1.0],
//               ),
//             ),
//             child: Stack(
//               children: [
//                 // Decorative background elements (add as needed)
//                 if (_bubbleAnimationController != null) ...[
//                   Positioned(
//                     top: -screenHeight * 0.2,
//                     left: -screenWidth * 0.25,
//                     child: AnimatedBuilder(
//                       animation: _bubbleAnimationController!,
//                       builder: (context, child) {
//                         return Transform.translate(
//                           offset: Offset(
//                             0,
//                             _bubbleAnimationController!.value * 10,
//                           ),
//                           child: Container(
//                             width: screenWidth * 1.5,
//                             height: screenHeight * 0.5,
//                             decoration: BoxDecoration(
//                               color: const Color.fromRGBO(66, 134, 129, 0.07),
//                               borderRadius:
//                                   BorderRadius.circular(screenHeight * 0.25),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   Positioned(
//                     bottom: -screenHeight * 0.1,
//                     right: -screenWidth * 0.25,
//                     child: AnimatedBuilder(
//                       animation: _bubbleAnimationController!,
//                       builder: (context, child) {
//                         return Transform.translate(
//                           offset: Offset(
//                             0,
//                             -_bubbleAnimationController!.value * 10,
//                           ),
//                           child: Container(
//                             width: screenWidth * 0.9,
//                             height: screenHeight * 0.3,
//                             decoration: BoxDecoration(
//                               color: const Color.fromRGBO(66, 134, 129, 0.08),
//                               borderRadius:
//                                   BorderRadius.circular(screenHeight * 0.15),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   Positioned(
//                     top: screenHeight * 0.45,
//                     left: screenWidth * 0.05,
//                     child: AnimatedBuilder(
//                       animation: _bubbleAnimationController!,
//                       builder: (context, child) {
//                         return Transform.translate(
//                           offset: Offset(
//                             _bubbleAnimationController!.value * 5,
//                             _bubbleAnimationController!.value * 8,
//                           ),
//                           child: Container(
//                             width: 50,
//                             height: 50,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: const Color.fromRGBO(66, 134, 129, 0.2),
//                               border: Border.all(
//                                 color: const Color.fromRGBO(66, 134, 129, 0.3),
//                                 width: 1.5,
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   Positioned(
//                     top: screenHeight * 0.6,
//                     right: screenWidth * 0.1,
//                     child: AnimatedBuilder(
//                       animation: _bubbleAnimationController!,
//                       builder: (context, child) {
//                         return Transform.translate(
//                           offset: Offset(
//                             -_bubbleAnimationController!.value * 8,
//                             -_bubbleAnimationController!.value * 6,
//                           ),
//                           child: Container(
//                             width: 35,
//                             height: 35,
//                             decoration: const BoxDecoration(
//                               shape: BoxShape.circle,
//                               gradient: RadialGradient(
//                                 colors: [
//                                   Color.fromRGBO(72, 138, 163, 0.3),
//                                   Color.fromRGBO(72, 138, 163, 0.1),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//                 // Static background elements
//                 Positioned(
//                   top: screenHeight * 0.25,
//                   right: screenWidth * 0.15,
//                   child: Container(
//                     width: 8,
//                     height: 8,
//                     decoration: const BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Color.fromRGBO(72, 138, 163, 0.4),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   top: screenHeight * 0.26,
//                   right: screenWidth * 0.2,
//                   child: Container(
//                     width: 6,
//                     height: 6,
//                     decoration: const BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Color.fromRGBO(72, 138, 163, 0.3),
//                     ),
//                   ),
//                 ),
//                 // Back Button.
//                 Positioned(
//                   top: screenHeight * 0.03,
//                   left: screenWidth * 0.01,
//                   child: ElevatedButton.icon(
//                     onPressed: () {
//                       Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (_) => const AnothersympScreen()),
//                 );

//                     },

//                     icon:  Icon(
//                       Icons.arrow_back_ios_new,
//                       color: const Color.fromRGBO(61, 47, 40, 1),
//                       size: 26.sp,
//                     ),
//                     label: const Text(''),
//                     style: ButtonStyle(
//                   backgroundColor: WidgetStateProperty.all(Colors.transparent),
//                   elevation: WidgetStateProperty.all(0),
//                   shadowColor: WidgetStateProperty.all(Colors.transparent),
//                   overlayColor: WidgetStateProperty.all(Colors.transparent), 
//                 ),
//                   ),
//                 ),
//                 // Animated Header.
//                 AnimatedPositioned(
//                   duration: const Duration(seconds: 1),
//                   curve: Curves.easeInOut,
//                   top: _isAnimated ? screenHeight * 0.13 : -100,
//                   left: screenWidth * 0.1,
//                   child: Row(
//                     children: [
//                       Container(
//                         width: screenWidth * 0.15,
//                         height: screenWidth * 0.15,
//                         decoration: const BoxDecoration(
//                           shape: BoxShape.circle,
//                           boxShadow: [
//                             BoxShadow(
//                               color: Color.fromRGBO(66, 134, 129, 0.2),
//                               blurRadius: 10,
//                               offset: Offset(0, 4),
//                             ),
//                           ],
//                         ),
//                         child: Image.asset(
//                           'assets/paw.png',
//                           fit: BoxFit.contain,
//                         ),
//                       ),
//                       SizedBox(width: screenWidth * 0.05),
//                     ],
//                   ),
//                 ),
//                 // Form for symptom input.
//                 Positioned(
//                   top: screenHeight * 0.22,
//                   left: screenWidth * 0.12,
//                   right: screenWidth * 0.02,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       SlideInLeft(
//                         duration: const Duration(milliseconds: 1000),
//                         delay: const Duration(milliseconds: 300),
//                         from: 100,
//                         child: const Text(
//                           "Mention another sign or behavior that is unusual for your pet",
//                           style: TextStyle(
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                             color: Color.fromRGBO(29, 29, 44, 1.0),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 50.h),
//                       FadeIn(
//                         duration: const Duration(milliseconds: 800),
//                         delay: const Duration(milliseconds: 400),
//                         child: SizedBox(
//                           width: screenWidth * 0.8,
//                           child: Column(
//                             children: [
//                               Form(
//                                 key: _formKey,
//                                 child: TextFormField(
//                                   controller: _symptomController,
//                                   focusNode: _focusNode,
//                                   autofillHints: const [AutofillHints.name],
//                                   inputFormatters: [
//                                     FirstLetterUpperCaseTextFormatter(),
//                                     FilteringTextInputFormatter.deny(RegExp(r'[0-9]')),
//                                   ],
//                                   textInputAction: TextInputAction.done,
//                                   decoration: InputDecoration(
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(10.0),
//                                     ),
//                                     enabledBorder: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(12.0),
//                                       borderSide: const BorderSide(
//                                         color: Color.fromRGBO(82, 170, 164, 1),
//                                         width: 2.0,
//                                       ),
//                                     ),
//                                     focusedBorder: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(12.0),
//                                       borderSide: const BorderSide(
//                                         color: Color.fromRGBO(72, 38, 163, 1),
//                                         width: 2.0,
//                                       ),
//                                     ),
//                                     hintText: 'Enter a single symptom (e.g., Vomiting)',
//                                     contentPadding: const EdgeInsets.symmetric(
//                                       vertical: 20.0,
//                                       horizontal: 15.0,
//                                     ),
//                                   ),
//                                   validator: (value) {
//                                     if (value == null || value.isEmpty) {
//                                       return 'Please enter the symptom of the pet';
//                                     }
//                                     if (value.contains(',') || value.contains('+')) {
//                                       return 'Please enter only one symptom at a time';
//                                     }
//                                     final inputLower = value.trim().toLowerCase();
//                                     final userData =
//                                         Provider.of<UserData>(context, listen: false);
//                                     final petType = userData.selectedPetType;
//                                      final Map<String, dynamic> petSymptoms = {
//                                       // ...symptomQuestions,
//                                       if (petType == "Dog") ...symptomQuestionsDog,
//                                       if (petType == "Cat") ...symptomQuestionsCat,
//                                     };
//                                     final resolvedSymptom = resolveNlpSymptom(inputLower);

//                                     if (!petSymptoms.containsKey(resolvedSymptom)) {
//                                     return 'This symptom is not available for ${petType.toLowerCase()}';
//                                   }
//                                     if (userData.pendingSymptoms.contains(inputLower)) {
//                                       return 'This symptom is already added';
//                                     }
                                    
//                                     return null;
//                                   },
//                                 ),
//                               ),
//                               if (_showSuggestions)
//                                 Container(
//                                   width: screenWidth * 0.8,
//                                   constraints: const BoxConstraints(maxHeight: 170),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(10),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.grey.withOpacity(0.2),
//                                         spreadRadius: 1,
//                                         blurRadius: 5,
//                                       ),
//                                     ],
//                                   ),
//                                   child: ListView.builder(
//                                     shrinkWrap: true,
//                                     itemCount: _suggestedSymptoms.length,
//                                     padding: EdgeInsets.zero,
//                                     itemBuilder: (context, index) {
//                                       return ListTile(
//                                         title: Text(_capitalizeEachWord(_suggestedSymptoms[index])),
//                                         onTap: () {
//                                         final selected = _suggestedSymptoms[index];
//                                         final capitalized = _capitalizeEachWord(selected);  // 👈 Apply capitalization

//                                         _symptomController.text = capitalized;
//                                         _symptomController.selection = TextSelection.fromPosition(
//                                           TextPosition(offset: capitalized.length),
//                                         );

//                                         setState(() {
//                                           _showSuggestions = false;
//                                         });

//                                         FocusScope.of(context).unfocus(); // Optional: dismiss keyboard
//                                       }

//                                       );
//                                     },
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Positioned(
//                   top: screenHeight * 0.9,
//                   right: screenWidth * 0.02,
//                   child: SlideInUp(
//                     duration: const Duration(milliseconds: 1000),
//                     delay: const Duration(milliseconds: 300),
//                     from: 100,
//                     child: SizedBox(
//                       width: 100,
//                       child: ElevatedButton(
//                         onPressed: navigateToNextPage,
//                         style: ButtonStyle(
//                           backgroundColor: MaterialStateProperty.resolveWith((states) {
//                             if (states.contains(MaterialState.pressed)) {
//                               return const Color.fromARGB(255, 0, 0, 0);
//                             }
//                             return Colors.transparent;
//                           }),
//                           foregroundColor: MaterialStateProperty.resolveWith((states) {
//                             if (states.contains(MaterialState.pressed)) {
//                               return const Color.fromARGB(255, 255, 255, 255);
//                             }
//                             return const Color.fromRGBO(29, 29, 44, 1.0);
//                           }),
//                           shadowColor: MaterialStateProperty.all(Colors.transparent),
//                           side: MaterialStateProperty.all(
//                             const BorderSide(
//                               color: Color.fromRGBO(82, 170, 164, 1),
//                               width: 2.0,
//                             ),
//                           ),
//                           shape: MaterialStateProperty.all(
//                             const RoundedRectangleBorder(
//                               borderRadius: BorderRadius.all(Radius.circular(100)),
//                             ),
//                           ),
//                           fixedSize: MaterialStateProperty.all(const Size(100, 55)),
//                         ),
//                         child: const Text(
//                           "Next",
//                           style: TextStyle(
//                             fontSize: 22.0,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   bottom: 100.h,
//                   right: 16.w,
//                   child: AnimatedContainer(
//                     duration: Duration.zero,
//                     child: FloatingActionButton(
//                       onPressed: _navigateToSymptomCatalog,
//                       backgroundColor: const Color.fromRGBO(29, 29, 44, 1.0),
//                       foregroundColor: const Color(0xFFE8F2F5),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(100.r),
//                       ),
//                       child: const Icon(Icons.menu_book_sharp),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
