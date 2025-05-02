import 'package:flutter/material.dart';
import 'package:petsymp/QuestionDiseasesone/questionone.dart';
import 'package:petsymp/SymptomQuestions/CatQuestions.dart';
import 'package:petsymp/SymptomQuestions/DogQuestions.dart';
import 'package:petsymp/SymptomQuestions/symptomsquestions.dart';
import 'package:provider/provider.dart';
import '../userdata.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../SymptomsCatalog/symptomscatalog.dart';
import 'package:animate_do/animate_do.dart';
import 'package:petsymp/Assesment/anothersymptoms.dart';
import 'mentionsymptoms.dart';
import 'package:petsymp/searchdescription.dart';

class AnothersearchsymptomsScreen extends StatefulWidget {
  final List<String> symptoms;

  const AnothersearchsymptomsScreen({super.key, required this.symptoms});

  @override
  AnothersearchsymptomsScreenState createState() =>
      AnothersearchsymptomsScreenState();
}

class AnothersearchsymptomsScreenState extends State<AnothersearchsymptomsScreen>
    with SingleTickerProviderStateMixin {
  bool _isAnimated = false;
  bool _isNavigating = false;
  AnimationController? _bubbleAnimationController;


  @override
  void initState() {
    super.initState();
    _bubbleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _isAnimated = true;
      });
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


    String _capitalizeEachWord(String text) {
  return text
      .split(' ')
      .map((word) => word.isNotEmpty
          ? word[0].toUpperCase() + word.substring(1)
          : '')
      .join(' ');
}


  @override
  Widget build(BuildContext context) {
    // Screen dimensions.
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final UserData userData = Provider.of<UserData>(context, listen: false);
    final petType = userData.selectedPetType;

    final Map<String, dynamic> petSymptoms = {
      // ...symptomQuestions,
      if(petType == 'Dog') ...symptomQuestionsDog,
      if(petType == 'Cat') ...symptomQuestionsCat,
    };

    // Get predefined symptoms from userData.
    final List<String> predefinedSymptoms = petSymptoms.keys.toList();

    // Define additional symptoms.
    final List<String> additionalSymptoms = [
      'Frequent Bowel Movements',
      'Frequent Episodes',
    ];

    
    String inputSymptom = "";
    if (widget.symptoms.isNotEmpty && widget.symptoms[0].trim().isNotEmpty) {
      inputSymptom = widget.symptoms[0].toLowerCase();
    }

    // Determine the candidate symptom:
    // Priority: pending > selected > input.
    String candidateSymptom = "";
    if (userData.pendingSymptoms.isNotEmpty) {
      candidateSymptom = userData.pendingSymptoms.last;
    } else if (userData.selectedSymptom.isNotEmpty) {
      candidateSymptom = userData.selectedSymptom;
    } else if (inputSymptom.isNotEmpty) {
      candidateSymptom = inputSymptom;
    }

    List<String> candidateList = [];
    if (inputSymptom.isNotEmpty) candidateList.add(inputSymptom);
    candidateList.addAll(predefinedSymptoms);
    candidateList.addAll(additionalSymptoms);

  
    List<String> uniqueList = [];
    for (String s in candidateList) {
      if (!uniqueList.any((u) => u.toLowerCase() == s.toLowerCase())) {
        uniqueList.add(s);
      }
    }

  
    final Set<String> pendingSet =
        userData.pendingSymptoms.map((s) => s.toLowerCase()).toSet();
    uniqueList.removeWhere((s) => pendingSet.contains(s.toLowerCase()));

    
    if (candidateSymptom.isNotEmpty) {
      uniqueList.removeWhere((s) =>
          s.toLowerCase() == candidateSymptom.toLowerCase());
    }

    final List<String> symptomList = uniqueList;

    // If no selectable symptoms exist, show an error page.
    if (symptomList.isEmpty && candidateSymptom.isEmpty) {
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
                const Text("No symptoms available.",
                    style: TextStyle(fontSize: 20, color: Colors.black)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const MentionsympScreen()),
                  );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(29, 29, 44, 1.0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
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
        child: Stack(
          children: [
            // Animated background bubbles.
            if (_bubbleAnimationController != null) ...[
              Positioned(
                top: -screenHeight * 0.2,
                left: -screenWidth * 0.25,
                child: AnimatedBuilder(
                  animation: _bubbleAnimationController!,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _bubbleAnimationController!.value * 10),
                      child: Container(
                        width: screenWidth * 1.5,
                        height: screenHeight * 0.5,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(66, 134, 129, 0.07),
                          borderRadius:
                              BorderRadius.circular(screenHeight * 0.25),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: -screenHeight * 0.1,
                right: -screenWidth * 0.25,
                child: AnimatedBuilder(
                  animation: _bubbleAnimationController!,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, -_bubbleAnimationController!.value * 10),
                      child: Container(
                        width: screenWidth * 0.9,
                        height: screenHeight * 0.3,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(66, 134, 129, 0.08),
                          borderRadius:
                              BorderRadius.circular(screenHeight * 0.15),
                        ),
                      ),
                    );
                  },
                ),
              ),
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
            // Static background dots.
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
            // Main content.
            SafeArea(
              child: Column(
                children: [
                  // Back button and header.
                  SizedBox(
                    height: 60.h,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.05, vertical: 10.h),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(
                              Icons.arrow_back_ios_new,
                              color: const Color.fromRGBO(61, 47, 40, 1),
                              size: 26.sp,
                            ),

                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(Colors.transparent),
                              elevation: WidgetStateProperty.all(0),
                              shadowColor: WidgetStateProperty.all(Colors.transparent),
                              overlayColor: WidgetStateProperty.all(Colors.transparent), 
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  // Animated header title.
                  AnimatedOpacity(
                    duration: const Duration(seconds: 1),
                    opacity: _isAnimated ? 1 : 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SlideInLeft(
                          duration: const Duration(milliseconds: 1000),
                          from: 50,
                          child: AutoSizeText(
                            "Select Another Symptoms",
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
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  // If a candidate (pending or input) symptom exists, show it as a header.
                  if (candidateSymptom.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          "Symptoms: ${_capitalizeEachWord(candidateSymptom)}",
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 10.h),
                  // Selectable symptom list.
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.fromLTRB(screenWidth * 0.07, 5.h, screenWidth * 0.07, 80.h),
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
            // Floating catalog button.
            Positioned(
              bottom: 50.h,
              right: 16.w,
              child: FloatingActionButton(
                onPressed: _navigateToSymptomCatalog,
                backgroundColor: const Color.fromRGBO(29, 29, 44, 1.0),
                foregroundColor: const Color(0xFFE8F2F5),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.r)
                ),
                child: const Icon(Icons.menu_book_sharp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a card for a given symptom.
  /// The "Select" button sets the symptom as selected and updates the questions,
  /// then navigates to QoneScreen. It does not add the symptom to pending immediately.
  Widget buildSymptomsContainer(double screenWidth, String title, BuildContext context) {
    final String symptomKey = title.toLowerCase();
    final String description = symptomDescriptions[symptomKey] ??
        'No Description Available.';
        
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
            _capitalizeEachWord(title),
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: const Color.fromRGBO(255, 255, 255, 1),
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
                    userData.addPendingSymptom(title, source: 'auto');
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
                    return Colors.white;
                  }
                  return Colors.white;
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
                fixedSize: WidgetStateProperty.all(Size(120.w, 45.h)),
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
