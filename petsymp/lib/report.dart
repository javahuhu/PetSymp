import 'package:flutter/material.dart';
import 'package:petsymp/Summaryinput.dart';
import 'userdata.dart';
import 'package:provider/provider.dart';
class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  ReportScreenState createState() =>ReportScreenState();
}

class ReportScreenState extends State<ReportScreen> {
  bool _isAnimated = false; // Animation toggle
  // State to track the selected tab

  // Control the visibility of buttons
  final List<bool> _buttonVisible = [false, false, false, false, false, false];

  @override
  void initState() {
    super.initState();
    // Trigger the animation for each button with a delay
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _isAnimated = true;
      });
      for (int i = 0; i < _buttonVisible.length; i++) {
        Future.delayed(Duration(milliseconds: 300 * i), () {
          setState(() {
            _buttonVisible[i] = true; // Make each button visible sequentially
          });
        });
      }
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
          
            Stack(
              children: [
                // Back Button
                Positioned(
                  top: screenHeight * 0.03,
                  left: screenWidth * 0.01,
                  child: ElevatedButton.icon(
                    onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context); // ✅ Only pops if there's a previous route
                    } 
                  },
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
                // Animated Header
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
                    ],
                  ),
                ),
                // Title Section
                Positioned(
                  top: screenHeight * 0.22,
                  left: screenWidth * 0.12,
                  right: screenWidth * 0.02,
                  child:  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text(
                        "Thank you, $userName I have put together a report to your inputs.",
                        style:const  TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(29, 29, 44, 1.0),
                        ),
                      ),

                       

                      

                      const SizedBox(height: 50),
                    ],
                  ),
                ),
                // Animated Buttons
                
                buildAnimatedButton(
                    screenHeight * 1.03, screenWidth, 0.87, "Continue", const SummaryScreen(),1),
              
              ],
            ),
         
        ],
      ),
      
    );
  }

  // Method to create an animated button
  Widget buildAnimatedButton(double screenHeight, double screenWidth,
      double topPosition,String label, Widget destination, int index) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      top: _buttonVisible[index] ? screenHeight * topPosition : screenHeight,
      left: screenWidth * 0.65,
      child: ElevatedButton(
        onPressed: () {
          
         Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => destination),
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
                      const Size(155, 55),
                    ),
                  ),
              child: Text(
          label,
          style: const TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
