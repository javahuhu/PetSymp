import 'package:flutter/material.dart';
import 'package:petsymp/Assesment/newsummary.dart';
import '../userdata.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  ReportScreenState createState() => ReportScreenState();
}

class ReportScreenState extends State<ReportScreen> {
  bool _isAnimated = false;
  bool _isLoading = false;
  String ownerName = 'Loading...';

  final List<bool> _buttonVisible = [false, false, false, false, false, false];

  @override
  void initState() {
    super.initState();
    fetchOwnerName(); // ← Fetch owner from Firestore

    // Your animation sequence
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _isAnimated = true;
      });
      for (int i = 0; i < _buttonVisible.length; i++) {
        Future.delayed(Duration(milliseconds: 300 * i), () {
          if (mounted) {
            setState(() {
              _buttonVisible[i] = true;
            });
          }
        });
      }
    });
  }

  Future<void> fetchOwnerName() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String userId = user.uid;

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          final data = userDoc.data() as Map<String, dynamic>;

          setState(() {
            ownerName = data['Username'] ?? 'Pet Owner';
          });
        } else {
          setState(() {
            ownerName = 'User Not Found';
          });
        }
      } else {
        setState(() {
          ownerName = 'Not Logged In';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching owner name: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final PetName = Provider.of<UserData>(context).userName;

    return PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: const Color(0xFFE8F2F5),
          body: Stack(
            children: [
              Stack(
                children: [
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (ownerName != 'Loading...' && PetName.isNotEmpty)
                              ? "Thank you, $ownerName. I have put together a report of $PetName 's possible complications."
                              : "Loading report...",
                          style: const TextStyle(
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

                  buildAnimatedButton(screenHeight * 1.03, screenWidth, 0.87,
                      "Continue", const NewSummaryScreen(), 1),
                ],
              ),
            ],
          ),
        ));
  }

  // Method to create an animated button
  Widget buildAnimatedButton(double screenHeight, double screenWidth,
      double topPosition, String label, Widget destination, int index) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      top: _buttonVisible[index] ? screenHeight * topPosition : screenHeight,
      right: screenWidth * 0.02,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : () async {
                setState(() {
                  _isLoading = true;
                });

                try {
                  await Future.delayed(const Duration(seconds: 3));

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => destination),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                    'Something went wrong: $e',
                  )));
                } finally {
                  if (mounted) setState(() => _isLoading = false);
                }
              },
        style: ButtonStyle(
          // Dynamic background color based on button state
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) {
              if (states.contains(WidgetState.pressed)) {
                return const Color.fromARGB(
                    255, 0, 0, 0); // Background color when pressed
              }
              return Colors.transparent; // Default background color
            },
          ),
          // Dynamic text color based on button state
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) {
              if (states.contains(WidgetState.pressed)) {
                return const Color.fromARGB(
                    255, 255, 255, 255); // Text color when pressed
              }
              return const Color.fromRGBO(
                  29, 29, 44, 1.0); // Default text color
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
        child: _isLoading
            ? SizedBox(
                height: 20.w,
                width: 20.w,
                child: const CircularProgressIndicator(
                  color: Color.fromARGB(255, 64, 35, 93),
                  strokeWidth: 5,
                ),
              )
            : Text(
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
