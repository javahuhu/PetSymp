import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:petsymp/PetProfile/viewHistory.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

enum ShapeType {
  circle,
  square,
  triangle,
  star,
  heart,
  rectangle,
  diamond,

}


class ShapeWidget extends StatelessWidget {
  final ShapeType type;
  final Color color;
  final double size;
  
  const ShapeWidget({
    Key? key,
    required this.type,
    required this.color,
    required this.size,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: ShapePainter(
        type: type,
        color: color,
      ),
    );
  }
}


class ShapePainter extends CustomPainter {
  final ShapeType type;
  final Color color;
  
  ShapePainter({
    required this.type,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    
    switch (type) {
      case ShapeType.circle:
        canvas.drawCircle(
          Offset(size.width / 2, size.height / 2),
          size.width / 2,
          paint,
        );
        break;
      
      case ShapeType.square:
        canvas.drawRect(
          Rect.fromLTWH(0, 0, size.width, size.height),
          paint,
        );
        break;
      
      case ShapeType.triangle:
        final Path path = Path();
        path.moveTo(size.width / 2, 0);
        path.lineTo(0, size.height);
        path.lineTo(size.width, size.height);
        path.close();
        canvas.drawPath(path, paint);
        break;
      
      case ShapeType.star:
        final Path path = _drawStar(size);
        canvas.drawPath(path, paint);
        break;
      
      case ShapeType.heart:
        final Path path = _drawHeart(size);
        canvas.drawPath(path, paint);
        break;

      case ShapeType.diamond:
        final Path path = _drawDiamond(size);
        canvas.drawPath(path, paint);
        break;

      case ShapeType.rectangle:
        final Path path = _drawRegularPolygon(size, 4);
        canvas.drawPath(path, paint);
        break;
    

    }
  }

  Path _drawStar(Size size) {
    final Path path = Path();
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = size.width / 2;
    final double innerRadius = radius * 0.4;
    
    const int numPoints = 5;
    final double angle = (2 * pi) / (2 * numPoints);
    
    path.moveTo(centerX + radius * cos(0), centerY + radius * sin(0));
    
    for (int i = 1; i < 2 * numPoints; i++) {
      final double r = i.isOdd ? innerRadius : radius;
      final double currAngle = i * angle;
      path.lineTo(
        centerX + r * cos(currAngle),
        centerY + r * sin(currAngle),
      );
    }
    
    path.close();
    return path;
  }

  
Path _drawDiamond(Size size) {
  final Path path = Path();
  final double width = size.width;
  final double height = size.height;
  
  // Draw a diamond (rotated square)
  path.moveTo(width / 2, 0); // Top point
  path.lineTo(width, height / 2); // Right point
  path.lineTo(width / 2, height); // Bottom point
  path.lineTo(0, height / 2); // Left point
  path.close();
  
  return path;
}

Path _drawRegularPolygon(Size size, int sides) {
  final Path path = Path();
  final double centerX = size.width / 2;
  final double centerY = size.height / 2;
  final double radius = size.width / 2;
  
  // Calculate the angle between each point
  final double angle = (2 * pi) / sides;
  
  // Start at the top point (0 degrees)
  path.moveTo(
    centerX + radius * cos(-pi / 2),
    centerY + radius * sin(-pi / 2),
  );
  
  // Draw lines to each point
  for (int i = 1; i < sides; i++) {
    final double currAngle = (-pi / 2) + (i * angle);
    path.lineTo(
      centerX + radius * cos(currAngle),
      centerY + radius * sin(currAngle),
    );
  }
  
  path.close();
  return path;
}



  Path _drawHeart(Size size) {
    final Path path = Path();
    final double width = size.width;
    final double height = size.height;
    
    path.moveTo(0.5 * width, height * 0.25);
    path.cubicTo(
      0.2 * width, 0.1 * height,
      0, 0.4 * height,
      0.5 * width, height,
    );
    path.cubicTo(
      width, 0.4 * height,
      0.8 * width, 0.1 * height,
      0.5 * width, height * 0.25,
    );


    
    
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}


class AnimatedShapesBackground extends StatefulWidget {
  final Color baseColor;
  final ShapeType shapeType;
  
  const AnimatedShapesBackground({
    Key? key,
    required this.baseColor,
    required this.shapeType,
  }) : super(key: key);

  @override
  _AnimatedShapesBackgroundState createState() => _AnimatedShapesBackgroundState();
}

class _AnimatedShapesBackgroundState extends State<AnimatedShapesBackground> with TickerProviderStateMixin {
  late List<AnimatedShape> _shapes;
  final Random _random = Random();
  
  @override
  void initState() {
    super.initState();
    _initializeShapes();
  }

  void _initializeShapes() {
    // Create 4-6 random animated shapes
    final int numShapes = 15 + _random.nextInt(10);
    _shapes = List.generate(numShapes, (_) => _generateRandomShape());
  }

  AnimatedShape _generateRandomShape() {
    // Random position
    final double left = _random.nextDouble() * 250;
    final double top = _random.nextDouble() * 150;
    
    // Random size between 15 and 30
    final double size = 15 + _random.nextDouble() * 15;
    
    // Animation duration between 5 and 10 seconds
    final int duration = 5000 + _random.nextInt(5000);
    
    // Random color variation based on the base color
    final HSLColor hslColor = HSLColor.fromColor(widget.baseColor);
    final double hue = (hslColor.hue + _random.nextDouble() * 30 - 15) % 360;
    final double saturation = 0.5 + _random.nextDouble() * 0.3;
    final double lightness = 0.7 + _random.nextDouble() * 0.2;
    final Color color = HSLColor.fromAHSL(0.6, hue, saturation, lightness).toColor();
    
    // Create an AnimationController for this shape
    final AnimationController controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: duration),
    );
    
    // Make the animation loop
    controller.repeat(reverse: true);
    
    return AnimatedShape(
      left: left,
      top: top,
      size: size,
      color: color,
      controller: controller,
      shapeType: widget.shapeType,
    );
  }

