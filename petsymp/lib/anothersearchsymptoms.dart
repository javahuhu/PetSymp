import 'package:flutter/material.dart';
import 'QuestionDiseasesone/questionone.dart';
import 'package:provider/provider.dart';
import 'userdata.dart';
import 'package:auto_size_text/auto_size_text.dart';

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
  ...userData.petSymptoms,   // ✅ First inputted symptoms
].where((symptom) => symptom.isNotEmpty).join(" + ");  // ✅ Format correctly

// Avoid empty strings

    return Scaffold(
      backgroundColor: const Color(0xFFE8F2F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Back Button in Stack
              Container(
                height: screenHeight * 0.1, // Ensure Stack has height
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

                    // ✅ Dynamic Resizable Text
                    Expanded(
                      child: AutoSizeText(
                        "Select Another Symptoms",
                        maxLines: 1,
                        minFontSize: 12,
                        style: TextStyle(
                          fontSize: screenWidth * 0.08, // Dynamic Text Size
                          fontWeight: FontWeight.bold,
                          color: const Color.fromRGBO(29, 29, 44, 1.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.05),

              // Symptoms List
              buildSymptomsContainer(
                screenWidth,
                allSymptoms.isNotEmpty ? allSymptoms : "Select Another Symptoms",
                ["Drooling or licking lips excessively before", "or after vomiting."],
                const QoneScreen(),
              ),
              SizedBox(height: screenHeight * 0.03),

              buildSymptomsContainer(
                screenWidth,
                "Frequent Bowel Movements",
                ["Loose, watery stools."],
                const QoneScreen(),
              ),
              SizedBox(height: screenHeight * 0.03),

              buildSymptomsContainer(
                screenWidth,
                "Frequent Episodes",
                ["Repeated vomiting over a short period"],
                const QoneScreen(),
              ),

               SizedBox(height: screenHeight * 0.03),

              buildSymptomsContainer(
                screenWidth,
                "Frequent Episodes",
                ["Repeated vomiting over a short period"],
                const QoneScreen(),
              ),
              
            ],
          ),
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
