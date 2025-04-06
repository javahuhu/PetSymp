import 'package:flutter/material.dart';
import 'package:petsymp/QuestionDiseasesone/questionone.dart';
import 'package:provider/provider.dart';
import 'userdata.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'symptomscatalog.dart';

class AnothersearchsymptomsScreen extends StatefulWidget {
  const AnothersearchsymptomsScreen({super.key});

  @override
  AnothersearchsymptomsScreenState createState() =>
      AnothersearchsymptomsScreenState();
}

class AnothersearchsymptomsScreenState extends State<AnothersearchsymptomsScreen> {
  bool _isAnimated = false;
  final List<bool> _buttonVisible = [false, false, false, false, false, false];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _isAnimated = true;
      });
      for (int i = 0; i < _buttonVisible.length; i++) {
        final int index = i;
        Future.delayed(Duration(milliseconds: 300 * index), () {
          if (!mounted) return;
          setState(() {
            _buttonVisible[index] = true;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth  = MediaQuery.of(context).size.width;
    final userData = Provider.of<UserData>(context);

    // Instead of checking the temporary anotherSymptom field,
    // use the last element in pendingSymptoms.
    String displayedSymptom = "";
    if (userData.pendingSymptoms.isNotEmpty) {
      displayedSymptom = userData.pendingSymptoms.last;
    } else if (userData.selectedSymptom.isNotEmpty) {
      displayedSymptom = userData.selectedSymptom;
    } else {
      displayedSymptom = "Select Another Symptoms";
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE8F2F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Back Button
              SizedBox(
                height: screenHeight * 0.1,
                child: Stack(
                  children: [
                    Positioned(
                      top: screenHeight * 0.03,
                      left: -screenWidth * 0.05,
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
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              // Animated Header
              AnimatedOpacity(
                duration: const Duration(seconds: 1),
                opacity: _isAnimated ? 1 : 0,
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
                    Expanded(
                      child: AutoSizeText(
                        "Select Another Symptoms",
                        maxLines: 1,
                        minFontSize: 12,
                        style: TextStyle(
                          fontSize: screenWidth * 0.08,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromRGBO(29, 29, 44, 1.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 70),
              // Container that shows the latest symptom (from pendingSymptoms)
              buildSymptomsContainer(
                screenWidth,
                displayedSymptom,
                ["Tap to select and answer questions for new symptoms"],
              ),
              SizedBox(height: 5),
              // Additional hardcoded symptom containers (if needed)
              buildSymptomsContainer(
                screenWidth,
                "Frequent Bowel Movements",
                ["Loose, watery stools."],
              ),
              SizedBox(height: 5),
              buildSymptomsContainer(
                screenWidth,
                "Frequent Episodes",
                ["Repeated vomiting over a short period"],
              ),
              SizedBox(height: 0),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(

    onPressed: () {
       Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SymptomscatalogScreen(),
                  ));
    },
    backgroundColor: const Color.fromRGBO(29, 29, 44, 1.0), // Changes the button color to red.
    foregroundColor: const Color(0xFFE8F2F5),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(100.r), // Circular shape
    ),
    child: const Icon(Icons.menu_book_sharp),
  ),
  floatingActionButtonLocation: CustomFABLocation(topOffset: 650.0.h, rightOffset: 16.0.w),
    );
  }

  Widget buildSymptomsContainer(
      double screenWidth, String title, List<String> details) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(29, 29, 44, 1.0),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(255, 255, 255, 1),
            ),
          ),
          const SizedBox(height: 8),
          for (String detail in details)
            Text(
              detail,
              style: const TextStyle(
                fontSize: 18,
                color: Color.fromRGBO(210, 216, 216, 1),
              ),
            ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final userData =
                      Provider.of<UserData>(context, listen: false);
                  // Add this symptom and set it as the selected symptom.
                  userData.addNewPetSymptom(title);
                  userData.setSelectedSymptom(title);
                  // Update the questions for the selected symptom.
                  userData.updateQuestions();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QoneScreen(
                        symptom: title,
                        questions: List<String>.from(userData.questions),
                        impactChoices:
                            List<List<String>>.from(userData.impactChoices),
                      ),
                    ),
                  );
                });
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
                  const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                  ),
                ),
                fixedSize: WidgetStateProperty.all(const Size(120, 45)),
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

class CustomFABLocation extends FloatingActionButtonLocation {
  final double topOffset;
  final double rightOffset;

  CustomFABLocation({this.topOffset = 100.0, this.rightOffset = 16.0});

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final fabSize = scaffoldGeometry.floatingActionButtonSize;
    final double x = scaffoldGeometry.scaffoldSize.width - fabSize.width - rightOffset;
    final double y = topOffset;
    return Offset(x, y);
  }
}