  @override
  void dispose() {
    // Dispose all animation controllers
    for (final shape in _shapes) {
      shape.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _shapes.map((shape) {
        return AnimatedBuilder(
          animation: shape.controller,
          builder: (context, child) {
            // Move the shape in a floating pattern
            final double offset = sin(shape.controller.value * pi * 2) * 10;
            
            return Positioned(
              left: shape.left + offset,
              top: shape.top + (cos(shape.controller.value * pi * 2) * 10),
              child: ShapeWidget(
                type: shape.shapeType,
                color: shape.color,
                size: shape.size + (offset * 0.3),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

/// Model class for an animated shape
class AnimatedShape {
  final double left;
  final double top;
  final double size;
  final Color color;
  final AnimationController controller;
  final ShapeType shapeType;
  
  AnimatedShape({
    required this.left,
    required this.top,
    required this.size,
    required this.color,
    required this.controller,
    required this.shapeType,
  });
}

class PetProfileScreen extends StatefulWidget {
  const PetProfileScreen({Key? key}) : super(key: key);

  @override
  _PetProfileScreenState createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends State<PetProfileScreen> {
  late final ScrollController _scrollController;
  final Random _random = Random();
  
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
  }

   @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  
  Color generatePastelColor() {
  // Generate a darker pastel color
  final int red = 65 + _random.nextInt(75);   
  final int green = 65 + _random.nextInt(75); 
  final int blue = 65 + _random.nextInt(75);  

  return Color.fromRGBO(red, green, blue, 1.0);
}


  ShapeType getRandomShapeType() {
    final types = ShapeType.values;
    return types[_random.nextInt(types.length)];
  }
  
  
  Future<List<Map<String, dynamic>>> fetchPetHistory() async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw Exception("User is not signed in.");
    }
    
    
    final historyCol = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('History');
    
    // Get the documents ordered by date
    final snapshot = await historyCol
        .orderBy('date', descending: true)
        .get();
    
    
    return snapshot.docs
        .map((doc) {
          
          final data = doc.data();
          return {
            ...data,
            'id': doc.id, 
          };
        })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: const Color.fromRGBO(29, 29, 44, 1.0),
      body: 
      FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchPetHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: const Color(0xFF52AAA4),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red[300],
                    size: 60.sp,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "Error: ${snapshot.error}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {}); // Retry fetching data.
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF52AAA4),
                      padding: EdgeInsets.symmetric(
                          horizontal: 24.w, vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      "Retry",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pets,
                    color: Colors.grey[400],
                    size: 80.sp,
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    "No pet profiles found",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "Add a pet to get started",
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 32.h),
                 
                ],
              ),
            );
          } else {

            final petHistory = snapshot.data!;
            final DateTime now       = DateTime.now();
            final String todayDate   = DateFormat('d').format(now);
            final String todayWeekday  = DateFormat('E').format(now);  
            final int todayIndex     = now.weekday - 1;
            return 
            
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                 Row(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                SizedBox(width: 50.w),

                
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                    padding: EdgeInsets.only(top: 110.h,),
                    child: Text(
                      "Pets Profile",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                  
                  ],
                ),

              
              Padding(padding: EdgeInsets.only( top: 40.h, left: 5.w),
              child: Container(
                width: 200.w,
                height: 150.h,
                
                child: Lottie.asset(
                  'assets/dogsitanimation.json',
                  fit: BoxFit.contain,  
                  repeat: true,
                  animate: true,
                ),
              )),

              ],
            ),



                Expanded(
                  child: Stack(
                    children: [
                     
                      Positioned(
                        bottom: 0.h,
                        left: 0.w,
                        right: 0.w,
                        child: Container(
                          height: 540.h,
                          decoration: const BoxDecoration(
                            color: Color.fromRGBO(225, 240, 243, 0.884),
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(50)),
                            border: Border(
                              top: BorderSide(
                                color: Color.fromRGBO(82, 170, 164, 1),
                                width: 10,
                              ),
                            ),
                          ),
                          child: Stack(  
                            children: [
                              Padding(padding: EdgeInsets.only(top: 15.h, left: 15.w),
                              child: Container(
                                width: 70.w,
                                height: 70.h,
                                decoration: BoxDecoration(
                                  color: const Color.fromRGBO(82, 170, 164, 1),
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                  color: const Color.fromRGBO(29, 29, 44, 1.0),
                                  width: 1.w,
                                  ),
                                ),

                                child:  Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                  padding: EdgeInsets.only(top: 5.h),
                                  child: Text(
                                    petHistory.length.toString(),
                                    style: TextStyle(
                                      color: const Color.fromARGB(255, 231, 231, 231),
                                      fontSize: 25.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                
                                  Text(
                                    'Pets',
                                    style: TextStyle(
                                      color: const Color.fromARGB(255, 231, 231, 231),
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                                
                              )),




                               Padding(padding: EdgeInsets.only(top: 15.h, left: 100.w),
                               
                              child: Container(
                                width: 70.w,
                                height: 70.h,
                                decoration: BoxDecoration(
                                  color: const Color.fromRGBO(82, 170, 164, 1),
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color: const Color.fromRGBO(29, 29, 44, 1.0),
                                    width: 1.w,
                                  ),
                                ),

                                child:  Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                  padding: EdgeInsets.only(top: 5.h),
                                  child: Text(
                                    todayDate,
                                    style: TextStyle(
                                      color: const Color.fromARGB(255, 231, 231, 231),
                                      fontSize: 25.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                
                                  Text(
                                    todayWeekday,
                                    style: TextStyle(
                                      color: const Color.fromARGB(255, 231, 231, 231),
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                                
                              )),

                              
                              
                              Padding(
                                padding: EdgeInsets.only(top: 95.h),
                                child: ListView.builder(
                                  controller: _scrollController,
                                  primary: false,
                                  physics: const BouncingScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  itemCount: petHistory.length,
                                  itemBuilder: (context, index) {
                                    final petData = petHistory[index];
                                    return _buildPetCard(context, petData);
                                  },
                                ),
                              ),

                              
                              Positioned(
                                top: 110.h,   
                                bottom: 0,   
                                left: MediaQuery.of(context).size.width
                                      - (80.w + 20.w ),
                                child: Container(
                                  width: 2.w,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(255, 63, 62, 62),
                                    borderRadius: BorderRadius.circular(50.r),
                                  ),
                                  
                                ),

                              ),

                            
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),


                ],
              ),
            );
          }
        },
      ),
    );
  }

  
  Widget _buildPetCard(BuildContext context, Map<String, dynamic> petData) {
  final String petType = petData['petType'] ?? 'Unknown';
  final String petName   = petData['petName']   ?? 'Unknown';
  final List details     = petData['petDetails'] is List ? petData['petDetails'] : [];
  final String age       = details.length > 1 ? '${details[1]['value']} yrs' : '–';
  final String breed     = details.length > 3 ? details[3]['value'] : 'Unknown';
  final String imageUrl  = petData['petImage']  ?? 'assets/sampleimage.jpg';
  final Timestamp? ts = petData['date'] as Timestamp?;
                                final String dateStr = ts != null
                                  ? DateFormat('MMM d, yyyy').format(ts.toDate())
                                  : '';
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 23.h),
    child: GestureDetector(
      onTap: () => _showPetDetails(context, petData),
      child: Container(
        child: Row(
          children: [
          SizedBox(
          width: 24.w,          
          child: RotatedBox(
            quarterTurns: 3,     
            child: Text(
              petType,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
            SizedBox(width: 12.w),
            
            Container(
            height: 70.h,
            width: 215.w,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 235, 233, 233),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50.r),
                bottomLeft: Radius.circular(50.r),
                topRight: Radius.circular(10.r),
                bottomRight: Radius.circular(10.r),
              ),
                boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),  
                  offset: const Offset(-5, 10),                   
                  blurRadius: 10,                          
                  spreadRadius: 1,                        
                ),
              ],
            ),
            child: 
              Padding(padding: EdgeInsets.only(left: 12.w),
              child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container( 
                  decoration: BoxDecoration(  
                    borderRadius: BorderRadius.circular(50.r), 
                    border: Border.all(
                    color: const Color.fromRGBO(82, 170, 164, 1),  // border color
                    width: 3.w,           // border thickness
                  ),),
                            child: ClipOval(
                  child: imageUrl.startsWith('http')
                      ? Image.network(
                          imageUrl,
                          width: 48.w,
                          height: 48.w,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          imageUrl,
                          width: 48.w,
                          height: 48.w,
                          fit: BoxFit.cover,
                        ),
                )),

                SizedBox(width: 12.w),

                Padding(padding: EdgeInsets.only(top: 10.w),
              child:
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      petName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color.fromARGB(255, 0, 0, 0),   // white on dark grey
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '$age • $breed',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color.fromARGB(179, 0, 0, 0),
                            ),

                              maxLines: 1,                   
                              overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      )),
                    
                    ],
                  ),
                )),

                
                            

