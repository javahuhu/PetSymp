import 'package:flutter/material.dart';
import 'package:flutter/services.dart';



class RecoveryScreen extends StatefulWidget {
  const RecoveryScreen({super.key});

  @override
  RecoveryScreenState createState() => RecoveryScreenState();
}

class RecoveryScreenState extends State<RecoveryScreen> {
   final List<TextEditingController> _otpControllers =
      List.generate(6, (index) => TextEditingController()); // 4-digit OTP
  final List<FocusNode> _focusNodes =
      List.generate(6, (index) => FocusNode());

  
  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFE8F2F5),
      body: Stack(
        children: [

          Positioned(
              top: screenHeight * 0.037,
              left: screenWidth * 0.25,
              width: screenWidth * 5,
              child: const Text('Recovery Password', style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(29, 29, 44, 1.0),
                        ),)),
          
          
          Positioned(
            top: screenHeight * 0.03,
            left: screenWidth * 0.01,
            child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_sharp,
                  color:  Color.fromRGBO(61, 47, 40, 1),
                  size: 40.0,),
                  label: const Text(''),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                  ),
                ),), // Show this layout only on the first tab
            Stack(
              children: [
              
                Positioned(
                  top: screenHeight * 0.22, // Text and input below the paw
                  left: screenWidth * 0.321,
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text(
                        "OTP Verification",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(29, 29, 44, 1.0),
                        ),
                      ),
                      
                   
                     
                    ],
                  ),
                ),


                
                 // OTP Input Field
        Positioned(top: screenHeight *0.35, left: screenWidth * 0.1325, child: 
          Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (index) => _buildOtpBox(index)),
        ),
      )),



                // Next Button at the previous position
                Positioned(
                  top: screenHeight * 0.7,
                  left: screenWidth * 0.380,
                
                  child: ElevatedButton(
                     onPressed: () {
                              Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RecoveryScreen()),
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
                      const Size(120, 55),
                    ),
                  ),
                    child: const Text(
                      "Verify",
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
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

  Widget _buildOtpBox(int index) {
    return Container(
      width: 50, // ✅ Box size
      margin:const EdgeInsets.symmetric(horizontal: 5), // ✅ Spacing
      child: TextFormField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number, // ✅ Numeric Keyboard
        textAlign: TextAlign.center, // ✅ Center Text
        maxLength: 1, // ✅ Allow only 1 digit
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), // ✅ Styling
        decoration: InputDecoration(
          counterText: "", // ✅ Hide character counter
          enabledBorder: OutlineInputBorder(
            borderSide:const BorderSide(color: Color.fromARGB(255, 0, 0, 0), width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color.fromARGB(255, 95, 74, 110), width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly, // ✅ Numbers only
        ],
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < _otpControllers.length - 1) {
              FocusScope.of(context).requestFocus(_focusNodes[index + 1]); // ✅ Move to next box
            } else {
              FocusScope.of(context).unfocus(); // ✅ Close keyboard if last digit is entered
            }
          }
        },
      ),
    );
  }
}
