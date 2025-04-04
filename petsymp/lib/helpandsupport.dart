import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HelpandsupportScreen extends StatefulWidget {
  const HelpandsupportScreen({super.key});

  @override
  HelpandsupportScreenState createState() => HelpandsupportScreenState();
}

class HelpandsupportScreenState extends State<HelpandsupportScreen> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true, 
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
         appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 219, 230, 233),
        elevation: 0,
        automaticallyImplyLeading: false,
        title:  Padding(padding: EdgeInsets.only(left:85.5.w),child:   Text(
                "Help and Support",
                style: TextStyle(
                  fontSize: 25.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Oswald',
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              )),
      ), // Lighter background for better contrast
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 25.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 25.h),
                
                // FAQ expandable cards
                _buildExpandableCard(
                  title: "1. Can PetSymp diagnose my pet's illness?",
                  icon: Icons.medical_services,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "PetSymp is not a replacement for professional veterinary care. The app provides educational information based on your pet's symptoms to help you better understand potential issues, but only a licensed veterinarian can provide a proper diagnosis.",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 127, 127, 127),
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 10.h),
                
                _buildExpandableCard(
                  title: "2. Why does the app ask follow-up questions?",
                  icon: Icons.question_answer,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Follow-up questions help our system narrow down the potential issues affecting your pet. Just like a veterinarian would ask specific questions during an exam, these additional queries provide more detailed information about your pet's condition.",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 127, 127, 127),
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 10.h),
                
                _buildExpandableCard(
                  title: "3. What if my pet's symptom is not listed?",
                  icon: Icons.search_off,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "If you don't see your pet's specific symptom, select the closest match or use the 'Other' option when available. For symptoms not covered by the app, we recommend consulting with a veterinarian directly, especially if your pet appears to be in distress.",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 127, 127, 127),
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 10.h),
                
                _buildExpandableCard(
                  title: "4. Can I track my pet's past assessments?",
                  icon: Icons.history,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Yes, PetSymp keeps a record of all your previous symptom assessments. You can access your pet's health history in the 'History' section of the app. This feature helps you monitor your pet's health over time and share valuable information with your veterinarian when needed.",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 127, 127, 127),
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10.h),

                _buildExpandableCard(
                  title: "5. Does the app work for all breeds and ages?",
                  icon: Icons.pets,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "PetSymp is designed to work with cats and dogs of all breeds and ages. However, different breeds and age groups may have specific health considerations. The app takes these factors into account when analyzing symptoms, but always consult with a veterinarian for breed-specific or age-related concerns, especially for very young, senior, or pregnant pets.",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 127, 127, 127),
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10.h),

                _buildExpandableCard(
                  title: "6. Can I share my pet's results with my vet?",
                  icon: Icons.share,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Absolutely! PetSymp makes it easy to share your pet's symptom assessment with your veterinarian. Simply tap the 'Share' button on any completed assessment to generate a detailed report that can be sent via email, text, or saved as a PDF. This information can help your vet understand your pet's symptoms and changes over time.",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 127, 127, 127),
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10.h),

                _buildExpandableCard(
                  title: "7. How accurate are the results?",
                  icon: Icons.analytics,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "PetSymp uses advanced algorithms developed with veterinary professionals to analyze symptoms and provide educational information. The accuracy depends on the symptoms entered and the available data. While our system is continuously improving with machine learning, it's important to remember that no app can replace a hands-on examination by a qualified veterinarian. Always consult a professional for definitive diagnoses.",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 127, 127, 127),
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10.h),

                _buildExpandableCard(
                  title: "8. Can I assess multiple pets?",
                  icon: Icons.group,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Yes, PetSymp supports multiple pet profiles. You can add and manage several pets within the app, each with their own profile, medical history, and symptom assessments. This feature is perfect for households with multiple pets, allowing you to keep track of each animal's health separately and maintain organized records for all your furry family members.",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 127, 127, 127),
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // Method to build expandable cards
  Widget _buildExpandableCard({
    required String title,
    required IconData icon,
    required Widget content,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
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
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          shadowColor: Colors.transparent, // Remove shadow effect
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: ExpansionTile(
            backgroundColor: Colors.white,
            collapsedBackgroundColor: Colors.white, // Keep consistent background when collapsed
            leading: Icon(
              icon,
              color: const Color(0xFF52AAA4),
            ),
            title: Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
                color: const Color(0xFF3D4A5C),
              ),
            ),
            initiallyExpanded: false,
            childrenPadding: EdgeInsets.all(15.w),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h), // More consistent padding
            maintainState: true, // Maintain widget state when collapsed
            children: [
              content,
            ],
          ),
      ),
    ));
  }
}