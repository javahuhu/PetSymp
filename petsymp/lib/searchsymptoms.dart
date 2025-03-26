import 'package:flutter/material.dart';
import 'package:petsymp/QuestionDiseasesone/questionone.dart';
import 'package:provider/provider.dart';
import 'package:petsymp/userdata.dart';
import 'package:auto_size_text/auto_size_text.dart';

class SearchsymptomsScreen extends StatefulWidget {
  final List<String> symptoms;

  const SearchsymptomsScreen({super.key, required this.symptoms});

  @override
  SearchsymptomsScreenState createState() => SearchsymptomsScreenState();
}

class SearchsymptomsScreenState extends State<SearchsymptomsScreen> {
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
    final userData = Provider.of<UserData>(context, listen: false);

    // Get the predefined symptoms from userData.
    final List<String> predefinedSymptoms = userData.getPredefinedSymptoms();

    // Filter the provided list (which now contains a single string)
    final List<String> matchedSymptoms = widget.symptoms.where((symptom) {
      return predefinedSymptoms.contains(symptom.toLowerCase());
    }).toList();

    // If no matching symptom is found, show a message.
    if (matchedSymptoms.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFE8F2F5),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "No such symptom found.",
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Go Back"),
              )
            ],
          ),
        ),
      );
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
                        "Select Symptoms",
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
              SizedBox(height: screenHeight * 0.05),
              // Dynamic symptom containers for matched symptoms
              ...matchedSymptoms.map((symptom) {
                return Column(
                  children: [
                    buildSymptomsContainer(
                      screenWidth,
                      symptom,
                      ["Tap to select this symptom and answer questions"],
                      context,
                    ),
                    SizedBox(height: screenHeight * 0.03),
                  ],
                );
              }),
              // Add standard symptoms that aren't in the user's input.
              if (!matchedSymptoms.contains("Reduced Appetite") &&
                  !widget.symptoms.any((s) =>
                      s.toLowerCase() == "reduced appetite"))
                Column(
                  children: [
                    buildSymptomsContainer(
                      screenWidth,
                      "Reduced Appetite",
                      [
                        "Consuming little or having little appetite for",
                        "food or treats."
                      ],
                      context,
                    ),
                    SizedBox(height: screenHeight * 0.03),
                  ],
                ),
              if (!matchedSymptoms.contains("Low Energy") &&
                  !widget.symptoms.any((s) => s.toLowerCase() == "low energy"))
                buildSymptomsContainer(
                  screenWidth,
                  "Low Energy",
                  [
                    "Less attentive to stimuli such as food, toys,",
                    "or your own voice."
                  ],
                  context,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSymptomsContainer(
      double screenWidth, String title, List<String> details, BuildContext context) {
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
                final userData = Provider.of<UserData>(context, listen: false);
                // If title contains a comma, split it into individual symptoms.
                if (title.contains(',')) {
                  List<String> symptoms =
                      title.split(',').map((s) => s.trim()).toList();
                  for (String s in symptoms) {
                    userData.addNewPetSymptom(title);
                  }
                  // Do NOT call setSelectedSymptom when multiple symptoms are present.
                } else {
                  userData.addNewPetSymptom(title);
                  userData.setSelectedSymptom(title);
                }
                print("✅ Selected Symptom: $title");
                print("✅ Updated Questions: ${userData.questions}");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QoneScreen(),
                  ),
                );
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
