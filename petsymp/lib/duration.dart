import 'package:flutter/material.dart';
import 'package:petsymp/anothersymptoms.dart';
import 'package:provider/provider.dart';
import 'userdata.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DurationScreen extends StatefulWidget {
  const DurationScreen({super.key});

  @override
  DurationScreenState createState() => DurationScreenState();
}

class DurationScreenState extends State<DurationScreen> {
  bool _isAnimated = false;
  int _currentSymptomIndex = 0; // ✅ Track the symptom being processed
  final List<bool> _buttonVisible = [false, false, false, false, false, false];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _isAnimated = true;
      });

      for (int i = 0; i < _buttonVisible.length; i++) {
  final int index = i; // ✅ Create a local copy of `i`
  Future.delayed(Duration(milliseconds: 300 * index), () {
    if (!mounted) return; // ✅ Prevents calling setState after dispose()
    setState(() {
      _buttonVisible[index] = true;
    });
  });
}


    });
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context, listen: false);
    final List<String> symptoms = userData.petSymptoms; 

    // ✅ Check if all symptoms have duration
    if (_currentSymptomIndex >= symptoms.length) {
      Future.microtask(() {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AnothersympScreen()),
        );
      });
      return Container(); // Avoids showing unnecessary UI
    }

    final currentSymptom = symptoms[_currentSymptomIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFE8F2F5),
      body: Stack(
        children: [
          // ✅ Back Button with Animation
           Positioned(
            top: 20.h,
            left: 5.w,
            child: ElevatedButton(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.transparent,
                shape: const CircleBorder(),
                padding: EdgeInsets.all(8.w),
              ),
              child: Icon(Icons.arrow_back, size: 40.sp, color: const Color.fromRGBO(61, 47, 40, 1)),
            ),
          ),

          // ✅ Animated Header & Paw Image
          AnimatedPositioned(
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            top: _isAnimated ? MediaQuery.of(context).size.height * 0.12 : -100,
            left: 20.w,
            child: Row(
              children: [
                Image.asset('assets/paw.png', width: 60.w, height: 60.h),
            
              ],
            ),
          ),

          // ✅ Question for Current Symptom
          Positioned(
            top:  162.h,
            left: 27.w,
            right:  20.w,
            child: AnimatedOpacity(
              duration: const Duration(seconds: 1),
              opacity: _isAnimated ? 1.0 : 0.0,
              child: Text(
                "How long has ${currentSymptom.toLowerCase()} been troubling your pet?",
                style:  TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: const Color.fromRGBO(29, 29, 44, 1.0)),
              ),
            ),
          ),

          // ✅ Animated Duration Buttons
           buildAnimatedButton(context, "Three days", currentSymptom, 0, symptoms),
        buildAnimatedButton(context, "Five days", currentSymptom, 1, symptoms),
        buildAnimatedButton(context, "One week", currentSymptom, 2, symptoms),
        buildAnimatedButton(context, "Two weeks", currentSymptom, 3, symptoms),
        buildAnimatedButton(context, "Three weeks", currentSymptom, 4, symptoms),
        buildAnimatedButton(context, "One month", currentSymptom, 5, symptoms),
        ],
      ),
    );
  }

  // ✅ Create an animated button for duration selection
  Widget buildAnimatedButton(BuildContext context, String duration, String symptom, int index, List<String> symptoms) {
  return AnimatedPositioned(
    duration: const Duration(milliseconds: 800),
    curve: Curves.easeInOut,
    top: _buttonVisible[index] ? MediaQuery.of(context).size.height * (0.35 + (index * 0.08)) : MediaQuery.of(context).size.height,
    left: MediaQuery.of(context).size.width * 0.29 - 65,
    child: ElevatedButton(
      onPressed: () {
        final userData = Provider.of<UserData>(context, listen: false);
        userData.setSymptomDuration(symptom, duration);

        // ✅ Move to the next symptom or navigate
        setState(() {
          if (_currentSymptomIndex < symptoms.length - 1) {
            _currentSymptomIndex++;
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AnothersympScreen()),
            );
          }
        });
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(WidgetState.pressed)) {
              return const Color.fromARGB(255, 0, 0, 0);
            }
            return Colors.transparent;
          },
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(WidgetState.pressed)) {
              return const Color.fromARGB(255, 255, 255, 255);
            }
            return const Color.fromRGBO(29, 29, 44, 1.0);
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
          Size(300.w, 55.w),
        ),
      ),
      child: Text(duration, style: TextStyle(fontSize: 22.0.sp, fontWeight: FontWeight.bold)),
    ),
  );
}

}
