import 'package:flutter/material.dart';
import 'homepage.dart';
class GetstartedScreen extends StatefulWidget {
  const GetstartedScreen({super.key});

  @override
  GetstartedScreenState createState() => GetstartedScreenState();
}

class GetstartedScreenState extends State<GetstartedScreen> {
  // State variables to control visibility of images
  List<bool> _visibleImages = [false, false, false, false, false];

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

  // Method to reset visibility and restart the animation
  void _resetAndAnimateImages() {
    setState(() {
      _visibleImages = [false, false, false, false, false];
    });
    Future.delayed(const Duration(milliseconds: 50), _animateImages);
  }

  // Method to animate visibility of images sequentially
  void _animateImages() async {
    for (int i = 0; i < _visibleImages.length; i++) {
      await Future.delayed(const Duration(milliseconds: 1000)); // Delay for each image
      setState(() {
        _visibleImages[i] = true; // Make the image visible
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( backgroundColor: const Color(0xFFCFCFCC),
      body: Stack(
        children: [
          // Custom Background with Chubby Curves
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: CurvedBackgroundPainter(),
          ),

          // Logo and Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Image.asset(
                  'assets/logo.png',
                  width: 300,
                  height: 300,
                ),
              ),
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 400, // Provide enough space for the images
                    height: 400, // Adjust based on layout
                    child: Stack(
                      clipBehavior: Clip.none, // Prevent clipping
                      alignment: Alignment.center,
                      children: [
                        // Outer Large Circle
                        Container(
                          width: 350,
                          height: 350,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/dogfirstaidkit.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        // Inner Small Circles (Overlapping)
                        Positioned(
                          top: -5,
                          left: -5,
                          child: _buildAnimatedImage(
                            visible: _visibleImages[0],
                            size: 130,
                            assetPath: 'assets/getstartedpet.jpg',
                          ),
                        ),
                        Positioned(
                          top: -95,
                          left: 170,
                          child: _buildAnimatedImage(
                            visible: _visibleImages[1],
                            size: 105,
                            assetPath: 'assets/veetveet.jpg',
                          ),
                        ),
                        Positioned(
                          top: -110,
                          left: 75,
                          child: _buildAnimatedImage(
                            visible: _visibleImages[2],
                            size: 52,
                            assetPath: 'assets/catanddog.jpg',
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: -10,
                          child: _buildAnimatedImage(
                            visible: _visibleImages[3],
                            size: 78,
                            assetPath: 'assets/takingcareofpets.jpg',
                          ),
                        ),
                        Positioned(
                          bottom: -40,
                          right: -10,
                          child: _buildAnimatedImage(
                            visible: _visibleImages[4],
                            size: 52,
                            assetPath: 'assets/pethiscatttt.jpg',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Button at the Bottom
              Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: Center(
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
                      backgroundColor: const Color(0xFF3D2F28),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      fixedSize: const Size(200, 65), // Button width and height
                    ),
                    child: const Text(
                      "Get Started",
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

  // Helper method to build animated images
  Widget _buildAnimatedImage({
    required bool visible,
    required double size,
    required String assetPath,
  }) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500), // Animation duration
      opacity: visible ? 1.0 : 0.0, // Fade in when visible
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: Image.asset(
            assetPath,
            fit: BoxFit.cover,
          ),
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
      ..color = const Color(0xFF3D2F28) // Brownish color
      ..style = PaintingStyle.fill;

    // Bottom-Left Chubby Curve
    Path path1 = Path();
    path1.moveTo(0, size.height);
    path1.quadraticBezierTo(
      size.width * 0.4, size.height * 0.9, // Control point for a rounded effect
      size.width * 0.2, size.height * 0.7, // End point
    );
    path1.quadraticBezierTo(
      size.width * 0.1, size.height * 0.75, // Secondary control point for smoothing
      0, size.height * 0.6, // Bring the curve back to the left
    );
    path1.close();

    // Upper-Right Chubby Curve
    Path path2 = Path();
    path2.moveTo(size.width, 0);
    path2.quadraticBezierTo(
      size.width * 0.7, size.height * 0.1, // Control point for the rounded effect
      size.width * 0.8, size.height * 0.2, // End point
    );
    path2.quadraticBezierTo(
      size.width * 0.9, size.height * 0.15, // Secondary control point
      size.width, size.height * 0.3, // Smoothly bring it back to the right
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
