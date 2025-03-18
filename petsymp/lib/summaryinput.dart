import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'userdata.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  SummaryScreenState createState() => SummaryScreenState();
}

class SummaryScreenState extends State<SummaryScreen> {
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
        Future.delayed(Duration(milliseconds: 300 * i), () {
          setState(() {
            _buttonVisible[i] = true;
          });
        });
      }
    });
  }

    String truncateText(String text, int maxLength) {
  return (text.length > maxLength) ? '${text.substring(0, maxLength)}...' : text;
}


  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final userData = Provider.of<UserData>(context);



    String allSymptoms = truncateText({
  if (userData.selectedSymptom.isNotEmpty) userData.selectedSymptom,
  if (userData.anotherSymptom.isNotEmpty) userData.anotherSymptom,
  ...userData.petSymptoms.where((symptom) => symptom.isNotEmpty),
}.join(" + "), 20);  // ✅ Apply truncation at the end, not per symptom




    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 233, 233, 232),
      body: Stack(
        children: [
          _buildBackground(screenHeight, screenWidth), // ✅ Background Added
          ..._buildFloatingBalls(), // ✅ Floating Balls Added

          // Left Side Container - Displays User Input
          Positioned(
            top: screenHeight * 0.36,
            left: screenWidth * 0.06,
            child: InkWell(
              onTap: () => _showUserInputDialog(context, userData, allSymptoms),
              child: Container(
                width: 0.43.sw,
                height: 0.25.sh,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(29, 29, 44, 0.89),
                  borderRadius: BorderRadius.all(Radius.circular(10.r)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10.r)),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 0.6.sw,
                        maxHeight: 0.4.sh,
                      ),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 0.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildInputCardclone("🎂", "Age", userData.age.toString()),
                            _buildInputCardclone("📏", "Height", userData.size.toString()),
                            _buildInputCardclone("🐶", "Breed", userData.breed),
                            _buildInputCardclone("🤕", "Symptoms", allSymptoms),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Right Side Container - Displays Diagnosis Results
          // ✅ Right Side Container - Displays Top 3 Diagnoses
Positioned(
  top: screenHeight * 0.36,
  left: screenWidth * 0.515,
  child: InkWell(
    onTap: () => _showDiagnosisDialog(context, userData.diagnosisResults),
    child: Container(
      width: 0.43.sw,
      height: 0.42.sh,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(29, 29, 44, 0.897),
        borderRadius: BorderRadius.all(Radius.circular(10.r)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(10.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: userData.diagnosisResults.isNotEmpty
              ? userData.diagnosisResults
                  .take(3) // ✅ Only get top 3 illnesses
                  .map((diagnosis) {
                  double confidence = ((diagnosis["final_score"] ?? 0) * 100).toDouble();
                  return Column(
                    children: [
                      CircularPercentIndicator(
                        radius: 50.r,
                        lineWidth: 10.w,
                        percent: confidence / 100,
                        animation: true,
                        center: Text(
                          "${confidence.toStringAsFixed(0)}%",
                          style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
                        ),
                        progressColor: _getDiagnosisColor(confidence),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 5.h),
                        child: Text(
                          diagnosis["illness"] ?? "Unknown",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp, color: Colors.white),
                        ),
                      ),
                      const Divider(color: Colors.white24), // ✅ Adds separation
                    ],
                  );
                }).toList()
              : [
                  Center(
                    child: Padding(padding: EdgeInsets.only(left: 20.w),
                    child: Text("No diagnosis results", style: TextStyle(color: Colors.white, fontSize: 16.sp)),
                  ))
                ],
        ),
      ),
    ),
  ),
),

        ],
      ),
    );
  }

  /// **Background Elements (Yellow Gradient & Floating Images)**
  Widget _buildBackground(double screenHeight, double screenWidth) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            width: screenWidth,
            height: screenHeight * 1.5,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(232, 242, 245, 1.0),
                  Color.fromRGBO(95, 93, 93, 1),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(100.0),
                bottomRight: Radius.circular(100.0),
              ),
            ),
          ),
        ),
        Positioned(
          top: -screenHeight * 0.15,
          left: -screenWidth * 0.2,
          child: Image.asset('assets/bonesbg.png', height: 700, width: 750, fit: BoxFit.contain),
        ),
        Positioned(
          top: screenHeight * 0.08,
          left: screenWidth * 0.41,
          child: AnimatedOpacity(
            duration: const Duration(seconds: 1),
            opacity: _isAnimated ? 1.0 : 0.0,
            child: Image.asset('assets/paw.png', width: screenWidth * 0.2, height: screenWidth * 0.2),
          ),
        ),
      ],
    );
  }

   // Show User Input Dialog
  void _showUserInputDialog(BuildContext context, UserData userData, String allSymptoms) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 243, 242, 240),
          contentPadding: EdgeInsets.zero,
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('User Input Details', textAlign: TextAlign.center, style: TextStyle(color: Colors.black)),
          content: SizedBox(
            width: 1.sw,
            height: 0.52.sh,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildInputCard("🎂", "Age", userData.age.toString()),
                  _buildInputCard("📏", "Height", userData.size.toString()),
                  _buildInputCard("🐶", "Breed", userData.breed),
                  _buildInputCard("🤕", "Symptoms", allSymptoms),
                ],
              ),
            ),
          ),
          

        );
        
      },
    );
  }

  Widget _buildInputCard(String emoji, String label, String value) {
  return Card(
    elevation: 3,
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Aligns text and trailing
        children: [
          // Leading Icon & Text
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
    const SizedBox(width: 15),
              Column(          
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ],
              ),
            ],
          ),
          
          // **Trailing Icon (Example: Edit Icon)**
          const Icon(Icons.check, color:  Color.fromARGB(255, 21, 180, 0)),
        ],
      ),
    ),
  );
}


