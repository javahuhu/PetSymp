import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:petsymp/duration.dart';
import 'package:petsymp/userdata.dart'; // Import UserData Provider

class SearchsymptomsScreen extends StatefulWidget {
  final String petSymptom;

  const SearchsymptomsScreen({super.key, required this.petSymptom});

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

    return Scaffold(
      backgroundColor: const Color(0xFFE8F2F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          children: [
            SizedBox(
              height: screenHeight + 35,
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
                          SizedBox(width: screenWidth * 0.05),
                          Padding(
                            padding: EdgeInsets.only(top: screenHeight * 0.03),
                            child: const Text(
                              "Select Symptoms",
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
                    Positioned(
                      top: screenHeight * 0.25,
                      left: screenWidth * 0.05,
                      right: screenWidth * 0.05,
                      child: buildSymptomsContainer(
                        screenWidth,
                        widget.petSymptom,
                        ["Unwillingness into activity, recreation, or", "movement."],
                        context, // Pass context for Provider
                      ),
                    ),
                    Positioned(
                      top: screenHeight * 0.45,
                      left: screenWidth * 0.05,
                      right: screenWidth * 0.05,
                      child: buildSymptomsContainer(
                        screenWidth,
                        "Reduced Appetite",
                        ["Consuming little or having little appetite for", "food or treats."],
                        context,
                      ),
                    ),
                    Positioned(
                      top: screenHeight * 0.65,
                      left: screenWidth * 0.05,
                      right: screenWidth * 0.05,
                      child: buildSymptomsContainer(
                        screenWidth,
                        "Low Energy",
                        ["Less attentive to stimuli such as food, toys,", "or your own voice."],
                        context,
                      ),
                    ),

                    Positioned(
                      top: screenHeight * 0.85,
                      left: screenWidth * 0.05,
                      right: screenWidth * 0.05,
                      child: buildSymptomsContainer(
                        screenWidth,
                        "Low Energy",
                        ["Less attentive to stimuli such as food, toys,", "or your own voice."],
                        context,
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

                userData.setSelectedSymptom(title);
                userData.addPetSymptom(title);

                // Navigate to DurationScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DurationScreen(),
                  ),
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
