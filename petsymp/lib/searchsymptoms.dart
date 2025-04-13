import 'package:flutter/material.dart';
import 'package:petsymp/QuestionDiseasesone/questionone.dart';
import 'package:petsymp/SymptomQuestions/CatQuestions.dart';
import 'package:petsymp/SymptomQuestions/DogQuestions.dart';
import 'package:petsymp/SymptomQuestions/symptomsquestions.dart';
import 'package:provider/provider.dart';
import 'package:petsymp/userdata.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:petsymp/symptomscatalog.dart';
import 'package:animate_do/animate_do.dart';

class SearchsymptomsScreen extends StatefulWidget {
  /// Expected to be a single-element list with the input symptom.
  final List<String> symptoms;

  const SearchsymptomsScreen({super.key, required this.symptoms});

  @override
  SearchsymptomsScreenState createState() => SearchsymptomsScreenState();
}

class SearchsymptomsScreenState extends State<SearchsymptomsScreen>
    with SingleTickerProviderStateMixin {
  bool _isAnimated = false;
  bool _isNavigating = false;
  AnimationController? _bubbleAnimationController;
  
  // Map for additional descriptions.
  final Map<String, String> _symptomDescriptions = {
    'diarrhea': 'Loose, watery stools occurring more frequently than usual.',
    'vomiting': 'Forceful expulsion of stomach contents through the mouth.',
    'coughing': 'Sudden expulsion of air from the lungs to clear the passages.',
    'fever': 'Abnormally high body temperature, often indicating infection.',
    'lethargy': 'Unusual tiredness or decreased activity.',
    'loss of appetite': 'Reduced desire to eat despite a normal feeding schedule.',
    // Add more as needed.
  };

  @override
  void initState() {
    super.initState();
    _bubbleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _isAnimated = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _bubbleAnimationController?.dispose();
    super.dispose();
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
    final userData = Provider.of<UserData>(context, listen: false);
    final petType = userData.selectedPetType;

    final Map<String,dynamic> petSymptoms = {
      ...symptomQuestions,
      if(petType == 'Dog') ...symptomQuestionsDog,
      if(petType == 'Cat') ...symptomQuestionsCat,
    };

    final List<String> predefinedSymptoms = petSymptoms.keys.toList();

    // Determine the input symptom.
    String inputSymptom = "";
    if (widget.symptoms.isNotEmpty && widget.symptoms[0].trim().isNotEmpty) {
      inputSymptom = widget.symptoms[0].toLowerCase();
    }

    // Build the symptom list: input symptom at top, then others excluding it.
    List<String> symptomList = [];
    if (inputSymptom.isNotEmpty) {
      symptomList.add(inputSymptom);
      symptomList.addAll(predefinedSymptoms.where((s) => s.toLowerCase() != inputSymptom));
    } else {
      symptomList = predefinedSymptoms;
    }

    if (symptomList.isEmpty) {
      return Scaffold(
        body: Container(
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("No symptoms available.", style: TextStyle(fontSize: 20, color: Colors.black)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(29, 29, 44, 1.0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                  child: const Text("Go Back"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Container(
        width: screenWidth,
        height: screenHeight,
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
        child: SafeArea(
          child: Column(
            children: [
              // Back button and header.
              SizedBox(
                height: 60.h,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 10.h),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_sharp, color: Color.fromRGBO(61, 47, 40, 1), size: 32.0),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              SlideInLeft(
                duration: const Duration(milliseconds: 1000),
                from: 50,
                child: AutoSizeText(
                  "Select Symptoms",
                  maxLines: 1,
                  minFontSize: 12,
                  style: TextStyle(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Oswald',
                    color: const Color.fromRGBO(29, 29, 44, 1.0),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              // Scrollable list of symptom cards.
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(screenWidth * 0.05, 5.h, screenWidth * 0.05, 80.h),
                  itemCount: symptomList.length,
                  itemBuilder: (context, index) {
                    final symptom = symptomList[index];
                    return FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: Duration(milliseconds: index * 100),
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 15.h),
                        child: buildSymptomsContainer(screenWidth, symptom, context),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToSymptomCatalog,
        backgroundColor: const Color.fromRGBO(29, 29, 44, 1.0),
        foregroundColor: const Color(0xFFE8F2F5),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100.r)),
        child: const Icon(Icons.menu_book_sharp),
      ),
    );
  }

  /// Builds a card for a given symptom.
  Widget buildSymptomsContainer(double screenWidth, String title, BuildContext context) {
    final symptomKey = title.toLowerCase();
    final description = _symptomDescriptions[symptomKey] ??
        'A common symptom that may indicate health issues in your pet.';
        
    return Container(
      padding: EdgeInsets.all(16.sp),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(29, 29, 44, 1.0),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
        border: Border.all(
          color: const Color.fromRGBO(66, 134, 129, 0.3),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Symptom title.
          Text(
            title[0].toUpperCase() + title.substring(1),
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          // Description.
          Text(
            description,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
          SizedBox(height: 16.h),
          // Select button.
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                final userData = Provider.of<UserData>(context, listen: false);
                // Instead of immediately adding to pending,
                // set the selected symptom and update the questions.
                userData.setSelectedSymptom(title);
                userData.updateQuestions();
                debugPrint("✅ Selected Symptom: $title");
                debugPrint("✅ Updated Questions: ${userData.questions}");
                // Navigate to QoneScreen.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QoneScreen(
                      symptom: title,
                      questions: List<String>.from(userData.questions),
                      impactChoices: List<List<String>>.from(userData.impactChoices),
                    ),
                  ),
                );
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.pressed)) {
                    return const Color.fromRGBO(66, 134, 130, 1.0);
                  }
                  return Colors.transparent;
                }),
                foregroundColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.pressed)) {
                    return const Color.fromARGB(255, 255, 255, 255);
                  }
                  return const Color.fromARGB(255, 255, 255, 255);
                }),
                shadowColor: MaterialStateProperty.all(Colors.transparent),
                side: MaterialStateProperty.all(
                  const BorderSide(
                    color: Color.fromRGBO(82, 170, 164, 1),
                    width: 2.0,
                  ),
                ),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6.r)),
                  ),
                ),
                padding: MaterialStateProperty.all(
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                ),
                fixedSize: MaterialStateProperty.all(
                  Size(120.w, 45.h),
                ),
              ),
              child: const Text(
                "Select",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