                  SizedBox(width: 0.w),

            // 3) The horizontal connector rail
            Container(
                height: 2.w,         
                width: 14.w,         // thickness of the rail
                color: const Color.fromARGB(255, 63, 62, 62),      // same grey as your timeline
              ),
            

            SizedBox(width: 20.w),

            // 4) Date
            Text(
              dateStr,
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color.fromARGB(255, 63, 62, 62),
              )),
          ],
        ),
      ),
    ),
  );
}


  /// Add this method to create/update pets with a random color and shape type
  Future<void> createNewPet(Map<String, dynamic> petData) async {
    try {
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception("User is not signed in.");
      }

      // Generate a random color for this pet
      final Color cardColor = generatePastelColor();
      
      // Generate a random shape type
      final ShapeType shapeType = getRandomShapeType();
      
      // Add the color and shape type to the pet data
      petData['cardColor'] = cardColor.value;
      petData['shapeType'] = shapeType.index; // Store the enum index
      
      // Add the pet to Firestore
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('History')
          .add(petData);
      
    } catch (e) {
      print("Error creating new pet: $e");
      rethrow;
    }
  }


  Future<void> updateExistingPetsWithAnimationProperties() async {
    try {
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('History')
          .get();
      
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Only update if the pet doesn't already have animation properties
        if (!data.containsKey('cardColor') || !data.containsKey('shapeType')) {
          await doc.reference.update({
            'cardColor': generatePastelColor().value,
            'shapeType': getRandomShapeType().index,
          });
        }
      }
    } catch (e) {
      print("Error updating pets with animation properties: $e");
    }
  }

  void _showPetDetails(BuildContext context, Map<String, dynamic> petData) {
    final List<dynamic> assessments = petData['assessments'] is List ? petData['assessments'] : [];
    final dynamic timestamp = petData['date'];
    final String defaultDateStr = (timestamp != null && timestamp is Timestamp)
        ? "${timestamp.toDate().day} ${_getMonthAbbr(timestamp.toDate().month)} ${timestamp.toDate().year}"
        : "N/A";
    final List<dynamic> details = petData['petDetails'] is List ? petData['petDetails'] : [];
    final String age = details.length > 1 ? (details[1]['value']?.toString() ?? "Unknown") : "Unknown";
    final String size = details.length > 2 ? (details[2]['value']?.toString() ?? "Unknown") : "Unknown";
    final String breed = details.length > 3 ? (details[3]['value']?.toString() ?? "Unknown") : "Unknown";

    List<Widget> healthRecords = [];
    if (assessments.isNotEmpty) {
      for (var assessment in assessments) {
        // Generate a unique ID for each assessment
        String assessmentId = assessment['assessmentId'] ?? 
                        assessment['date']?.toString() ?? 
                        DateTime.now().millisecondsSinceEpoch.toString();
                        
        // Use the symptom input stored in this assessment
        final String inputSymptoms = assessment['allSymptoms'] ?? "";
        
        // Get the diagnosis results from the assessment
        final List<dynamic> diag = assessment['diagnosisResults'] ?? [];
        String finalIllness = "No Result";
        Timestamp? assessTimestamp;
        
        if (diag.isNotEmpty) {
          List<dynamic> sortedDiag = List.from(diag);
          sortedDiag.sort((a, b) => (b['confidence_ab'] as num)
              .compareTo(a['confidence_ab'] as num));
          finalIllness = sortedDiag.first['illness'] ?? "No Result";
          assessTimestamp = sortedDiag.first['date'] is Timestamp
              ? sortedDiag.first['date'] as Timestamp
              : null;
        }
        
        final String assessDate = assessTimestamp != null
            ? "${assessTimestamp.toDate().day} ${_getMonthAbbr(assessTimestamp.toDate().month)} ${assessTimestamp.toDate().year}"
            : defaultDateStr;

        // Create a deep copy of the petDetails list
        List<dynamic> updatedPetDetails = (petData['petDetails'] as List<dynamic>?)
            ?.map((e) => Map<String, dynamic>.from(e))
            .toList() ?? [];
            
        // Update or add the Symptoms detail for this assessment
        if (updatedPetDetails.length >= 5) {
          updatedPetDetails[4]['value'] = inputSymptoms;
        } else {
          updatedPetDetails.add({"icon": "☣️", "label": "Symptoms", "value": inputSymptoms});
        }

        // Merge the pet's basic data with the assessment-specific fields
        Map<String, dynamic> mergedData = {
          'id': petData['id'], // Include document ID for editing
          'petName': petData['petName'] ?? "Unknown",
          'petDetails': updatedPetDetails,
          'petImage': petData['petImage'] ?? "assets/sampleimage.jpg",
          'petType': petData['petType'] ?? "",
          // Overwrite/assign assessment-specific fields
          'date': assessment['date'] ?? defaultDateStr,
          'diagnosisResults': assessment['diagnosisResults'] ?? [],
          'allSymptoms': inputSymptoms,
          'symptomDetails': assessment['symptomDetails'] ?? {},
        };

        healthRecords.add(
          _buildHealthRecordItem(
            title: "$inputSymptoms\n→ $finalIllness",
            date: assessDate,
            status: "Completed",
            isCompleted: true,
            recordId: assessmentId, // Pass the assessment ID for deletion
            petDocId: petData['id'],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewhistoryScreen(historyData: mergedData),
                ),
              );
            },
          ),
        );
      }
    } else {
      healthRecords.add(
        _buildHealthRecordItem(
          title: "No assessments available",
          date: defaultDateStr,
          status: "N/A",
          isCompleted: false,
          onTap: () {},
        ),
      );
    }

    // Create a key to access the modal sheet's state
    final GlobalKey<ImageDraggableBottomSheetState> resizableSheetKey = GlobalKey<ImageDraggableBottomSheetState>();

    // Store the current context's size
    final Size screenSize = MediaQuery.of(context).size;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color.fromARGB(0, 0, 0, 0),
      enableDrag: false, // Disable default dragging to use our custom implementation
      isDismissible: true,
      builder: (context) {
        return ImageDraggableBottomSheet(
          key: resizableSheetKey,
          initialHeight: screenSize.height * 0.85, // Start at 85% of screen height
          minHeight: screenSize.height * 0.4, // Minimum height (40%)
          maxHeight: screenSize.height * 0.95, // Maximum height (95%)
          petData: petData,
          borderRadius: BorderRadius.vertical(top: Radius.circular(50.r)),
          petBreed: breed,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(50.r)),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          onPetDetailsUpdated: () {
            // Refresh the screen when pet details are updated
            setState(() {});
          },
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Details",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16.h),
                // Pet details in cards
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailCard(
                        icon: Icons.cake,
                        iconColor: Colors.amber,
                        label: "Age",
                        value: age,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      flex: 1,
                      child: _buildDetailCard(
                        icon: Icons.pets,
                        iconColor: Colors.brown,
                        label: "Breed",
                        value: breed,
                      ),

                      ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _buildDetailCard(
                        icon: Icons.straighten,
                        iconColor: Colors.blue,
                        label: "Size",
                        value: size,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                // Recent Health Records section.
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Recent Health Records",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "Swipe",
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          "See All",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                // Display all health record items.
                Column(
                  children: healthRecords,
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        );
      },
      // Set barrier color and other modal properties
      barrierColor: Colors.black.withOpacity(0.5),
    );
  }

  /// Helper method to get month abbreviation.
  String _getMonthAbbr(int month) {
    const List<String> months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
  
  /// Builds a detail card for a pet detail.
  Widget _buildDetailCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 0.w),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 24.sp,
          ),
          SizedBox(height: 8.h),
          
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 4.h),
          
          Text(
          value,
          textAlign: TextAlign.center,
          softWrap: false, 
          overflow: TextOverflow.ellipsis,  
          maxLines: 1,  
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        ],
      ),
    );
  }
  
  /// Builds a health record item with swipe-to-delete functionality.
  Widget _buildHealthRecordItem({
    required String title,
    required String date,
    required String status,
    required bool isCompleted,
    String? recordId,
    String? petDocId,
    VoidCallback? onTap,
  }) {
    // If no record ID is provided, don't make it dismissible
    if (recordId == null || petDocId == null) {
      return GestureDetector(
        onTap: onTap,
        child: _buildHealthRecordContent(
          title: title,
          date: date,
          status: status,
          isCompleted: isCompleted,
        ),
      );
    }
    
    // Otherwise, wrap in Dismissible for swipe-to-delete
    return Dismissible(
      key: Key(recordId),
      direction: DismissDirection.endToStart, // Right to left swipe
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete,
              color: Colors.white,
              size: 24.sp,
            ),
            SizedBox(height: 4.h),
            Text(
              "Delete",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        // Show confirmation dialog
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              title: Text(
                "Confirm Deletion",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF3D4A5C),
                ),
              ),
              content: Text(
                "Are you sure you want to delete this health record?",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16.sp,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    "Delete",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        // Execute deletion when confirmed
        _deleteHealthRecord(petDocId, recordId);
      },
      child: GestureDetector(
        onTap: onTap,
        child: _buildHealthRecordContent(
          title: title,
          date: date,
          status: status,
          isCompleted: isCompleted,
        ),
      ),
    );
  }
  
  /// Builds the content of a health record item.
  Widget _buildHealthRecordContent({
    required String title,
    required String date,
    required String status,
    required bool isCompleted,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          // Status icon.
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check_circle : Icons.access_time,
              color: isCompleted ? Colors.green : Colors.orange,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 16.w),
          // Title and date.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
          // Status label.
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: isCompleted ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w500,
                fontSize: 12.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Delete a health record assessment from Firestore.
  Future<void> _deleteHealthRecord(String petDocId, String assessmentId) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(
              color: const Color(0xFF52AAA4),
            ),
          );
        },
      );
      
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception("User is not signed in.");
      }
      
      // Get the document reference
      final docRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('History')
          .doc(petDocId);
      
      // Get the current document data
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        throw Exception("Pet document not found");
      }
      
      final docData = docSnapshot.data() as Map<String, dynamic>;
      
      // Get the assessments array
      List<dynamic> assessments = docData['assessments'] is List 
          ? List.from(docData['assessments']) 
          : [];
      
      // Find the index of the assessment to remove
      final int indexToRemove = assessments.indexWhere(
        (assessment) => assessment['assessmentId'] == assessmentId || 
                        assessment['date']?.toString() == assessmentId
      );
      
      if (indexToRemove != -1) {
        // Remove the assessment from the array
        assessments.removeAt(indexToRemove);
        
        // Update the document with the modified assessments array
        await docRef.update({
          'assessments': assessments,
        });
        
        // Close loading dialog
        Navigator.of(context).pop();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Health record deleted successfully"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
        
        // Refresh the UI
        setState(() {});
      } else {
        // Close loading dialog
        Navigator.of(context).pop();
        
        // Show error message if assessment not found
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Assessment not found in the record"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still showing
      Navigator.of(context).pop();
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error deleting health record: ${e.toString()}"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
    }
  }

  /// Builds an expandable card (UI remains unchanged).
  Widget _buildExpandableCard({
    required String title,
    required IconData icon,
    required Widget content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          backgroundColor: const Color.fromARGB(0, 0, 0, 0),
          leading: Icon(
            icon,
            color: const Color(0xFF52AAA4),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF3D4A5C),
            ),
          ),
          initiallyExpanded: true,
          childrenPadding: EdgeInsets.all(15.w),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [content],
        ),
      ),
    );
  }
  
  /// Builds a recommendation item.
  Widget _buildRecommendationItem(ListItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FA),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            if (item.isExternal) {
              await _launchURL(item.url!);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => item.route!,
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    item.imageUrl,
                    width: 80.w,
                    height: 80.h,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF52AAA4),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        item.subtitle,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF6B7A8D),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 5.w),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFF52AAA4),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}

