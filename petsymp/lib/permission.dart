import 'package:flutter/material.dart';
import 'package:petsymp/ageinput.dart';
import 'userdata.dart';
import 'package:provider/provider.dart';
class PermissionScreen extends StatefulWidget {
 const PermissionScreen({super.key});

  @override
  PermissionScreenState createState() => PermissionScreenState();
}

class PermissionScreenState extends State<PermissionScreen> {
  bool _isAnimated = false; // Animation toggle // State to track the selected tab

  @override
  void initState() {
    super.initState();
    // Trigger the animation after the widget builds
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimated = true;
      });
    });
  }

  

  

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final userName = Provider.of<UserData>(context).userName;

    return Scaffold(
      backgroundColor: const Color(0xFFE8F2F5),
      body: Stack(
        children: [
         // Show this layout only on the first tab
            Stack(
              children: [
                // AnimatedPositioned for Paw Image
                AnimatedPositioned(
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  top: _isAnimated ? screenHeight * 0.13 : -100, // From off-screen to final position
                  left: screenWidth * 0.1,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: screenWidth * 0.15, // 15% of screen width
                        height: screenWidth * 0.15, // Equal height for circular image
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/paw.png',
                          fit: BoxFit.contain,
                        ),
                      ),

                      SizedBox(width: screenWidth * 0.05), // 5% of screen width for spacing

                      // Text beside the image
                      Padding(
                        padding: EdgeInsets.only(top: screenHeight * 0.03), // Relative padding
                        child:   Text(
                          "Hi, $userName",
                          style:  const TextStyle(
                            fontSize: 27, // Fixed font size for readability
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(29, 29, 44, 1.0), // Make the text bold
                          ),
                        ),
                      ),
                       // Spacing between paw and text
                      
                    ],
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.22, // Text and input below the paw
                  left: screenWidth * 0.12,
                  right: screenWidth * 0.02,
                  child:  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text(
                        "Please provide the following basic information Regarding to your pet",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.normal,
                          color: Color.fromRGBO(29, 29, 44, 1.0),
                        ),
                      ),
                      
                    ],
                  ),
                ),

                // Next Button at the previous position
                Positioned(
                top: screenHeight * 0.9,
                right: screenWidth * 0.02, // Adjust dynamically for right alignment
                child: SizedBox( // Wrap with SizedBox to ensure correct width
                  width: 150, // Adjust as needed
                  child: ElevatedButton(
                    onPressed: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute
                    (builder: (context) =>  const AgeinputScreen()),
                  );
                  },
                    style: ButtonStyle(
                    // Dynamic background color based on button state
                    backgroundColor: WidgetStateProperty.resolveWith(
                      (states) {
                        if (states.contains(WidgetState.pressed)) {
                          return const Color.fromARGB(255, 0, 0, 0); // Background color when pressed
                        }
                        return Colors.transparent; // Default background color
                      },
                    ),
                    // Dynamic text color based on button state
                    foregroundColor: WidgetStateProperty.resolveWith(
                      (states) {
                        if (states.contains(WidgetState.pressed)) {
                          return const Color.fromARGB(255, 255, 255, 255); // Text color when pressed
                        }
                        return const Color.fromRGBO(29, 29, 44, 1.0); // Default text color
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
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                      ),
                    ),
                    fixedSize: WidgetStateProperty.all(
                      const Size(100, 55),
                    ),
                  ),
                    child: const Text(
                      "CONFIRM",
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              ],
            ),
         
        ],
      ),
      
    );
  }
}
