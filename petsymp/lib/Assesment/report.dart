import 'package:flutter/material.dart';
import 'package:petsymp/Assesment/newsummary.dart';
import '../userdata.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  ReportScreenState createState() => ReportScreenState();
}

class ReportScreenState extends State<ReportScreen>
    with SingleTickerProviderStateMixin {
  static const int _bubbleCount = 8; // number of static bubbles
  late List<Bubble> _bubbles;

  bool _isAnimated = false;
  bool _isLoading = false;
  String ownerName = 'Loading...';
  final List<bool> _buttonVisible = [false, false, false, false, false, false];

  @override
  void initState() {
    super.initState();
    // Generate static bubbles
    _bubbles = List.generate(_bubbleCount, (_) => Bubble());

    fetchOwnerName();

    // Animation for title and buttons
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() => _isAnimated = true);
      for (int i = 0; i < _buttonVisible.length; i++) {
        Future.delayed(Duration(milliseconds: 300 * i), () {
          if (mounted) setState(() => _buttonVisible[i] = true);
        });
      }
    });
  }

  Future<void> fetchOwnerName() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get();
        if (userDoc.exists && userDoc.data() != null) {
          final data = userDoc.data() as Map<String, dynamic>;
          setState(() => ownerName = data['Username'] ?? 'Pet Owner');
        } else {
          setState(() => ownerName = 'User Not Found');
        }
      } else {
        setState(() => ownerName = 'Not Logged In');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching owner name: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final petName = Provider.of<UserData>(context).userName;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFE8F2F5),
        body: Stack(
          children: [
            // Static bubbles background
            ..._bubbles.map((bubble) {
              final size = bubble.size * screenWidth * 0.3; // larger bubbles
              return Positioned(
                left: bubble.position.dx * screenWidth,
                top: bubble.position.dy * screenHeight,
                child: Opacity(
                  opacity: 0.5 * bubble.opacity,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [
                          Color.fromRGBO(82, 170, 164, 0.8),
                          Color.fromRGBO(82, 170, 164, 0.2),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),

            // Main content stack
            Stack(
              children: [
                // Paw icon animation
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
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child:
                            Image.asset('assets/paw.png', fit: BoxFit.contain),
                      ),
                      SizedBox(width: screenWidth * 0.05),
                    ],
                  ),
                ),

                // Title section
                Positioned(
                  top: screenHeight * 0.22,
                  left: screenWidth * 0.12,
                  right: screenWidth * 0.02,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (ownerName != 'Loading...' && petName.isNotEmpty)
                            ? "Thank you, $ownerName. I have put together a report of $petName's possible complications."
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

                // Animated Continue button
                buildAnimatedButton(
                  screenHeight * 1.03,
                  screenWidth,
                  0.88,
                  "Continue",
                  const NewSummaryScreen(),
                  1,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Animated button builder
  Widget buildAnimatedButton(
    double screenHeight,
    double screenWidth,
    double topFactor,
    String label,
    Widget destination,
    int index,
  ) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      top: _buttonVisible[index] ? screenHeight * topFactor : screenHeight,
      right: screenWidth * 0.02,
      child: GestureDetector(
        onTap: _isLoading
            ? null
            : () async {
                setState(() => _isLoading = true);
                try {
                  await Future.delayed(const Duration(seconds: 3));
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => destination),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Something went wrong: $e')),
                  );
                } finally {
                  if (mounted) setState(() => _isLoading = false);
                }
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 60.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromRGBO(82, 170, 164, 1),
                Color.fromRGBO(82, 170, 164, 1)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                  padding: EdgeInsets.only(left: 5.w),
                  child: Text(
                    "CONTINUE",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  )),
              SizedBox(width: 8.w),
              Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 22.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Simple Bubble class for static placement
class Bubble {
  final Offset position;
  final double size;
  final double opacity;

  Bubble()
      : position =
            Offset(math.Random().nextDouble(), math.Random().nextDouble()),
        size =
            0.5 + math.Random().nextDouble() * 0.5, // relative size (50–100%)
        opacity = 0.3 + math.Random().nextDouble() * 0.5; // 30–80% opacity
}
