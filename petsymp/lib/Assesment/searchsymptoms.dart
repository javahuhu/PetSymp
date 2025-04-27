import 'package:flutter/material.dart';
import 'package:petsymp/QuestionDiseasesone/questionone.dart';
import 'package:petsymp/SymptomQuestions/CatQuestions.dart';
import 'package:petsymp/SymptomQuestions/DogQuestions.dart';
import 'package:petsymp/SymptomQuestions/symptomsquestions.dart';
import 'package:provider/provider.dart';
import 'package:petsymp/userdata.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:petsymp/SymptomsCatalog/symptomscatalog.dart';
import 'package:animate_do/animate_do.dart';
import 'package:petsymp/Assesment/anothersymptoms.dart';
import 'package:petsymp/searchdescription.dart';

class SearchsymptomsScreen extends StatefulWidget {
  /// Expected to be a single-element list with the input symptom.
  final List<String> symptoms;

  const SearchsymptomsScreen({super.key, required this.symptoms});

  @override
  SearchsymptomsScreenState createState() => SearchsymptomsScreenState();
}

class SearchsymptomsScreenState extends State<SearchsymptomsScreen>
    with SingleTickerProviderStateMixin {
  bool _isNavigating = false;
  AnimationController? _bubbleAnimationController;
  @override
void initState() {
  super.initState();

  _bubbleAnimationController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  )..repeat(reverse: true);



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
                        onPressed: () {
                          Navigator.of(context).pop();
                        },

                    style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.transparent),
                  elevation: WidgetStateProperty.all(0),
                  shadowColor: WidgetStateProperty.all(Colors.transparent),
                  overlayColor: WidgetStateProperty.all(Colors.transparent), 
                ),

                        icon: Icon(Icons.arrow_back_ios_new, color: const Color.fromRGBO(61, 47, 40, 1), size: 26.sp),
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
    final description = symptomDescriptions[symptomKey] ??
        'No Description available.'; 
        
    return Container(
      padding: EdgeInsets.all(16.sp),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(29, 29, 44, 1.0),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset:  Offset(2, 2),
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
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          SizedBox(height: 16.h),
          // Select button.
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
             onPressed: () {
                  final userData = Provider.of<UserData>(context, listen: false);
                  userData.setSelectedSymptom(title);
                  userData.updateQuestions();

                  if (userData.questions.isEmpty) {
                    // 🔵 No follow-up → instantly add to pending + go to next screen
                    userData.addPendingSymptom(title);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AnothersympScreen()),
                    );
                  } else {
                   
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
                  }
                },

              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.pressed)) {
                    return const Color.fromRGBO(66, 134, 130, 1.0);
                  }
                  return Colors.transparent;
                }),
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.pressed)) {
                    return const Color.fromARGB(255, 255, 255, 255);
                  }
                  return const Color.fromARGB(255, 255, 255, 255);
                }),
                shadowColor: WidgetStateProperty.all(Colors.transparent),
                side: WidgetStateProperty.all(
                  const BorderSide(
                    color: Color.fromRGBO(82, 170, 164, 1),
                    width: 2.0,
                  ),
                ),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6.r)),
                  ),
                ),
                padding: WidgetStateProperty.all(
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                ),
                fixedSize: WidgetStateProperty.all(
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