/// A bottom sheet that can be resized by dragging the image area.
/// 
/// This widget displays a bottom sheet with a pet image at the top that
/// can be dragged to adjust the height of the sheet.
class ImageDraggableBottomSheet extends StatefulWidget {
  final Widget child;
  final double initialHeight;
  final double minHeight;
  final double maxHeight;
  final BoxDecoration decoration;
  final BorderRadius borderRadius;
  final Map<String, dynamic> petData;
  final String petBreed;
  final VoidCallback? onPetDetailsUpdated;

  const ImageDraggableBottomSheet({
    Key? key,
    required this.child,
    required this.initialHeight,
    required this.minHeight,
    required this.maxHeight,
    required this.decoration,
    required this.borderRadius,
    required this.petData,
    required this.petBreed,
    this.onPetDetailsUpdated,
  }) : super(key: key);

  @override
  State<ImageDraggableBottomSheet> createState() => ImageDraggableBottomSheetState();
}

class ImageDraggableBottomSheetState extends State<ImageDraggableBottomSheet> with SingleTickerProviderStateMixin {
  late double _currentHeight;
  bool _isDragging = false;
  late AnimationController _snapController;
  late Animation<double> _snapAnimation;
  
  // Add fixed bottom limit constant
  final double _fixedBottomLimit = 500.0; // Adjust value as needed
  
