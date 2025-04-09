import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:petsymp/helpandsupport.dart';
import 'package:petsymp/historyassesment.dart';
import 'package:petsymp/termsandcondition.dart';
import 'homepage.dart';
import 'profile.dart';

class Settingscreen extends StatefulWidget {
  const Settingscreen({super.key});

  @override
  SettingscreenState createState() => SettingscreenState();
}

class SettingscreenState extends State<Settingscreen> {
  Map<String, Map<String, dynamic>> hashmap = {
    "img1": {
      "image": "assets/security.png",
      "screen": (BuildContext context) => const HomePageScreen(),
    },
    "img2": {
      "image": "assets/support.png",
      "screen": (BuildContext context) => const HelpandsupportScreen(),
    },
    "img3": {
      "image": "assets/condition.png",
      "screen": (BuildContext context) => const TermsandconditionScreen(),
    },
    "img4": {
      "image": "assets/editprofile.png",
      "screen": (BuildContext context) => const Profilescreen(),
    },
    "img5": {
      "image": "assets/restore.png",
      "screen": (BuildContext context) => const HistoryassesmentScreen(),
    },
    "img6": {
      "image": "assets/logout.png",
      "screen": (BuildContext context) => const HomePageScreen(),
    },
  };

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(29, 29, 44, 1.0),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: screenHeight * 0.09),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              // First Group
              _buildCardContainer([
                _buildInputCard("img1", "Security"),
                _buildInputCard("img2", "Help and Support"),
                _buildInputCard("img3", "Terms and Conditions", isLast: true),
              ]),

              SizedBox(height: 20.h),

              // Second Group
              _buildCardContainer([
                _buildInputCard("img4", "Edit Profile"),
                _buildInputCard("img5", "History"),
                _buildInputCard("img6", "Log out", isLast: true),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  // Container Wrapper
  Widget _buildCardContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(36, 36, 55, 1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(children: children),
    );
  }

  // Individual Card Builder
  Widget _buildInputCard(String index, String value, {bool isLast = false}) {
    return GestureDetector(
      onTap: () {
        if (hashmap.containsKey(index)) {
          var screenFunction = hashmap[index]!["screen"];
          if (screenFunction is Widget Function(BuildContext)) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => screenFunction(context)),
            );
          }
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: isLast
                ? BorderSide.none
                : const BorderSide(
                    color: Color.fromARGB(255, 142, 142, 142),
                    width: 0.4,
                  ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icon + Label
            Row(
              children: [
                Image.asset(
                  hashmap[index]!["image"],
                  width: 22.w,
                  height: 22.h,
                  fit: BoxFit.contain,
                  color: const Color.fromRGBO(82, 170, 164, 1),
                ),
                SizedBox(width: 14.w),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color.fromRGBO(82, 170, 164, 1),
                  ),
                ),
              ],
            ),

            // Arrow icon
            Icon(
              Icons.chevron_right,
              size: 20.sp,
              color: Colors.grey.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}
