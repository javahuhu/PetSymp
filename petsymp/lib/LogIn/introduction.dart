import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:petsymp/LogIn/login.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';


class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({super.key});

  @override
  IntroductionScreenState createState() => IntroductionScreenState();
}

class IntroductionScreenState extends State<IntroductionScreen> with TickerProviderStateMixin {
  
  int _activeIndex = 0;
  
  
final CarouselSliderController _carouselController = CarouselSliderController();


  @override
  void initState() {
    super.initState();
    
  }

  @override
  void dispose() {
    super.dispose();
  }

  
  final List<FeatureItem> _featureItems = [
    FeatureItem(
      image: 'assets/introductionimg/pettype.png',
      title: 'Pet Health Tracking',
      description: 'Monitor your pet\'s health with detailed analytics',
    ),
    FeatureItem(
      image: 'assets/introductionimg/petimage.png',
      title: 'Vet Appointments',
      description: 'Schedule vet visits with just a few taps',
    ),
    FeatureItem(
      image: 'assets/introductionimg/basicinfo.png',
      title: 'Pet Community',
      description: 'Connect with other pet owners near you',
    ),
    FeatureItem(
      image: 'assets/introductionimg/symptoms.png',
      title: 'Pet Reminders',
      description: 'Never miss an important pet care task',
    ),
    FeatureItem(
      image: 'assets/introductionimg/searchsymptoms.png',
      title: 'Pet Reminders',
      description: 'Never miss an important pet care task',
    ),
    FeatureItem(
      image: 'assets/introductionimg/listsymptoms.png',
      title: 'Pet Reminders',
      description: 'Never miss an important pet care task',
    ),
    FeatureItem(
      image: 'assets/introductionimg/summary.png',
      title: 'Pet Reminders',
      description: 'Never miss an important pet care task',
    ),
     FeatureItem(
      image: 'assets/introductionimg/illnessinfo.png',
      title: 'Pet Reminders',
      description: 'Never miss an important pet care task',
    ),
    FeatureItem(
      image: 'assets/introductionimg/disclaimer.png',
      title: 'Pet Reminders',
      description: 'Never miss an important pet care task',
    ),
     FeatureItem(
      image: 'assets/introductionimg/saved.png',
      title: 'Pet Reminders',
      description: 'Never miss an important pet care task',
    ),
    FeatureItem(
      image: 'assets/introductionimg/petprofile.png',
      title: 'Pet Reminders',
      description: 'Never miss an important pet care task',
    ),
    
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          
          CarouselSlider.builder(
            carouselController: _carouselController,
            itemCount: _featureItems.length,
            options: CarouselOptions(
              height: MediaQuery.of(context).size.height,
              viewportFraction: 1.0, 
              enlargeCenterPage: false,
              enableInfiniteScroll: false, 
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 4),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              onPageChanged: (index, reason) {
                setState(() {
                  _activeIndex = index;
                });
              },
            ),
            itemBuilder: (context, index, realIndex) {
              return _buildCarouselBackground(_featureItems[index]);
            },
          ),

        
         
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               
                
                Expanded(child: Container()), 
                
              
                Center(
                  child: AnimatedSmoothIndicator(
                    activeIndex: _activeIndex,
                    count: _featureItems.length,
                    effect: WormEffect(
                      dotHeight: 8.h,
                      dotWidth: 8.w,
                      activeDotColor: const Color.fromRGBO(66, 134, 130, 1.0),
                      dotColor: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                    ),
                  ),
                ),
                
                SizedBox(height: 0.03.sh),
                
                  Center(
                    child: TextButton(
                      onPressed: () {
                         Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(Colors.transparent), 
                    shadowColor: MaterialStateProperty.all(Colors.transparent),  
                  ),

                      child: Text(
                        "Proceed",
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.w500,
                        ),
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

  // Helper method to build a carousel background
  Widget _buildCarouselBackground(FeatureItem item) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Image.asset(
        item.image,
        fit: BoxFit.cover,
      ),
    );
  }
}

// Data class for feature carousel items
class FeatureItem {
  final String image;
  final String title;
  final String description;

  FeatureItem({
    required this.image,
    required this.title,
    required this.description,
  });
}
