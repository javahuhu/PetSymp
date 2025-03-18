import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:petsymp/homepage.dart';
import 'package:petsymp/profile.dart';
import 'package:provider/provider.dart';
import 'userdata.dart';
import 'package:url_launcher/url_launcher.dart';

class NewSummaryScreen extends StatefulWidget {
  const NewSummaryScreen({super.key});

  @override
  NewSummaryScreenState createState() => NewSummaryScreenState();
}

class NewSummaryScreenState extends State<NewSummaryScreen> {
  final List<ListItem> items = [
    const ListItem(
        title: 'Provide Medicine for Lethargy',
        subtitle: 'techniques on how can dog drink a vitamins quickly',
        route: HomePageScreen(),
        isExternal: false,
        imageUrl: 'assets/youtube1.jpg'),
    const ListItem(
        title: 'How to Easily Give Your Pet Medicine Without Stress!',
        subtitle:
            "Learn simple and stress-free techniques to give your pet medicine, whether it's a pill, liquid, or injection, ensuring their health and comfort",
        route: Profilescreen(),
        isExternal: false,
        imageUrl: 'assets/youtube1.jpg'),
    const ListItem(
        title: 'ricks to Give Your Pet Medicine Without a Fight!',
        subtitle:
            'Discover easy and effective ways to give your pet medicine without stress, making it a smooth experience for both of you.',
        url:
            'https://www.youtube.com/results?search_query=flutter+list+with+images',
        isExternal: true,
        imageUrl: 'assets/youtube1.jpg'),
    const ListItem(
        title: 'How to Hide Medicine in Treats for Your Pet!',
        subtitle:
            'Learn sneaky yet safe ways to hide pills in treats and food so your pet takes their medicine without even noticing.',
        route: HomePageScreen(),
        isExternal: false,
        imageUrl: 'assets/youtube1.jpg'),
    const ListItem(
        title: 'The Right Way to Give Your Pet Liquid Medicine!',
        subtitle:
            "Master the best techniques to give your pet liquid medicine without mess or resistance.",
        route: Profilescreen(),
        isExternal: false,
        imageUrl: 'assets/youtube1.jpg'),
  ];

