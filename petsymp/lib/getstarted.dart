import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'homepage.dart';

class GetstartedScreen extends StatefulWidget {
  const GetstartedScreen({super.key});

  @override
  GetstartedScreenState createState() => GetstartedScreenState();
}

class GetstartedScreenState extends State<GetstartedScreen> {
  // State variables to control visibility of images and button
  List<bool> _visibleImages = [false, false, false, false, false, false]; // Last index for button

  @override
  void initState() {
    super.initState();
    _animateImages(); // Trigger animations when the screen loads
  }

  @override
  void reassemble() {
    super.reassemble();
    // Called during hot reload, explicitly restart the animation
    _resetAndAnimateImages();
  }

  // Reset visibility and restart animation
  void _resetAndAnimateImages() {
    setState(() {
      _visibleImages = [false, false, false, false, false, false];
    });
    Future.delayed(const Duration(milliseconds: 50), _animateImages);
  }

  // Animate visibility of images sequentially
  void _animateImages() async {
    for (int i = 0; i < _visibleImages.length; i++) {
      await Future.delayed(const Duration(milliseconds: 1000));
      setState(() {
        _visibleImages[i] = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F2F5),
      body: Stack(
        children: [
          // Custom Background with Chubby Curves
          CustomPaint(
            size: Size(1.sw, 1.sh), // Screen width and height
            painter: CurvedBackgroundPainter(),
          ),

          // Logo and Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 15.w, top: 15.h), // Responsive padding
                child: Image.asset(
                  'assets/logo.png',
                  width: 250.w,
                  height: 250.h,
                ),
              ),
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 350.w, // Responsive width
                    height: 350.h, // Responsive height
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        // Outer Large Circle
                        Container(
                          width: 315.w,
                          height: 315.h,
                          decoration: const BoxDecoration(shape: BoxShape.circle),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/dogfirstaidkit.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        // Inner Small Circles (Overlapping)
                        Positioned(
                          top: -5.h,
                          left: -5.w,
                          child: _buildAnimatedImage(
                            visible: _visibleImages[0],
                            size: 110.r,
                            assetPath: 'assets/getstartedpet.jpg',
                          ),
                        ),
                        Positioned(
                          top: -90.h,
                          left: 170.w,
                          child: _buildAnimatedImage(
                            visible: _visibleImages[1],
                            size: 95.r,
                            assetPath: 'assets/veetveet.jpg',
                          ),
                        ),
                        Positioned(
                          top: -110.h,
                          left: 75.w,
                          child: _buildAnimatedImage(
                            visible: _visibleImages[2],
                            size: 50.r,
                            assetPath: 'assets/catanddog.jpg',
                          ),
                        ),
                        Positioned(
                          bottom: 0.h,
                          left: -10.w,
                          child: _buildAnimatedImage(
                            visible: _visibleImages[3],
                            size: 70.r,
                            assetPath: 'assets/takingcareofpets.jpg',
                          ),
                        ),
                        Positioned(
                          bottom: -35.h,
                          right: -10.w,
                          child: _buildAnimatedImage(
                            visible: _visibleImages[4],
                            size: 50.r,
                            assetPath: 'assets/pethiscatttt.jpg',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Button at the Bottom with Animation
              Padding(
                padding: EdgeInsets.only(bottom: 15.h),
                child: Center(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: _visibleImages[5] ? 1.0 : 0.0, // Button visibility
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomePageScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D1D2C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.r),
                        ),
                        fixedSize: Size(200.w, 60.h), // Responsive button size
                      ),
                      child: Text(
                        "Get Started",
                        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
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

  // Helper method to build animated images
  Widget _buildAnimatedImage({
    required bool visible,
    required double size,
    required String assetPath,
  }) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: visible ? 1.0 : 0.0, // Fade in when visible
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: ClipOval(
          child: Image.asset(assetPath, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

// Painter for the curved background with chubby curves
class CurvedBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = const Color(0xFF1D1D2C)
      ..style = PaintingStyle.fill;

    // Bottom-Left Chubby Curve
    Path path1 = Path();
    path1.moveTo(0, size.height);
    path1.quadraticBezierTo(
      size.width * 0.4, size.height * 0.9,
      size.width * 0.2, size.height * 0.7,
    );
    path1.quadraticBezierTo(
      size.width * 0.1, size.height * 0.75,
      0, size.height * 0.6,
    );
    path1.close();

    // Upper-Right Chubby Curve
    Path path2 = Path();
    path2.moveTo(size.width, 0);
    path2.quadraticBezierTo(
      size.width * 0.7, size.height * 0.1,
      size.width * 0.8, size.height * 0.2,
    );
    path2.quadraticBezierTo(
      size.width * 0.9, size.height * 0.15,
      size.width, size.height * 0.3,
    );
    path2.close();

    // Draw the paths
    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