Widget _buildInputCardclone(String emoji, String label, String value) {
  return Card(
    elevation: 3,
    margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: Padding(
      padding: const EdgeInsets.all(5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  SizedBox(
                    width: 115, // ✅ Ensure width is controlled for truncation
                    child: Text(
                      truncateText(value, 20),  // ✅ Truncate text inside widget
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                      overflow: TextOverflow.ellipsis,  // ✅ Ensure UI does not overflow
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Icon(Icons.check, color: Color.fromARGB(255, 21, 180, 0)),
        ],
      ),
    ),
  );
}

  // Show Diagnosis Results Dialog
  void _showDiagnosisDialog(BuildContext context, List<dynamic> diagnoses) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final topDiagnosis = diagnoses.isNotEmpty ? diagnoses.first : null;
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 243, 240, 240),
          contentPadding: EdgeInsets.zero,
          insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 170),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Top Diagnosis', textAlign: TextAlign.center, style: TextStyle(color: Colors.black)),
          content: topDiagnosis != null
              ? CircularPercentIndicator(
                  radius: 100.0,
                  lineWidth: 20.0,
                  animation: true,
                  percent: (topDiagnosis["final_score"] ?? 0) * 100 / 100,
                  center: Text("${((topDiagnosis["final_score"] ?? 0) * 100).toStringAsFixed(0)}%", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0)),
                  footer: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(topDiagnosis["illness"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0)),
                  ),
                  progressColor: _getDiagnosisColor((topDiagnosis["final_score"] ?? 0) * 100),
                )
              : const Text("No diagnosis available"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close", style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }


  /// **Floating Balls (Decorative Elements)**
  List<Widget> _buildFloatingBalls() {
    return List.generate(9, (index) {
      return Positioned(
        top: (0.3 + index * 0.1).sh,
        left: (index.isEven ? -0.15 : 0.1).sw,
        child: Image.asset('assets/floatball.png', height: 200.h, width: 200.w, fit: BoxFit.fill),
      );
    });
  }

  /// **Diagnosis Color Based on Confidence**
  Color _getDiagnosisColor(double confidence) {
    if (confidence > 70) return Colors.red;
    if (confidence > 40) return Colors.orange;
    return Colors.green;
  }
}
