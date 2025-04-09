import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'userdata.dart';
import 'package:petsymp/userpet.dart'; // This screen is shown when a pet is selected

class CardpetScreen extends StatefulWidget {
  const CardpetScreen({super.key});

  @override
  CardpetScreenState createState() => CardpetScreenState();
}

class CardpetScreenState extends State<CardpetScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  final double _scaleFactor = 0.8;

  late AnimationController _animationController = AnimationController(
    duration: const Duration(milliseconds: 500),
    vsync: this,
  );
  late Animation<double> _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
  );

  bool _isAnimating = false;
  String _selectedPet = 'Dog'; // Default to first pet

  final List<Map<String, dynamic>> _pets = [
    {
      'image': 'assets/cardDog.png',
      'name': 'Dog',
      'description': 'Loyal companion for your family',
      'color': const Color(0xFF428682),
      'page': const UserPetScreen(),
    },
    {
      'image': 'assets/cardCat.png',
      'name': 'Cat',
      'description': 'Elegant and independent friend',
      'color': const Color(0xFF5DBFB0),
      'page': const UserPetScreen(),
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.75, initialPage: _currentPage);
    _animationController.forward();
    _pageController.addListener(() {
      final page = _pageController.page;
      if (page != null) {
        setState(() {
          _currentPage = page.round();
          _selectedPet = _pets[_currentPage]['name'] as String;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToPetPage(int index) {
    if (_isAnimating) return;
    final selectedPet = _pets[index]['name'] as String;
    // Set the pet type in the provider.
    Provider.of<UserData>(context, listen: false).setSelectedPetType(selectedPet);
    setState(() {
      _isAnimating = true;
      _selectedPet = selectedPet;
    });
    _animationController.reverse().then((_) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => _pets[index]['page']),
      );
      _animationController.forward().then((_) {
        setState(() {
          _isAnimating = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(29, 29, 44, 1.0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenHeight -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 60.h),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          'What is your Pet?',
                          style: TextStyle(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                            color: const Color(0xFF428682),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'Choose your companion',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Inter',
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  height: 420.h,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _pets.length,
                      physics: const BouncingScrollPhysics(),
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                          _selectedPet = _pets[page]['name'] as String;
                        });
                      },
                      itemBuilder: (context, index) {
                        final isSelected = _selectedPet == _pets[index]['name'];
                        final scale = _currentPage == index ? 1.0 : _scaleFactor;
                        return TweenAnimationBuilder(
                          tween: Tween<double>(begin: scale, end: scale),
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutQuint,
                          builder: (context, double value, child) {
                            return Transform.scale(scale: value, child: child);
                          },
                          child: _buildEnhancedPetCard(
                            _pets[index]['image'] as String,
                            _pets[index]['name'] as String,
                            _pets[index]['description'] as String,
                            _pets[index]['color'] as Color,
                            index,
                            isSelected,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  height: 30.h,
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pets.length, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(horizontal: 5.w),
                        height: 8.h,
                        width: _currentPage == index ? 24.w : 8.w,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? _pets[index]['color'] as Color
                              : Colors.grey[600],
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      );
                    }),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 20.h),
                  child: ElevatedButton(
                    onPressed: () => _navigateToPetPage(_currentPage),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _pets[_currentPage]['color'] as Color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      minimumSize: Size(double.infinity, 50.h),
                      elevation: 4,
                    ),
                    child: Text(
                      'Continue with ${_pets[_currentPage]['name']}',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedPetCard(
    String imagePath,
    String petName,
    String description,
    Color accentColor,
    int index,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        ).then((_) {
          Future.delayed(const Duration(milliseconds: 200), () {
            _navigateToPetPage(index);
          });
        });
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(227, 32, 32, 49),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: isSelected ? accentColor : Colors.transparent,
              width: isSelected ? 3.0 : 0.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? accentColor.withOpacity(0.4)
                    : Colors.black.withOpacity(0.2),
                blurRadius: 15.r,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.r),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        accentColor.withOpacity(0.15),
                      ],
                    ),
                  ),
                ),
              ),
              if (isSelected)
                Positioned(
                  top: 15.h,
                  right: 15.w,
                  child: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                  ),
                ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 15.h),
                  Hero(
                    tag: 'pet-$petName',
                    child: Container(
                      width: 180.w,
                      height: 180.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(0.3),
                            blurRadius: 20.r,
                            spreadRadius: 5.r,
                          ),
                        ],
                        image: DecorationImage(
                          image: AssetImage(imagePath),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Text(
                      petName,
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Oswald',
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Text(
                      description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white.withOpacity(0.8),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 60.w,
                    height: 6.h,
                    decoration: BoxDecoration(
                      color: _currentPage == index ? accentColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  ),
                  SizedBox(height: 15.h),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