  // Heights for magnetic snapping
  double? _snapToHeight;
  final List<double> _snapPoints = [];

  @override
  void initState() {
    super.initState();
    _currentHeight = widget.initialHeight;
    
    // Setup animation controller for smooth snapping
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _snapController.addListener(() {
      if (_snapToHeight != null) {
        setState(() {
          _currentHeight = _snapAnimation.value;
        });
      }
    });
    
    // Calculate snap points - these are positions where the sheet will "snap" to
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenHeight = MediaQuery.of(context).size.height;
      _snapPoints.addAll([
        screenHeight * 0.45, // Small peek
        screenHeight * 0.65, // Half view
        screenHeight * 0.85, // Full view
      ]);
    });
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  void setHeight(double newHeight) {
    setState(() {
      // Use fixed bottom limit instead of widget.minHeight
      _currentHeight = newHeight.clamp(_fixedBottomLimit, widget.maxHeight);
    });
  }
  
  void _snapToNearestPoint(double velocity) {
    // Find the nearest snap point that's above our fixed bottom limit
    double? nearestPoint;
    double minDistance = double.infinity;
    
    for (final point in _snapPoints) {
      // Only consider snap points above our fixed limit
      if (point >= _fixedBottomLimit) {
        final distance = (_currentHeight - point).abs();
        if (distance < minDistance) {
          minDistance = distance;
          nearestPoint = point;
        }
      }
    }
    
    // If there are no valid snap points, default to the fixed bottom limit
    nearestPoint ??= _fixedBottomLimit;
    
    // If the velocity is significant, snap in that direction
    if (velocity.abs() > 800 && nearestPoint != _fixedBottomLimit) {
      final direction = velocity < 0 ? 1 : -1;
      final currentIndex = _snapPoints.indexOf(nearestPoint);
      int targetIndex = (currentIndex + direction).clamp(0, _snapPoints.length - 1);
      
      // Ensure the target snap point is above our fixed limit
      while (targetIndex >= 0 && targetIndex < _snapPoints.length && 
             _snapPoints[targetIndex] < _fixedBottomLimit) {
        targetIndex += direction > 0 ? 1 : -1;
      }
      
      // If we found a valid target, use it
      if (targetIndex >= 0 && targetIndex < _snapPoints.length) {
        nearestPoint = _snapPoints[targetIndex];
      }
    }
    
    // Snap to the selected point if it differs from current height
    if (nearestPoint != null && (nearestPoint - _currentHeight).abs() > 10) {
      _snapToHeight = nearestPoint;
      
      // Create animation
      _snapAnimation = Tween<double>(
        begin: _currentHeight,
        end: _snapToHeight,
      ).animate(CurvedAnimation(
        parent: _snapController,
        curve: Curves.easeOutCubic,
      ));
      
      // Start animation
      _snapController.reset();
      _snapController.forward().then((_) {
        _snapToHeight = null;
      });
    }
  }

  // Add method to show edit dialog
  void _showEditDialog(BuildContext context) {
  // Create the controllers inside the builder:
  showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      final ageController = TextEditingController(
        text: (widget.petData['petDetails'] as List<dynamic>? ?? [])
                .length > 1
            ? (widget.petData['petDetails'][1]['value']?.toString() ?? '')
            : '',
      );
      final sizeController = TextEditingController(
        text: (widget.petData['petDetails'] as List<dynamic>? ?? [])
                .length > 2
            ? (widget.petData['petDetails'][2]['value']?.toString() ?? '')
            : '',
      );

      return AlertDialog(
        title: Text(
          "Edit Pet Details",
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF3D4A5C),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,  // <-- shrink to fit
            children: [
              TextField(
                controller: ageController,
                decoration: InputDecoration(
                  labelText: 'Age',
                  hintText: 'e.g. 2 yrs',
                  prefixIcon: Icon(Icons.cake, color: Colors.amber),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(
                        color: const Color(0xFF52AAA4), width: 2),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: sizeController,
                inputFormatters: [
                  FirstLetterUpperCaseTextFormatter(),
                  FilteringTextInputFormatter.deny(RegExp(r'[0-9]')),
                ],
                decoration: InputDecoration(
                  labelText: 'Size',
                  hintText: 'e.g. Medium',
                  prefixIcon: Icon(Icons.straighten, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(
                        color: const Color(0xFF52AAA4), width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text(
              "Cancel",
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF52AAA4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              "Save",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () async {
              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => Center(
                  child: CircularProgressIndicator(
                    color: const Color(0xFF52AAA4),
                  ),
                ),
              );

              try {
                await _updatePetDetails(
                    ageController.text, sizeController.text);
                Navigator.of(context).pop(); // close loading
                Navigator.of(dialogContext).pop(); // close dialog

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text("Pet details updated successfully"),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                );
                if (widget.onPetDetailsUpdated != null) {
                  widget.onPetDetailsUpdated!();
                }
              } catch (e) {
                Navigator.of(context).pop(); // close loading
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        "Error updating pet details: ${e.toString()}"),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      );
    },
  );
}


  // Add method to update Firestore
  Future<void> _updatePetDetails(String newAge, String newSize) async {
    try {
      // Get user ID
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception("User is not signed in.");
      }
      
      // Get document ID from petData
      final String documentId = widget.petData['id'] ?? "";
      if (documentId.isEmpty) {
        throw Exception("Document ID not found");
      }
      
      // Create a copy of the pet details
      List<dynamic> updatedDetails = [];
      if (widget.petData['petDetails'] is List) {
        updatedDetails = List.from(widget.petData['petDetails']);
        
        // Update age (index 1)
        if (updatedDetails.length > 1) {
          updatedDetails[1] = {
            ...updatedDetails[1] as Map<String, dynamic>,
            'value': newAge
          };
        }
        
        // Update size (index 2)
        if (updatedDetails.length > 2) {
          updatedDetails[2] = {
            ...updatedDetails[2] as Map<String, dynamic>,
            'value': newSize
          };
        }
      }
      
      // Update Firestore
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('History')
          .doc(documentId)
          .update({
            'petDetails': updatedDetails,
          });
      
      // Update local state to reflect changes
      setState(() {
        widget.petData['petDetails'] = updatedDetails;
      });
      
    } catch (e) {
      print("Error updating pet details: $e");
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: _isDragging ? 0 : 200),
      curve: Curves.easeInOut,
      height: _currentHeight,
      decoration: widget.decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Pet image section that acts as the draggable area
          GestureDetector(
            onVerticalDragStart: (details) {
              // Stop any running snap animation
              _snapController.stop();
              _snapToHeight = null;
              
              setState(() {
                _isDragging = true;
              });
            },
            onVerticalDragUpdate: (details) {
           
            final newHeight = _currentHeight - details.delta.dy;
            
            
            final screenHeight = MediaQuery.of(context).size.height;
            
            
            final minVisiblePortion = screenHeight * 0.3;
            
            
            final effectiveBottomLimit = max(_fixedBottomLimit, minVisiblePortion);
            
          
            final limitedHeight = newHeight.clamp(effectiveBottomLimit, widget.maxHeight);
            
            setState(() {
              _currentHeight = limitedHeight;
            });
          },
            onVerticalDragEnd: (details) {
              setState(() {
                _isDragging = false;
              });
              
              // Snap to nearest point when user stops dragging
              _snapToNearestPoint(details.velocity.pixelsPerSecond.dy);
            },
            child: Stack(
              children: [
                Container(
                  height: 400.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: widget.borderRadius,
                    image: DecorationImage(
                      image: widget.petData['petImage'] != null &&
                              (widget.petData['petImage'] as String).startsWith("http")
                          ? NetworkImage(widget.petData['petImage'])
                          : AssetImage(widget.petData['petImage'] ?? "assets/sampleimage.jpg") as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Close button
                Positioned(
                  top: 12.h,
                  left: 12.w,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(8.sp),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ),
                // Edit button
                Positioned(
                  top: 340.h,
                  right: 12.w,
                  child: GestureDetector(
                    onTap: () {
                      // Show edit dialog for age and size
                      _showEditDialog(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.sp),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 22.sp,
                      ),
                    ),
                  ),
                ),
                // Pet name and breed info at the bottom of the image
                Positioned(
                  bottom: 12.h,
                  left: 16.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.petData['petName'] ?? "Unknown",
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 8.0,
                              color: Colors.black.withOpacity(0.5),
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        widget.petBreed,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 8.0,
                              color: Colors.black.withOpacity(0.5),
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Content section
          Expanded(
            child: NotificationListener<ScrollNotification>(
              // Prevent scroll actions when dragging the modal
              onNotification: (notification) {
                if (_isDragging) {
                  return true; // Block scroll when dragging
                }
                return false; // Allow scroll normally
              },
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: widget.child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ListItem {
  final String title;
  final String subtitle;
  final Widget? route;
  final String? url;
  final bool isExternal;
  final String imageUrl;

  const ListItem({
    required this.title,
    required this.subtitle,
    this.route,
    this.url,
    required this.isExternal,
    required this.imageUrl,
  });
}

class FirstLetterUpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue; // Return empty value
    }
    
    // Capitalize the first letter and keep the rest as-is
    final text = newValue.text;
    final firstLetter = text[0].toUpperCase();
    final restOfText = text.substring(1);
    
    return newValue.copyWith(
      text: firstLetter + restOfText,
      selection: newValue.selection,
    );
  }
}