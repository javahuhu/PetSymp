import 'package:flutter/material.dart';
import 'package:petsymp/Assesment/breed.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import '../userdata.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';

class MeasureinputScreen extends StatefulWidget {
  const MeasureinputScreen({super.key});
  @override
  MeasureinputScreenState createState() => MeasureinputScreenState();
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

class MeasureinputScreenState extends State<MeasureinputScreen> with SingleTickerProviderStateMixin {
  bool _isAnimated = false; 
  String _selectedSize = ''; 
  late AnimationController _bubbleAnimationController;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller
    _bubbleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    // Trigger the animation after the widget builds
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimated = true;
      });
    });
  }

  @override
  void dispose() {
    _bubbleAnimationController.dispose();
    super.dispose();
  }

  // Helper method to launch external URLs
  Future<void> gotoPage(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  final TextEditingController _sizeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _handleSizeSelection(String selectedSize) {
  setState(() {
    _selectedSize = selectedSize;
    _sizeController.text = selectedSize;
  });
}

  void navigateToNextPage() {
    if (_formKey.currentState?.validate() ?? false) {
      Provider.of<UserData>(context, listen: false)
          .setpetSize(_sizeController.text);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BreedScreen()),
      );
    }
  }

  // Function to show the pet size guide modal
  void _showPetSizeGuideModal() {
    final isCat = Provider.of<UserData>(context, listen: false)
            .selectedPetType
            .toLowerCase() ==
        'cat';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(66, 134, 129, 0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isCat ? "Cat Size Guide" : "Dog Size Guide",
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromRGBO(29, 29, 44, 1.0),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close,
                        color: Color.fromRGBO(29, 29, 44, 1.0),
                      ),
                    ),
                  ],
                ),
              ),

              // Size examples
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: isCat
                        ? [
                            _buildSizeInfoRow(
                                "Small",
                                "Up to 5 pounds (2.3 kg)",
                                "Examples: Singapura, Munchkin, Cornish Rex",
                                "smallcat.png", _handleSizeSelection, _selectedSize == "Small"),
                            const Divider(height: 30),
                            _buildSizeInfoRow(
                                "Medium",
                                "5–10 pounds (2.3–4.5 kg)",
                                "Examples: American Shorthair, Burmese",
                                "mediumcat.png", _handleSizeSelection, _selectedSize == "Medium"),
                            const Divider(height: 30),
                            _buildSizeInfoRow(
                                "Large",
                                "10–15 pounds (4.5–6.8 kg)",
                                "Examples: Ragdoll, Maine Coon",
                                "largecat.png", _handleSizeSelection, _selectedSize == "Large"),
                            const Divider(height: 30),
                            _buildSizeInfoRow(
                                "Giant",
                                "Over 15 pounds (6.8+ kg)",
                                "Examples: Savannah Cat, Norwegian Forest Cat",
                                "giantcat.png", _handleSizeSelection, _selectedSize == "Giant"),
                          ]
                        : [
                            _buildSizeInfoRow(
                                "Small",
                                "Up to 20 pounds (9 kg)",
                                "Examples: Chihuahua, Pomeranian, Toy Poodle",
                                "smallpet.png", _handleSizeSelection, _selectedSize == "Small"),
                            const Divider(height: 30),
                            _buildSizeInfoRow(
                                "Medium",
                                "20–60 pounds (9–27 kg)",
                                "Examples: Beagle, Bulldog, Cocker Spaniel",
                                "mediumpet.png", _handleSizeSelection, _selectedSize == "Medium"),
                            const Divider(height: 30),
                            _buildSizeInfoRow(
                                "Large",
                                "60–100 pounds (27–45 kg)",
                                "Examples: Golden Retriever, Boxer",
                                "largepet.png", _handleSizeSelection, _selectedSize == "Large"),
                            const Divider(height: 30),
                            _buildSizeInfoRow(
                                "Giant",
                                "Over 100 pounds (45+ kg)",
                                "Examples: Great Dane, Mastiff",
                                "extralargepet.png", _handleSizeSelection, _selectedSize == "Giant"),
                          ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  
  Widget _buildSizeInfoRow(
  String size,
  String weight,
  String examples,
  String imageName,
  void Function(String) onSelect,
  bool isSelected, 
) {
  return GestureDetector(
  onTap: () {
    onSelect(size);
    Navigator.pop(context);
  },
  child: Container(
    decoration: BoxDecoration(
      color: isSelected
          ? const Color.fromRGBO(82, 170, 164, 0.15) 
          : Colors.transparent,
      border: Border.all(
        color: isSelected
            ? const Color.fromRGBO(82, 170, 164, 1)
            : Colors.transparent,
        width: 2,
      ),
      borderRadius: BorderRadius.circular(10),
    ),
    padding: const EdgeInsets.all(10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pet image or placeholder
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(66, 134, 129, 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Image.asset(
              'assets/$imageName',
              width: 70,
              height: 70,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.pets,
                  size: 40,
                  color: Color.fromRGBO(66, 134, 129, 0.6),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 15),
        // Size details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                size,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromRGBO(29, 29, 44, 1.0),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                weight,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color.fromRGBO(29, 29, 44, 0.8),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                examples,
                style: const TextStyle(
                  color: Color.fromRGBO(29, 29, 44, 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
);

}


  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        // Enhanced background with gradient
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(225, 240, 243, 1.0),
              Color.fromRGBO(201, 229, 231, 1.0),
              Color(0xFFE8F2F5),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Decorative background elements
            // Large wave-like shape at the top
            Positioned(
              top: -screenHeight * 0.2,
              left: -screenWidth * 0.25,
              child: AnimatedBuilder(
                animation: _bubbleAnimationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      0,
                      _bubbleAnimationController.value * 10,
                    ),
                    child: Container(
                      width: screenWidth * 1.5,
                      height: screenHeight * 0.5,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(66, 134, 129, 0.07),
                        borderRadius:
                            BorderRadius.circular(screenHeight * 0.25),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Smaller wave-like shape in bottom-right
            Positioned(
              bottom: -screenHeight * 0.1,
              right: -screenWidth * 0.25,
              child: AnimatedBuilder(
                animation: _bubbleAnimationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      0,
                      -_bubbleAnimationController.value * 10,
                    ),
                    child: Container(
                      width: screenWidth * 0.9,
                      height: screenHeight * 0.3,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(66, 134, 129, 0.08),
                        borderRadius:
                            BorderRadius.circular(screenHeight * 0.15),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Middle-left floating bubble
            Positioned(
              top: screenHeight * 0.45,
              left: screenWidth * 0.05,
              child: AnimatedBuilder(
                animation: _bubbleAnimationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      _bubbleAnimationController.value * 5,
                      _bubbleAnimationController.value * 8,
                    ),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color.fromRGBO(66, 134, 129, 0.2),
                        border: Border.all(
                          color: const Color.fromRGBO(66, 134, 129, 0.3),
                          width: 1.5,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Middle-right small floating circle
            Positioned(
              top: screenHeight * 0.6,
              right: screenWidth * 0.1,
              child: AnimatedBuilder(
                animation: _bubbleAnimationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      -_bubbleAnimationController.value * 8,
                      -_bubbleAnimationController.value * 6,
                    ),
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Color.fromRGBO(72, 138, 163, 0.3),
                            Color.fromRGBO(72, 138, 163, 0.1),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Small dot pattern top-right
            Positioned(
              top: screenHeight * 0.25,
              right: screenWidth * 0.15,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromRGBO(72, 138, 163, 0.4),
                ),
              ),
            ),
            Positioned(
              top: screenHeight * 0.26,
              right: screenWidth * 0.2,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromRGBO(72, 138, 163, 0.3),
                ),
              ),
            ),

            // AnimatedPositioned for Paw Image
            AnimatedPositioned(
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
              top: _isAnimated
                  ? screenHeight * 0.13
                  : -100, // From off-screen to final position
              left: screenWidth * 0.1,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: screenWidth * 0.15, // 15% of screen width
                    height:
                        screenWidth * 0.15, // Equal height for circular image
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      'assets/paw.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(
                      width:
                          screenWidth * 0.05), // Spacing between paw and text
                ],
              ),
            ),

            Positioned(
              top: screenHeight * 0.22, // Text and input below the paw
              left: screenWidth * 0.12,
              right: screenWidth * 0.02,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SlideInLeft(
                    duration: const Duration(milliseconds: 1000),
                    delay: const Duration(milliseconds: 300),
                    from: 400,
                    child: Text(
                      "What are pet sizes?",
                      style: TextStyle(
                        fontSize: 25.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Oswald',
                        color: const Color.fromRGBO(29, 29, 44, 1.0),
                      ),
                    ),
                  )
                ],
              ),
            ),

            Positioned(
              top: screenHeight * 0.32, // Adjusted position for the form
              left: screenWidth * 0.12,
              right: screenWidth * 0.12,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    TextFormField(
                        controller: _sizeController,
                        autofillHints: const [AutofillHints.name],
                        inputFormatters: [
                          FirstLetterUpperCaseTextFormatter(),
                          FilteringTextInputFormatter.deny(RegExp(r'[0-9]')),
                        ],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(
                              color: Color.fromRGBO(82, 170, 164,
                                  1), // Border color when not focused
                              width: 2.0, // Thickness when not focused
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(
                              color: Color.fromRGBO(
                                  72, 38, 163, 1), // Border color when focused
                              width: 2.0, // Thickness when focused
                            ),
                          ),
                          hintText: 'Enter the Size of the Pet',
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 20.0,
                            horizontal: 15.0,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter size of the pet';
                          }

                          final cleanedValue = value.trim();

                          // Disallow comma, plus, or space (multiple entries)
                          if (cleanedValue.contains(',') ||
                              cleanedValue.contains('+') ||
                              cleanedValue.contains(' ')) {
                            return 'Please enter only one size';
                          }

                          const validSizes = [
                            "Small",
                            "Medium",
                            "Large",
                            "Giant"
                          ];
                          if (!validSizes.contains(cleanedValue)) {
                            return 'Small, Medium, Large, or Giant Only';
                          }

                          return null;
                        }),

                        
                    // New help button text below the TextFormField
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, left: 5.0),
                      child: GestureDetector(
                        onTap: _showPetSizeGuideModal,
                        child: const Text(
                          "What is the size of pet?",
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.none,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              top: screenHeight * 0.9,
              right: screenWidth * 0.03, 
              child: SlideInUp(
                duration: const Duration(milliseconds: 1000),
                delay: const Duration(milliseconds: 300),
                from: 400,
                child: SizedBox(
                  width: 125.w, 
                  child: GestureDetector(
                    onTap: navigateToNextPage,
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
                                "Next",
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
