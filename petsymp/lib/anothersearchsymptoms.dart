import 'package:flutter/material.dart';
import 'QuestionDiseasesone/questionone.dart';
import 'package:provider/provider.dart';
import 'userdata.dart';

class AnothersearchsymptomsScreen extends StatefulWidget {
  const AnothersearchsymptomsScreen({super.key});

  @override
  AnothersearchsymptomsScreenState createState() =>
      AnothersearchsymptomsScreenState();
}

class AnothersearchsymptomsScreenState extends State<AnothersearchsymptomsScreen> {
  bool _isAnimated = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _isAnimated = true;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final userData = Provider.of<UserData>(context);

  String allSymptoms = [
  if (userData.selectedSymptom.isNotEmpty) userData.selectedSymptom, // ✅ Correct: selectedSymptom is a string
  if (userData.anotherSymptom.isNotEmpty) userData.anotherSymptom
].where((element) => element.isNotEmpty).join(" + "); // ✅ Prevents empty strings
 // Avoid empty strings

    return Scaffold(
      backgroundColor: const Color(0xFFE8F2F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: screenHeight + 25,
              width: screenWidth,
              child: Stack(
                children: [
               
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
                          SizedBox(width: screenWidth * 0.02),
                          Padding(
                            padding: EdgeInsets.only(top: screenHeight * 0.03),
                            child: const Text(
                              "Select Another Symptoms",
                              style: TextStyle(
                                fontSize: 27,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(29, 29, 44, 1.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Symptoms List
                    Positioned(
                      top: screenHeight * 0.25,
                      left: screenWidth * 0.05,
                      right: screenWidth * 0.05,
                      child: buildSymptomsContainer(
                        screenWidth,
                        allSymptoms.isNotEmpty ? allSymptoms : "Select Another Symptoms",
                        ["Drooling or licking lips excessively before", "or after vomiting."],
                        const QoneScreen(),
                      ),
                    ),
                    Positioned(
                      top: screenHeight * 0.45,
                      left: screenWidth * 0.05,
                      right: screenWidth * 0.05,
                      child: buildSymptomsContainer(
                        screenWidth,
                        "Frequent Bowel Movements",
                        ["Loose, watery stools."],
                        const QoneScreen(),
                      ),
                    ),
                    Positioned(
                      top: screenHeight * 0.628,
                      left: screenWidth * 0.05,
                      right: screenWidth * 0.05,
                      child: buildSymptomsContainer(
                        screenWidth,
                        "Frequent Episodes",
                        ["Repeated vomiting over a short period"],
                        const QoneScreen(),
                      ),
                    ),
                  ],
                 
               
              ),
            ),
          ],
        ),
      ),
      
    );
  }

  Widget buildSymptomsContainer(double screenWidth, String title,
      List<String> details, Widget navigate) {
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
              color: Color.fromARGB(255, 255, 255, 255),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => navigate),
                );
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith(
                  (states) {
                    if (states.contains(WidgetState.pressed)) {
                      return const Color.fromRGBO(66, 134, 130, 1.0);
                    }
                    return Colors.transparent;
                  },
                ),
                foregroundColor: WidgetStateProperty.resolveWith(
                  (states) {
                    if (states.contains(WidgetState.pressed)) {
                      return const Color.fromARGB(255, 255, 255, 255);
                    }
                    return const Color.fromARGB(255, 255, 255, 255);
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
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                  ),
                ),
                fixedSize: WidgetStateProperty.all(
                  const Size(120, 45),
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
