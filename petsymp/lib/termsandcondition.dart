import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TermsandconditionScreen extends StatefulWidget {
  const TermsandconditionScreen({super.key});

  @override
  TermsandconditionScreenState createState() => TermsandconditionScreenState();
}

class TermsandconditionScreenState extends State<TermsandconditionScreen> {
  String nickname = "Loading...";
  String email = "Loading...";

  final Map<String, Map<String, String>> profilelist = {
    "img1": {
      "profile": "assets/profile.jpg",
      "image": "assets/security.png",
    },
    "img2": {
      "image": "assets/support.png",
    },
    "img3": {
      "image": "assets/condition.png",
    },
    "img4": {
      "image": "assets/editprofile.png",
    },
    "img5": {
      "image": "assets/restore.png",
    },
  };

 


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 219, 230, 233),
      body: SafeArea(
        child: SingleChildScrollView(

          child: Padding(
            padding: EdgeInsets.all(0.w),
            child: Column(
              
              children: [

  Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon:  Icon(
                  Icons.arrow_back_sharp,
                  size: 30.sp,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              SizedBox(width:  50.w),
              Text(
                "Terms and Condition",
                style: TextStyle(
                  fontSize: 25.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Oswald',
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ],
          ),
          

         Padding(
  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 50.h), // responsive left/right padding
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start, // ⬅️ aligns text to the left
    children: [
      Text(
        "Welcome!",
        style: TextStyle(fontFamily: 'Inter', fontSize: 35.sp, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 25.h),
      Text(
        "These Terms and Conditions ('Terms') govern your use of the PetSymp mobile application and services. By accessing or using PetSymp, you agree to these Terms. If you do not agree, please do not use the app.",
        style: TextStyle(fontFamily: 'Inter', fontSize: 13.sp),
      ),
     
    ],
  ),
),


 Padding(
  padding: EdgeInsets.only(left: 50.w, right: 20.w), // responsive left/right padding
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start, // ⬅️ aligns text to the left
    children: [
      Text(
        "Acceptance of Terms",
        style: TextStyle(fontFamily: 'Inter', fontSize: 18.sp, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 5.h),
      Text(
        "By using PetSymp, you confirm that you have read, understood, and agree to comply with these Terms.",
        style: TextStyle(fontFamily: 'Inter', fontSize: 13.sp),
      ),

       SizedBox(height: 25.h),


      Text(
        "Description of Service",
        style: TextStyle(fontFamily: 'Inter', fontSize: 18.sp, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 5.h),
      Text(
        "PetSymp provides symptom analysis for pets based on user input. The app generates possible conditions and follow-up questions to refine the assessment. PetSymp does not provide medical diagnoses and should not replace professional veterinary advice.",
        style: TextStyle(fontFamily: 'Inter', fontSize: 13.sp),
      ),

       SizedBox(height: 25.h),
      Text(
        "User Responsibilities",
        style: TextStyle(fontFamily: 'Inter', fontSize: 18.sp, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 5.h),
      Text(
        "By using PetSymp, you agree to:",
        style: TextStyle(fontFamily: 'Inter', fontSize: 13.sp),
      ),

       SizedBox(height: 20.h),
      Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Icon(
      Icons.arrow_forward,
      size: 20.sp,
      color: Colors.black,
    ),
    SizedBox(width: 8.w), // spacing between icon and text
    Flexible(
      child: Text(
        "Provide accurate and truthful symptom information.",
        style: TextStyle(fontFamily: 'Inter', fontSize: 13.sp),
      ),
    ),


  ],
),


 SizedBox(height: 15.h),
 Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
  

    Icon(
      Icons.arrow_forward,
      size: 20.sp,
      color: Colors.black,
    ),
    SizedBox(width: 8.w), // spacing between icon and text
    Flexible(
      child: Text(
        "Use the app only for personal, non-commercial purposes.",
        style: TextStyle(fontFamily: 'Inter', fontSize: 13.sp),
      ),
    ),


  ],
),




 SizedBox(height: 15.h),
 Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
  

    Icon(
      Icons.arrow_forward,
      size: 20.sp,
      color: Colors.black,
    ),
    SizedBox(width: 8.w), // spacing between icon and text
    Flexible(
      child: Text(
        "Acknowledge that results are for informational purposes only and consult a veterinarian for medical concerns.",
        style: TextStyle(fontFamily: 'Inter', fontSize: 13.sp),
      ),
    ),


  ],
),


 SizedBox(height: 30.h),


  ],
  ),
)

          

              ],
            ),
          ),
        ),
      ),
    );
  }

}
