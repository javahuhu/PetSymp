import 'package:flutter/material.dart';
import 'package:petsymp/homepage.dart';
import 'package:petsymp/profile.dart';
import 'package:petsymp/recommendationtwo.dart';
import 'package:url_launcher/url_launcher.dart';

class RecommendationoneScreen extends StatefulWidget {
  const RecommendationoneScreen({super.key});

  @override
  RecommendationoneScreenState createState() => RecommendationoneScreenState();
}

class RecommendationoneScreenState extends State<RecommendationoneScreen> {
  bool _isAnimated = false;
  int _selectedIndex = 0;
  final List<bool> _buttonVisible = [false, false, false, false, false, false];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _isAnimated = true;
      });
      for (int i = 0; i < _buttonVisible.length; i++) {
        Future.delayed(Duration(milliseconds: 300 * i), () {
          setState(() {
            _buttonVisible[i] = true;
          });
        });
      }
    });
  }

  static const List<Widget> _pages = <Widget>[
    Icon(Icons.home, size: 150),
    Icon(Icons.person, size: 150),
    Icon(Icons.settings, size: 150),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<ListItem> items = [
    const ListItem(
        title: 'Go to 1',
        route: HomePageScreen(),
        isExternal: false,
        imageUrl: 'assets/pethiscatttt.jpg'),
    const ListItem(
        title: 'Go to 2',
        route: Profilescreen(),
        isExternal: false,
        imageUrl: 'assets/catanddog.jpg'),
    const ListItem(
        title: 'Open YouTube',
        url: 'https://www.youtube.com/results?search_query=how+to+make+a+list+with+images+beside+at+flutter',
        isExternal: true,
        imageUrl: 'assets/dogshock.png'),

    const ListItem(
        title: 'Go to 3',
        route: HomePageScreen(),
        isExternal: false,
        imageUrl: 'assets/pethiscatttt.jpg'),
    const ListItem(
        title: 'Go to 4',
        route: Profilescreen(),
        isExternal: false,
        imageUrl: 'assets/catanddog.jpg'),
    const ListItem(
        title: 'Open YouTube',
        url: 'https://www.youtube.com/results?search_query=how+to+make+a+list+with+images+beside+at+flutter',
        isExternal: true,
        imageUrl: 'assets/dogshock.png'),

    const ListItem(
        title: 'Go to 5',
        route: HomePageScreen(),
        isExternal: false,
        imageUrl: 'assets/pethiscatttt.jpg'),
    const ListItem(
        title: 'Go to 6',
        route: Profilescreen(),
        isExternal: false,
        imageUrl: 'assets/catanddog.jpg'),
    const ListItem(
        title: 'Open YouTube',
        url: 'https://www.youtube.com/results?search_query=how+to+make+a+list+with+images+beside+at+flutter',
        isExternal: true,
        imageUrl: 'assets/dogshock.png'),
  ];

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFCFCFCC),
      body: Stack(
        children: [
          if (_selectedIndex == 0)
            Stack(
              children: [
                Positioned(
                  top: screenHeight * 0.03,
                  left: screenWidth * 0.01,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isAnimated = false;
                        _buttonVisible.fillRange(0, _buttonVisible.length, false);
                      });
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
                  top: _isAnimated ? screenHeight * 0.13 : -100,
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
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.2,
                  left: screenWidth * 0.03,
                  child: SizedBox(
                    width: screenWidth * 0.95,
                    height: screenHeight * 0.68,
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white, // Background color for each tile
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 5,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
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
                                style: const TextStyle(fontWeight: FontWeight.bold),
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
                  screenHeight * 1.105, screenWidth, 0.8, "Proceed", const RecommendationtwoScreen(), 1,
                ),
              ],
            ),
          if (_selectedIndex != 0)
            Center(
              child: _pages.elementAt(_selectedIndex),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromRGBO(61, 47, 40, 1),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget buildAnimatedButton(double screenHeight, double screenWidth,
      double topPosition, String label, Widget destination, int index) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      top: _buttonVisible[index] ? screenHeight * topPosition : screenHeight,
      left: screenWidth * 0.45 - 50,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _isAnimated = false;
          });
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
              return const Color.fromRGBO(61, 47, 40, 1);
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
              color: Colors.black,
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
  });
}
