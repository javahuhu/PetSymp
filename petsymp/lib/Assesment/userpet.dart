import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:petsymp/Assesment/petimage.dart';
import 'package:petsymp/Assesment/symptoms.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../userdata.dart';

class UserPetScreen extends StatefulWidget {
  const UserPetScreen({super.key});
  @override
  UserPetScreenState createState() => UserPetScreenState();
}

class UserPetScreenState extends State<UserPetScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isAnimating = false;
  String _selectedPet = '';
  String? _userId;
  bool _subscribed = false;

  // The static fallback list is retained only for reference.
  

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    _animationController.forward();
    _userId = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_subscribed && _userId != null) {
      Provider.of<UserData>(context, listen: false).subscribeToHistory(_userId!);
      _subscribed = true;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToSymptomScreen(int index) {
  if (_isAnimating) return;
  final userData = Provider.of<UserData>(context, listen: false);

  final filteredHistory = userData.history
    .where((entry) => entry['petType'] == userData.selectedPetType)
    .toList();

  if (filteredHistory.isNotEmpty && index < filteredHistory.length) {
    final entry      = filteredHistory[index];
    final petDetails = entry['petDetails'] as List<dynamic>? ?? [];

    // Corrected indices:
    final age   = int.tryParse(petDetails.length > 2 ? petDetails[2]['value'] ?? '' : '') ?? 0;
    final size  =             petDetails.length > 3 ? petDetails[3]['value'] ?? '' : '';
    final breed =             petDetails.length > 4 ? petDetails[4]['value'] ?? '' : '';

    userData
      ..setUserName(entry['petName'] ?? '')
      ..setpetAge(age)
      ..setpetSize(size)
      ..setpetBreed(breed)
      ..setPetImage(entry['petImage'] ?? '')
      ..setSelectedPetType(entry['petType'] ?? '');
    
    setState(() {
      _isAnimating = true;
      _selectedPet = entry['petName'] ?? '';
    });
    
    _animationController.reverse().then((_) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SymptomsScreen()),
      ).then((_) {
        _animationController.forward().then((_) {
          setState(() {
            _isAnimating = false;
          });
        });
      });
    });
  }
}


  void _navigateToNewPetScreen() {
    if (_isAnimating) return;
    final userData = Provider.of<UserData>(context, listen: false);
    // Clear the basic info while keeping pet type intact.
    userData.clearBasicInfo();
    _animationController.reverse().then((_) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PetimageScreen()),
      ).then((_) {
        _animationController.forward().then((_) {
          setState(() {
            _isAnimating = false;
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);
    final history = userData.history;
  
    final List<Map<String, dynamic>> items = history.isNotEmpty
        ? history
            .where((entry) => entry['petType'] == userData.selectedPetType)
            .map((entry) {
                final ts = entry['date'] as Timestamp?;
                final dateStr = ts != null
                    ? ts.toDate().toLocal().toString().split(' ')[0]
                    : '';
                return {
                  'image': entry['petImage'] ?? 'assets/sampleimage.jpg',
                  'name': entry['petName'] ?? '',
                  'description': dateStr,
                  'color': entry['color'] ?? const Color(0xFF428682),
                };
              })
            .toList()
        : [];
    final bool hasItems = items.isNotEmpty;
  
    final Color primaryColor = hasItems
        ? (items.firstWhere(
                    (pet) => pet['name'] == _selectedPet,
                    orElse: () => items[0])['color'] as Color)
        : Colors.grey;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(29, 29, 44, 1.0),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 40.h),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: Column(
                  children: [
                    Text(
                      'Who needs the assessment?',
                      style: TextStyle(
                        fontSize: 26.sp,
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
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: hasItems
                    ? ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final isSelected = _selectedPet == item['name'];
                          return _buildPetCard(
                            item['image'] as String,
                            item['name'] as String,
                            item['description'] as String,
                            item['color'] as Color,
                            index,
                            isSelected,
                          );
                        },
                      )
                    : Center(
                        child: Text(
                          'No assessment yet.',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.white70,
                            fontFamily: 'Inter',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _navigateToNewPetScreen,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        minimumSize: Size(double.infinity, 50.h),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_outline, size: 20.sp),
                          SizedBox(width: 8.w),
                          Text(
                            'New',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // "Select" Button – enabled only if there is at least one item.
                  Expanded(
                    child: ElevatedButton(
                      onPressed: hasItems
                          ? () {
                              final idx = items.indexWhere(
                                  (pet) => pet['name'] == _selectedPet);
                              if (idx != -1) _navigateToSymptomScreen(idx);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        minimumSize: Size(double.infinity, 50.h),
                        elevation: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 20.sp),
                          SizedBox(width: 8.w),
                          Text(
                            'Select',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inter',
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
      ),
    );
  }

  Widget _buildPetCard(
    String imagePath,
    String petName,
    String description,
    Color accentColor,
    int index,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPet = petName;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: const Color.fromARGB(227, 32, 32, 49),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? accentColor : Colors.transparent,
            width: isSelected ? 3.0 : 0.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? accentColor.withValues(alpha:0.4)
                  : Colors.black.withValues(alpha:0.2),
              blurRadius: 8.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Hero(
              tag: 'pet-$petName',
              child: Container(
                width: 100.w,
                height: 100.h,
                margin: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha:0.3),
                      blurRadius: 10.r,
                      spreadRadius: 2.r,
                    ),
                  ],
                  image: DecorationImage(
                    image: imagePath.startsWith('http')
                        ? NetworkImage(imagePath) as ImageProvider
                        : AssetImage(imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      petName,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      description,
                      style:
                          TextStyle(fontSize: 14.sp, color: Colors.white70),
                    ),
                    SizedBox(height: 6.h),
                    Container(
                      width: 80.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(
                            isSelected ? 1.0 : 0.3),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 50.w,
              padding: EdgeInsets.only(right: 12.w),
              alignment: Alignment.center,
              child: isSelected
                  ? Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accentColor,
                      ),
                      child: Icon(Icons.check,
                          color: Colors.white, size: 20.sp),
                    )
                  : Container(
                      width: 28.w,
                      height: 28.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey[400]!,
                          width: 2.w,
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
