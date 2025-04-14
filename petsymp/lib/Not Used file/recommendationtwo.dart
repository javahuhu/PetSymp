import 'package:flutter/material.dart';
import 'package:petsymp/HomePage/homepage.dart';
import 'package:petsymp/HomePage/profile.dart';
import 'package:url_launcher/url_launcher.dart';

class RecommendationtwoScreen extends StatefulWidget {
  const RecommendationtwoScreen({super.key});

  @override
  RecommendationtwoScreenState createState() => RecommendationtwoScreenState();
}

class RecommendationtwoScreenState extends State<RecommendationtwoScreen> {
  bool _isAnimated = false;
  final List<bool> _buttonVisible = [false, false, false, false, false, false];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _triggerAnimation();
  }

  void _triggerAnimation() {
    setState(() {
      _isAnimated = false;
      _buttonVisible.fillRange(0, _buttonVisible.length, false);
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _isAnimated = true;
      });

      for (int i = 0; i < _buttonVisible.length; i++) {
        Future.delayed(Duration(milliseconds: 300 * i), () {
          if (mounted) {
            setState(() {
              _buttonVisible[i] = true;
            });
          }
        });
      }
    });
  }

  

  final List<ListItem> items = [
    const ListItem(
        title: 'Provide Medicine for Lethargy',
        subtitle: 'techniques on how can dog drink a vitamins quickly',
        route: HomePageScreen(),
        isExternal: false,
        imageUrl: 'assets/youtube1.jpg'),
    const ListItem(
        title: 'How to Easily Give Your Pet Medicine Without Stress!',
         subtitle: "Learn simple and stress-free techniques to give your pet medicine, whether it's a pill, liquid, or injection, ensuring their health and comfort",
        route: Profilescreen(),
        isExternal: false,
        imageUrl: 'assets/youtube1.jpg'),
    const ListItem(
        title: 'ricks to Give Your Pet Medicine Without a Fight!',
         subtitle: 'Discover easy and effective ways to give your pet medicine without stress, making it a smooth experience for both of you.',
        url: 'https://www.youtube.com/results?search_query=flutter+list+with+images',
        isExternal: true,
        imageUrl: 'assets/youtube1.jpg'),


    const ListItem(
        title: 'How to Hide Medicine in Treats for Your Pet!',
        subtitle: 'Learn sneaky yet safe ways to hide pills in treats and food so your pet takes their medicine without even noticing.',
        route: HomePageScreen(),
        isExternal: false,
        imageUrl: 'assets/youtube1.jpg'),
    const ListItem(
        title: 'The Right Way to Give Your Pet Liquid Medicine!',
         subtitle: "Master the best techniques to give your pet liquid medicine without mess or resistance.",
        route: Profilescreen(),
        isExternal: false,
        imageUrl: 'assets/youtube1.jpg'),
    
  ];

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFE8F2F5),
      body: Stack(
        children: [
         
            Stack(
              children: [
                Positioned(
                  top: screenHeight * 0.03,
                  left: screenWidth * 0.01,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.arrow_back_sharp,
                      color: Color.fromRGBO(61, 47, 40, 1),
                      size: 40.0,
                    ),
                    label: const Text(''),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  top: _isAnimated ? screenHeight * 0.09 : -100,
                  left: screenWidth * 0.1,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: screenWidth * 0.15,
                        height: screenWidth * 0.15,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: Image.asset(
                          'assets/paw.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.05),
                      Padding(
                        padding: EdgeInsets.only(top: screenHeight * 0.03),
                        child: const Text(
                          "Recommendation",
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(29, 29, 44, 1.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.17,
                  left: screenWidth * 0.03,
                  child: SizedBox(
                    width: screenWidth * 0.95,
                    height: screenHeight * 0.64,
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(0, 255, 255, 255), // Background color for each tile
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(5),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  items[index].imageUrl,
                                  width: 100, // Image width
                                  height: 100, // Image height
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(
                                items[index].title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20 ,color: Color.fromRGBO(66, 134, 130, 1.0)),
                              ),

                              subtitle: Text(
                                items[index].subtitle,
                                style: const TextStyle(fontWeight: FontWeight.normal, color: Color.fromRGBO(29, 29, 44, 1.0)),
                              ),

                              
                              onTap: () async {
                                if (items[index].isExternal) {
                                  await _launchURL(items[index].url!);
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => items[index].route!),
                                  );
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                buildAnimatedButton(
                  screenHeight * 1.07, screenWidth, 0.85, "Finish", const HomePageScreen(), 1,
                ),
              ],
            ),
         
        ],
      ),
      
    );
  }

  Widget buildAnimatedButton(double screenHeight, double screenWidth,
      double topPosition, String label, Widget destination, int index) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      top: _buttonVisible[index] ? screenHeight * topPosition : screenHeight,
      left: screenWidth * 0.44 - 50,
      child: ElevatedButton(
        onPressed: () {
         
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        },
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) {
              if (states.contains(WidgetState.pressed)) {
                return const Color.fromARGB(255, 255, 255, 255);
              }
              return const Color.fromRGBO(29, 29, 44, 1.0);
            },
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) {
              if (states.contains(WidgetState.pressed)) {
                return const Color.fromARGB(255, 0, 0, 0);
              }
              return const Color.fromARGB(255, 255, 255, 255);
            },
          ),
          shadowColor: WidgetStateProperty.all(Colors.transparent),
          side: WidgetStateProperty.all(
            const BorderSide(
              color: Color.fromRGBO(82, 170, 164, 0),
              width: 2.0,
            ),
          ),
          shape: WidgetStateProperty.all(
            const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(100)),
            ),
          ),
          fixedSize: WidgetStateProperty.all(
            const Size(155, 55),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
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
