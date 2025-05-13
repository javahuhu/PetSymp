import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../userdata.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:petsymp/Assesment/searchsymptoms.dart';
import 'package:petsymp/Breed/dogBreed.dart';
import 'package:petsymp/Breed/catBreed.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class BreedScreen extends StatefulWidget {
  const BreedScreen({super.key});

  @override
  BreedScreenState createState() => BreedScreenState();
}

class BreedScreenState extends State<BreedScreen>
    with SingleTickerProviderStateMixin {
  bool _isAnimated = false;
  AnimationController? _bubbleAnimationController;
  int? selectedIndex;
  final TextEditingController _breedcontroller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String searchQuery = '';
  String selectedLetter = 'All';

  @override
  void initState() {
    super.initState();
    _bubbleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _isAnimated = true;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _bubbleAnimationController?.dispose();
    super.dispose();
  }

  void navigateToNextPage() {
    if (selectedIndex != null) {
      Provider.of<UserData>(context, listen: false)
          .setpetBreed(_breedcontroller.text);

      // Add a subtle haptic feedback
      HapticFeedback.mediumImpact();

      // Transition to next screen with a smooth animation
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const SearchsymptomsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    } else {
      // Improved error feedback
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.pets, color: Colors.white),
              const SizedBox(width: 10),
              const Text("Please select a pet breed first"),
            ],
          ),
          backgroundColor: const Color(0xFF2A384D),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.1,
            left: 20,
            right: 20,
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final petType =
        Provider.of<UserData>(context).selectedPetType.toLowerCase();
    final breedList = petType == "cat" ? catBreed : dogBreed;

    final displayedBreeds = breedList.where((breed) {
      final name = breed["breed"]!.toLowerCase();
      final matchesSearch = name.contains(searchQuery.toLowerCase());
      final matchesLetter = selectedLetter == 'All' ||
          name.startsWith(selectedLetter.toLowerCase());
      return matchesSearch && matchesLetter;
    }).toList();

    final List<String> letters = [
      'All',
      ...List.generate(26, (i) => String.fromCharCode(65 + i))
    ];

    const primaryColor = Color.fromRGBO(82, 170, 164, 1);
    const secondaryColor = Color(0xFF263238);
    const accentColor = Color(0xFFFF5252);
    const backgroundColor = Color(0xFFF5FCFF);
    const textDarkColor = Color(0xFF1D2B3A);

    return Scaffold(
      body: Container(
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
            // Check that controller is initialized before using it
            if (_bubbleAnimationController != null) ...[
              // Decorative background elements
              // Large wave-like shape at the top
              Positioned(
                top: -screenHeight * 0.2,
                left: -screenWidth * 0.25,
                child: AnimatedBuilder(
                  animation: _bubbleAnimationController!,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        0,
                        _bubbleAnimationController!.value * 10,
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
                  animation: _bubbleAnimationController!,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        0,
                        -_bubbleAnimationController!.value * 10,
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
                  animation: _bubbleAnimationController!,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        _bubbleAnimationController!.value * 5,
                        _bubbleAnimationController!.value * 8,
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
                  animation: _bubbleAnimationController!,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        -_bubbleAnimationController!.value * 8,
                        -_bubbleAnimationController!.value * 6,
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
            ],

            // Static background elements that don't need the animation controller
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

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 50.h),
                  SlideInLeft(
                      duration: const Duration(milliseconds: 1000),
                      delay: const Duration(milliseconds: 300),
                      from: 300,
                      child: Padding(
                        padding: EdgeInsets.only(left: 5.w, top: 25.h),
                        child: Text(
                          "What is your pet Breed?",
                          style: TextStyle(
                            fontSize: 25.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Oswald',
                            color: const Color.fromRGBO(29, 29, 44, 1.0),
                          ),
                        ),
                      )),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: "Search breed...",
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            prefixIcon: const Icon(Icons.search),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // Dropdown A-Z
                      Expanded(
                        flex: 2,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2<String>(
                            isExpanded: true,
                            value: selectedLetter,
                            onChanged: (value) {
                              setState(() {
                                selectedLetter = value!;
                              });
                            },
                            items: letters.map((letter) {
                              return DropdownMenuItem<String>(
                                value: letter,
                                child: Text(letter,
                                    style: const TextStyle(fontSize: 14)),
                              );
                            }).toList(),
                            buttonStyleData: ButtonStyleData(
                              height: 45,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                                color: Colors.white,
                              ),
                            ),
                            dropdownStyleData: DropdownStyleData(
                              maxHeight: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Results count indicator
                  if (displayedBreeds.isNotEmpty)
                    FadeIn(
                      duration: const Duration(milliseconds: 600),
                      child: Padding(
                        padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
                        child: Text(
                          "Found ${displayedBreeds.length} breeds",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                  // Breed grid or empty state
                  Expanded(
                    child: displayedBreeds.isEmpty
                        ? Center(
                            child: FadeInUp(
                              duration: const Duration(milliseconds: 800),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(16.w),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.7),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.search_off_rounded,
                                      size: 56.sp,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    "No breeds found",
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    "Try another search term or filter",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Scrollbar(
                            controller: _scrollController,
                            thickness: 6,
                            radius: const Radius.circular(8),
                            child: GridView.builder(
                              controller: _scrollController,
                              padding: EdgeInsets.only(top: 8.h, bottom: 100.h, left: 10.w, right: 10.w),
                              itemCount: displayedBreeds.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 3 / 3.3,
                                mainAxisSpacing: 16.h,
                                crossAxisSpacing: 16.w,
                              ),
                              itemBuilder: (context, index) {
                                final breed = displayedBreeds[index];
                                final isSelected =
                                    breed["breed"] == _breedcontroller.text;

                                return FadeInUp(
                                  duration: Duration(
                                      milliseconds: 600 + (index * 50)),
                                  from: 20,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedIndex = index;
                                        _breedcontroller.text = breed["breed"]!;
                                      });
                                      HapticFeedback.lightImpact();
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      curve: Curves.easeOutExpo,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? secondaryColor
                                            : Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(22.r),
                                        boxShadow: [
                                          BoxShadow(
                                            color: isSelected
                                                ? secondaryColor
                                                    .withOpacity(0.4)
                                                : Colors.black
                                                    .withOpacity(0.08),
                                            blurRadius: isSelected ? 15 : 10,
                                            spreadRadius: isSelected ? 1 : 0,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: Stack(
                                        children: [
                                          // Card content
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              // Breed name
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 5.w,
                                                    vertical: 14.h),
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? secondaryColor
                                                      : Colors.white,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(22.r),
                                                    topRight:
                                                        Radius.circular(22.r),
                                                    bottomLeft:
                                                        Radius.circular(15.r),
                                                    bottomRight:
                                                        Radius.circular(15.r),
                                                  ),
                                                ),
                                                child: Text(
                                                  breed["breed"]!,
                                                  textAlign: TextAlign.center,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: isSelected
                                                        ? Colors.white
                                                        : textDarkColor,
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),

                                              // Image area with dark background
                                              Expanded(
                                                child: Container(
                                                  padding: EdgeInsets.all(8.w),
                                                  child: Center(
                                                    child: Hero(
                                                      tag:
                                                          "breed_${breed["breed"]}",
                                                      child: Container(
                                                        height: 125.w,
                                                        width: 125.w,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              Colors.black
                                                                  .withOpacity(
                                                                      0.08),
                                                              Colors.black
                                                                  .withOpacity(
                                                                      0.03),
                                                            ],
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight,
                                                          ),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: isSelected
                                                                  ? primaryColor
                                                                      .withOpacity(
                                                                          0.2)
                                                                  : Colors.black
                                                                      .withOpacity(
                                                                          0.1),
                                                              blurRadius: 15,
                                                              offset:
                                                                  const Offset(
                                                                      0, 5),
                                                            ),
                                                          ],
                                                        ),
                                                        child: ClipOval(
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    5.w),
                                                            child: Image.asset(
                                                              breed["img"]!,
                                                              fit: BoxFit
                                                                  .contain,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          // Smooth animated check icon
                                          AnimatedPositioned(
                                            duration: const Duration(
                                                milliseconds: 500),
                                            curve: Curves.easeOut,
                                            bottom: isSelected ? 14.h : 0,
                                            right: isSelected ? 14.w : 0,
                                            child: AnimatedOpacity(
                                              duration: const Duration(
                                                  milliseconds: 300),
                                              opacity: isSelected ? 1.0 : 0.0,
                                              child: AnimatedScale(
                                                scale: isSelected ? 1.0 : 0.6,
                                                duration: const Duration(
                                                    milliseconds: 300),
                                                child: Container(
                                                  padding: EdgeInsets.all(5.w),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: accentColor,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: accentColor
                                                            .withOpacity(0.3),
                                                        blurRadius: 6,
                                                        offset:
                                                            const Offset(0, 3),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Icon(
                                                    Icons.check,
                                                    color: Colors.white,
                                                    size: 16.sp,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: 24.h,
              left: 0,
              right: 0,
              child: SlideInUp(
                duration: const Duration(milliseconds: 800),
                from: 40,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: GestureDetector(
                    onTap: navigateToNextPage,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 60.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: selectedIndex != null
                              ? [
                                  primaryColor,
                                  const Color.fromRGBO(82, 170, 164, 1)
                                ]
                              : [Colors.grey.shade300, Colors.grey.shade400],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30.r),
                        boxShadow: [
                          BoxShadow(
                            color: selectedIndex != null
                                ? primaryColor.withOpacity(0.4)
                                : Colors.grey.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 0,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Continue",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
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

  List<Widget> _buildBackgroundAnimation(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return [
      // Top large background
      Positioned(
        top: -screenHeight * 0.2,
        left: -screenWidth * 0.25,
        child: AnimatedBuilder(
          animation: _bubbleAnimationController!,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _bubbleAnimationController!.value * 10),
              child: Container(
                width: screenWidth * 1.5,
                height: screenHeight * 0.5,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(66, 134, 129, 0.07),
                  borderRadius: BorderRadius.circular(screenHeight * 0.25),
                ),
              ),
            );
          },
        ),
      ),
      // Bottom-right shape
      Positioned(
        bottom: -screenHeight * 0.1,
        right: -screenWidth * 0.25,
        child: AnimatedBuilder(
          animation: _bubbleAnimationController!,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -_bubbleAnimationController!.value * 10),
              child: Container(
                width: screenWidth * 0.9,
                height: screenHeight * 0.3,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(66, 134, 129, 0.08),
                  borderRadius: BorderRadius.circular(screenHeight * 0.15),
                ),
              ),
            );
          },
        ),
      ),
    ];
  }
}