  @override
  Widget build(BuildContext context) {
    final List<Color> containerColors =
        List.filled(10, const Color.fromRGBO(29, 29, 44, 1.0));

    String truncateText(String text, int maxLength) {
      if (text.length <= maxLength) {
        return text;
      }
      return text.substring(0, maxLength) + "...";
    }

    final userData = Provider.of<UserData>(context);

    String allSymptoms = truncateText(
        {
          if (userData.selectedSymptom.isNotEmpty) userData.selectedSymptom,
          if (userData.anotherSymptom.isNotEmpty) userData.anotherSymptom,
          ...userData.petSymptoms.where((symptom) => symptom.isNotEmpty),
        }.join(" + "),
        20);


        final List<Map<String, String>> petDetails = [
          {"icon": "🎂", "label": "Age", "value": userData.age.toString()},
          {"icon": "📏", "label": "Size", "value": userData.size.toString()},
          {"icon": "🐶", "label": "Breed", "value": userData.breed},
          {"icon": "☣️", "label": "Symptoms", "value": allSymptoms},
        ];


    return Scaffold(
      backgroundColor: const Color(0xFFE8F2F5),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // **Month Title**
            SizedBox(height: 25.h),
            const Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                "March, 2025",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // **Horizontal Date List**
            Padding(
              padding: EdgeInsets.only(top: 15.h),
              child: SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: containerColors.length,
                  itemBuilder: (context, index) {
                    Border borderstyle = index == 2
                        ? Border.all(
                            color: const Color.fromARGB(255, 255, 0, 0),
                            width: 4)
                        : Border.all(color: const Color.fromARGB(255, 0, 0, 0));
                    return Container(
                      width: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: containerColors[index],
                        borderRadius: BorderRadius.circular(100),
                        border: borderstyle,
                      ),
                      child: Center(
                        child: Text(
                          "${index + 1}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            SizedBox(
              height: 0.h,
            ),

            // **Fix: Wrap Stack Inside a SizedBox**
            SizedBox(
              height: 450.h, // 🔥 Ensure Stack has a fixed height
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // **Circular Image**
                  Positioned(
                    left: 10.w,
                    top: 100.h,
                    child: Container(
                      height: 250.w,
                      width: 250.w,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color.fromARGB(255, 255, 0, 0),
                            width: 5),
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: Image.asset("assets/sampleimage.jpg",
                            fit: BoxFit.cover),
                      ),
                    ),
                  ),

                  // **Top Right Progress Indicator (Blue)**
                  Positioned(
                    right: 15.w,
                    top: 58.h,
                    child: SizedBox(
                      width: 150.w, // Controls the outer size
                      height: 150.w,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 70.w, // Explicitly set width & height
                            height: 70.w,
                            child: CircularProgressIndicator(
                              value: 0.90, // Example progress
                              backgroundColor: Colors.grey,
                              color: const Color.fromARGB(255, 239, 0, 0),
                              strokeWidth: 7.w, // Make it thicker
                            ),
                          ),
                          Text(
                            "90%", // Centered text
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // **Middle Right Progress Indicator (Green)**
                  Positioned(
                    right: -15.w,
                    top: 145.h,
                    child: SizedBox(
                      width: 150.w, // Controls the outer size
                      height: 150.w,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 70.w, // Explicitly set width & height
                            height: 70.w,
                            child: CircularProgressIndicator(
                              value: 0.50, // Example progress
                              backgroundColor: Colors.grey,
                              color: const Color.fromARGB(255, 13, 253, 0),
                              strokeWidth: 7.w, // Make it thicker
                            ),
                          ),
                          Text(
                            "50%", // Centered text
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // **Bottom Right Progress Indicator (Red)**
                  Positioned(
                    right: 15.w,
                    top: 235.h,
                    child: SizedBox(
                      width: 150.w, // Controls the outer size
                      height: 150.w,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 70.w, // Explicitly set width & height
                            height: 70.w,
                            child: CircularProgressIndicator(
                              value: 0.75, // Example progress
                              backgroundColor: Colors.grey,
                              color: const Color.fromARGB(255, 232, 135, 44),
                              strokeWidth: 7.w, // Make it thicker
                            ),
                          ),
                          Text(
                            "75%", // Centered text
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 Pet Details Section (Scrollable List)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: Stack(
                clipBehavior:
                    Clip.none, // ✅ Ensures animation does not get clipped
                children: [
                  // 🔥 Lottie Background Animation (Fixed)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 25.h, // ✅ Adjust this value to push animation down
                    child: SizedBox(
                      // ✅ Adjust height as needed
                      child: Lottie.asset(
                        'assets/wavy.json', // ✅ Replace with your Lottie animation
                        fit: BoxFit.cover,
                        repeat: true,
                      ),
                    ),
                  ),

                  // 🔹 Foreground Content (Pet Details)
                  Container(
                    padding: EdgeInsets.all(10.w),
                    width: double.infinity,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: petDetails.map((detail) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30.w),
                            child: SizedBox(
                              height: 90.h,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // 🔹 Label (Light Color)
                                  Text(
                                    detail["label"]!,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  ),

                                  // 🔹 Value (Bold)
                                  Text(
                                    detail["value"]!,
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          const Color.fromRGBO(29, 29, 44, 1.0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(vertical: 0.h),
              child: ExpansionTile(
                title: const Text(
                  'Illness Pet Result',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.normal),
                ),
                children: [
                  //progress indicator 1//
                  Padding(
                    padding: EdgeInsets.only(right: 200.w, top: 15.h),
                    child: SizedBox(
                      width: 150.w, // Controls the outer size
                      height: 200.w,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 110.w, // Explicitly set width & height
                            height: 110.w,
                            child: CircularProgressIndicator(
                              value: 0.90, // Example progress
                              backgroundColor: Colors.grey,
                              color: const Color.fromARGB(255, 255, 0, 0),
                              strokeWidth: 10.w, // Make it thicker
                            ),
                          ),
                          Text(
                            "90%", // Centered text
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 170.h),
                            child: Text("Acidic",
                                style: TextStyle(
                                    fontSize: 22.sp,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(top: 5.h),
                    child: SizedBox(
                      width: 350.w, // Ensure width is fixed
                      child: Text(
                        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. In vitae accumsan leo, quis pretium turpis. Phasellus laoreet libero vitae mauris fermentum, in imperdiet diam laoreet. Aenean odio metus, tempor a mattis non, pretium at mauris.",
                        softWrap:
                            true, // ✅ Allows text wrapping // ✅ Adds "..." if too long
                        style: TextStyle(
                          fontSize: 18.sp, // ✅ Keeps font size consistent
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                          fontFamily:
                              'Inter', // ✅ Must match 'family' in pubspec.yaml
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(top: 5.h),
                    child: SizedBox(
                      width: 350.w, // Ensure width is fixed
                      child: Text(
                        "Duis eleifend elementum sapien, eget pulvinar elit ultrices id. Aliquam imperdiet velit id tempor ullamcorper. Quisque aliquam et lacus id efficitur. Sed molestie justo cursus lobortis tempor.",
                        softWrap: true, // ✅ Allows text wrapping
                        style: TextStyle(
                          fontSize: 18.sp, // ✅ Keeps font size consistent
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                          fontFamily:
                              'Inter', // ✅ Must match 'family' in pubspec.yaml
                        ),
                      ),
                    ),
                  ),

//progress indicator 2///////////////////////////////////////

                  Padding(
                    padding: EdgeInsets.only(right: 200.w, top: 15.h),
                    child: SizedBox(
                      width: 150.w, // Controls the outer size
                      height: 200.w,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 110.w, // Explicitly set width & height
                            height: 110.w,
                            child: CircularProgressIndicator(
                              value: 0.5, // Example progress
                              backgroundColor: Colors.grey,
                              color: Colors.blue,
                              strokeWidth: 10.w, // Make it thicker
                            ),
                          ),
                          Text(
                            "50%", // Centered text
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 170.h),
                            child: Text("Lethargy",
                                style: TextStyle(
                                    fontSize: 22.sp,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(top: 5.h),
                    child: SizedBox(
                      width: 350.w, // Ensure width is fixed
                      child: Text(
                        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. In vitae accumsan leo, quis pretium turpis. Phasellus laoreet libero vitae mauris fermentum, in imperdiet diam laoreet. Aenean odio metus, tempor a mattis non, pretium at mauris.",
                        softWrap:
                            true, // ✅ Allows text wrapping // ✅ Adds "..." if too long
                        style: TextStyle(
                          fontSize: 18.sp, // ✅ Keeps font size consistent
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                          fontFamily:
                              'Inter', // ✅ Must match 'family' in pubspec.yaml
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(top: 5.h),
                    child: SizedBox(
                      width: 350.w, // Ensure width is fixed
                      child: Text(
                        "Duis eleifend elementum sapien, eget pulvinar elit ultrices id. Aliquam imperdiet velit id tempor ullamcorper. Quisque aliquam et lacus id efficitur. Sed molestie justo cursus lobortis tempor.",
                        softWrap: true, // ✅ Allows text wrapping
                        style: TextStyle(
                          fontSize: 18.sp, // ✅ Keeps font size consistent
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                          fontFamily:
                              'Inter', // ✅ Must match 'family' in pubspec.yaml
                        ),
                      ),
                    ),
                  ),

//progress indicator 3////////////////////////////////////////////////////////

                  Padding(
                    padding: EdgeInsets.only(right: 200.w, top: 15.h),
                    child: SizedBox(
                      width: 150.w, // Controls the outer size
                      height: 200.w,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 110.w, // Explicitly set width & height
                            height: 110.w,
                            child: CircularProgressIndicator(
                              value: 0.75, // Example progress
                              backgroundColor: Colors.grey,
                              color: const Color.fromARGB(255, 255, 145, 0),
                              strokeWidth: 10.w, // Make it thicker
                            ),
                          ),
                          Text(
                            "75%", // Centered text
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 170.h),
                            child: Text("Vomiting",
                                style: TextStyle(
                                    fontSize: 22.sp,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(top: 5.h),
                    child: SizedBox(
                      width: 350.w, // Ensure width is fixed
                      child: Text(
                        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. In vitae accumsan leo, quis pretium turpis. Phasellus laoreet libero vitae mauris fermentum, in imperdiet diam laoreet. Aenean odio metus, tempor a mattis non, pretium at mauris.",
                        softWrap:
                            true, // ✅ Allows text wrapping // ✅ Adds "..." if too long
                        style: TextStyle(
                          fontSize: 18.sp, // ✅ Keeps font size consistent
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                          fontFamily:
                              'Inter', // ✅ Must match 'family' in pubspec.yaml
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(top: 5.h),
                    child: SizedBox(
                      width: 350.w, // Ensure width is fixed
                      child: Text(
                        "Duis eleifend elementum sapien, eget pulvinar elit ultrices id. Aliquam imperdiet velit id tempor ullamcorper. Quisque aliquam et lacus id efficitur. Sed molestie justo cursus lobortis tempor.",
                        softWrap: true, // ✅ Allows text wrapping
                        style: TextStyle(
                          fontSize: 18.sp, // ✅ Keeps font size consistent
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                          fontFamily:
                              'Inter', // ✅ Must match 'family' in pubspec.yaml
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 50.h,
                  )
                ],
              ),
            ),

            ///Recommendation//////////
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15.h),
              child: ExpansionTile(
                title: const Text(
                  'Recommendations',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.normal),
                ),
                children: [
                  // 🔹 Wrap in ConstrainedBox for controlled height
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 300.h, // ✅ Limits height to enable scrolling
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: items.map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 10),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(8),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  item.imageUrl,
                                  width: 80.w, // Adjusted width
                                  height: 80.h, // Adjusted height
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(
                                item.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color.fromRGBO(66, 134, 130, 1.0),
                                ),
                              ),
                              subtitle: Text(
                                item.subtitle,
                                style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Color.fromRGBO(29, 29, 44, 1.0),
                                ),
                              ),
                              onTap: () async {
                                if (item.isExternal) {
                                  await _launchURL(item.url!);
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => item.route!),
                                  );
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // put the code here gpt//
          ],
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

class ListItem {
  final String title;
  final String subtitle;
  final Widget? route;
  final String? url;
  final bool isExternal;
  final String imageUrl;

  const ListItem({
    required this.title,
    this.route,
    this.url,
    required this.isExternal,
    required this.imageUrl,
    required this.subtitle,
  });
}
