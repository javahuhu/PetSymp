import 'package:flutter/material.dart';
import 'package:petsymp/recommendationone.dart';
import 'userdata.dart';
import 'package:provider/provider.dart';
import 'profile.dart';
import 'package:percent_indicator/percent_indicator.dart';
class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  SummaryScreenState createState() => SummaryScreenState();
}

class SummaryScreenState extends State<SummaryScreen> {
  bool _isAnimated = false;
  int _selectedIndex = 0;
  bool isHovering = false;

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
    Profilescreen(),
    Icon(Icons.settings, size: 150),
  ];


  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final userData = Provider.of<UserData>(context);
    String allSymptoms = [
  if (userData.selectedSymptom.isNotEmpty) userData.selectedSymptom, 
  if (userData.anotherSymptom.isNotEmpty) userData.anotherSymptom
  ].where((element) => element.isNotEmpty).join(" + ");

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 233, 233, 232),
      body: Stack(
        children: [
          if (_selectedIndex == 0)
            Stack(
              children: [
               
                

                // 🟡 Yellow Background - Positioned **Above the Bones**
                Positioned(
                  top: 0, // Set at the **topmost** of the screen
                  left: 0,
                  right: 0,
                  child: Container(
                    width: screenWidth,
                    height: screenHeight * 1.5,
                    decoration: const BoxDecoration(
                       gradient: LinearGradient(
              begin: Alignment.topCenter,  // Starts from top
              end: Alignment.bottomCenter, // Ends at bottom
              colors: [
                Color.fromRGBO(232, 242, 245, 1.0), // Light color (top)
                 Color.fromRGBO(95, 93, 93, 1) // Darker shade (bottom)
              ],
            ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(100.0),
                        bottomRight: Radius.circular(100.0),
                      ),
                    ),
                    
                  ),
                ),

                Positioned(
                  top: -screenHeight * 0.15, // Adjusted so it's below yellow background
                  left: -screenWidth * 0.2,
                  child: Image.asset(
                    'assets/bonesbg.png',
                    height: 700,
                    width: 750,
                    fit: BoxFit.contain,
                  ),
                ),

                 Positioned(
                  top: screenHeight * 0.3, // Adjusted so it's below yellow background
                  left: -screenWidth * 0.15,
                  child: Image.asset(
                    'assets/floatball.png',
                    height: 200,
                    width: 200,
                    fit: BoxFit.fill,
                  ),
                ), 

                Positioned(
                  top: screenHeight * 0.5, // Adjusted so it's below yellow background
                  left: screenWidth * 0.1,
                  child: Image.asset(
                    'assets/floatball.png',
                    height: 200,
                    width: 200,
                    fit: BoxFit.fill,
                  ),
                ), 

                Positioned(
                  top: screenHeight * 0.65, // Adjusted so it's below yellow background
                  left: -screenWidth * 0.06,
                  child: Image.asset(
                    'assets/floatball.png',
                    height: 200,
                    width: 200,
                    fit: BoxFit.fill,
                  ),
                ),

                Positioned(
                  top: screenHeight * 0.6, // Adjusted so it's below yellow background
                  left: screenWidth * 0.6,
                  child: Image.asset(
                    'assets/floatball.png',
                    height: 200,
                    width: 200,
                    fit: BoxFit.fill,
                  ),
                ),

                Positioned(
                  top: screenHeight * 0.73, // Adjusted so it's below yellow background
                  left: screenWidth * 0.3,
                  child: Image.asset(
                    'assets/floatball.png',
                    height: 200,
                    width: 200,
                    fit: BoxFit.fill,
                  ),
                ),

                Positioned(
                  top: screenHeight * 0.87, // Adjusted so it's below yellow background
                  left: screenWidth * 0.1,
                  child: Image.asset(
                    'assets/floatball.png',
                    height: 200,
                    width: 200,
                    fit: BoxFit.fill,
                  ),
                ),

                Positioned(
                  top: screenHeight * 0.8, // Adjusted so it's below yellow background
                  left: screenWidth * 0.8,
                  child: Image.asset(
                    'assets/floatball.png',
                    height: 200,
                    width: 200,
                    fit: BoxFit.fill,
                  ),
                ),

                Positioned(
                  top: screenHeight * 0.4, // Adjusted so it's below yellow background
                  left: screenWidth * 0.35,
                  child: Image.asset(
                    'assets/floatball.png',
                    height: 200,
                    width: 200,
                    fit: BoxFit.fill,
                  ),
                ), 

                Positioned(
                  top: screenHeight * 0.45, // Adjusted so it's below yellow background
                  left: screenWidth * 0.73,
                  child: Image.asset(
                    'assets/floatball.png',
                    height: 200,
                    width: 200,
                    fit: BoxFit.fill,
                  ),
                ), 

                // ⚫ Username Box - Positioned Above the Bones
                Positioned(
                  top: screenHeight * 0,
                  left: screenWidth * -0.00,
                  child: Container(
                    height:screenHeight * 0.25,
                    width: screenWidth * 1,
                    decoration: const BoxDecoration(
                      color:  Color.fromARGB(0, 255, 219, 88),
                      borderRadius:  BorderRadius.only(
                    bottomLeft: Radius.circular(100),
                    bottomRight: Radius.circular(100),
                  ),
                     
                    ),
                    child: Stack(
                      children: [
                        // 🐾 Paw Image Inside Yellow Background
                        Positioned(
                          top: screenHeight * 0.08,
                          left: screenWidth * 0.41,
                          child: AnimatedOpacity(
                            duration: const Duration(seconds: 1),
                            opacity: _isAnimated ? 1.0 : 0.0,
                            child: Container(
                              width: screenWidth * 0.2,
                              height: screenWidth * 0.2,
                              decoration: const BoxDecoration(shape: BoxShape.circle),
                              child: Image.asset('assets/paw.png', fit: BoxFit.contain),
                            ),
                          ),
                        ),

                        // 📌 "Summary of Input" Title Inside Yellow Background
                        Positioned(
                          top: screenHeight * 0.2,
                          left: screenWidth * 0.385,
                          child: const Text(
                            "Results",
                            style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(29, 29, 44, 1.0),
                            ),
                          ),
                        ),
                       
                      ],
                    ),
                    
                    
                    
                    
                   
                  ),
                ),

                Positioned(
                top: screenHeight * 0.36, // Centers it vertically
                left: screenWidth * 0.06 , // Centers it horizontally
                child: InkWell(
                  child: Container(
                    width: screenWidth * 0.43,
                    height: screenHeight * 0.248,
                    decoration:   const BoxDecoration(
                      color:   Color.fromRGBO(29, 29, 44, 0.89),
                       borderRadius:  BorderRadius.all(Radius.circular(10)),
                       
                    ),

                    child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                    _buildInputCardclone("🎂", "Age", userData.age.toString()),
                                    _buildInputCardclone("📏", "Height", userData.height.toString()),
                                    _buildInputCardclone("⚖️", "Weight", userData.weight.toString()),
                                    _buildInputCardclone("🐶", "Breed", userData.breed),
                                    _buildInputCardclone("🤕", "Symptoms",allSymptoms),
                              ],
                            ), 
                  ),
                  onTap: () {
                    showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: const Color.fromARGB(255, 243, 242, 240),
                        contentPadding: EdgeInsets.zero, // Removes extra padding
                        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 170), // Adjusts padding
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // Rounded corners
                        title: const Text('Input', textAlign: TextAlign.center, style: TextStyle(color:  Colors.black), ),
                        content: SizedBox(
                          width: screenWidth * 2, // 80% of screen width
                          height: screenHeight * 0.55, // 50% of screen height
                          child: Padding(
                            padding: const EdgeInsets.all(20.0), // Internal padding
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                    _buildInputCard("🎂", "Age", userData.age.toString()),
                                    _buildInputCard("📏", "Height", userData.height.toString()),
                                    _buildInputCard("⚖️", "Weight", userData.weight.toString()),
                                    _buildInputCard("🐶", "Breed", userData.breed),
                                    _buildInputCard("🤕", "Symptoms", allSymptoms),
                              ],
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Close",style: TextStyle(color: Colors.black),),
                          ),
                        ],
                      );
                    },
                  );

                  },

                
                  

                
                ),
              ),



               Positioned(
                  top: screenHeight * 0.36, // Centers it vertically
                  left: screenWidth * 0.515, // Centers it horizontally
                  child: InkWell(
                    child: Container(
                      width: screenWidth * 0.43,
                      height: screenHeight * 0.42,
                      decoration: const BoxDecoration(
                        color:   Color.fromRGBO(29, 29, 44, 0.897),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min, 
                        children: [
                          const Padding(padding: EdgeInsets.only(top: 30)),
                          CircularPercentIndicator(
                            radius: 45.0,
                            lineWidth: 15.0,
                            percent: 0.10,
                            animation: true,
                            center: const Text("10%", style: TextStyle(color: Colors.green),),
                            progressColor: const Color.fromARGB(255, 36, 143, 26),
                            footer: const Padding(
                            padding:  EdgeInsets.only(top: 10), // ✅ Adds 10px space above footer
                            child:  Text(
                              "Vomiting",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0, color: Color.fromARGB(255, 255, 255, 255)),
                            ),
                          ),
                          ),
                          SizedBox(height: screenHeight * 0.015), 

                          CircularPercentIndicator(
                            radius: 45.0,
                            lineWidth: 15.0,
                            percent: 0.30,
                            animation: true,
                            center: const Text("30%", style: TextStyle(color: Colors.orange),),
                            progressColor: Colors.orange,
                            footer: const Padding(
                            padding:  EdgeInsets.only(top: 10), // ✅ Adds 10px space above footer
                            child:  Text(
                              "Lethargy",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0, color: Color.fromARGB(255, 255, 255, 255)),
                            ),
                          ),
                          ),
                          SizedBox(height: screenHeight * 0.015), 

                          CircularPercentIndicator(
                            radius: 45.0,
                            lineWidth: 15.0,
                            percent: 0.90,
                            animation: true,
                            center: const Text("90%",style: TextStyle(color: Colors.red,),),
                            progressColor: const Color.fromARGB(255, 214, 39, 16),
                            footer: const Padding(
                            padding:  EdgeInsets.only(top: 10), // ✅ Adds 10px space above footer
                            child:  Text(
                              "Acid",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0, color: Color.fromARGB(255, 255, 255, 255)),
                            ),
                          ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: const Color.fromARGB(255, 243, 240, 240),
                      contentPadding: EdgeInsets.zero, // Removes extra padding
                      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 170), // Adjusts padding
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // Rounded corners
                      title: const Text(
                        'Symptoms Accuracy',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black),
                      ),
                      content: Padding(
                        padding: const EdgeInsets.only(top: 20), // ✅ Adds 10px top space
                        child: CircularPercentIndicator(
                          radius: 100.0,
                          lineWidth: 20.0,
                          animation: true,
                          percent: 0.9,
                          center: const Text(
                            "90.0%",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0),
                          ),
                          footer: const Padding(
                            padding:  EdgeInsets.only(top: 20), // ✅ Adds 10px space above footer
                            child:  Text(
                              "Acidic",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                            ),
                          ),
                          circularStrokeCap: CircularStrokeCap.round,
                          progressColor: const Color.fromARGB(255, 214, 39, 16),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Close", style: TextStyle(color: Colors.black)),
                        ),
                      ],
                    );
                  },
                );

    },
  ),
),




Positioned(
                top: screenHeight * 0.615, // Centers it vertically
                left: screenWidth * 0.06 , // Centers it horizontally
                child: InkWell(
                  child: Container(
                    width: screenWidth * 0.43,
                    height: screenHeight * 0.165,
                    decoration:   const BoxDecoration(
                      color:   Color.fromRGBO(29, 29, 44, 0.911),
                       borderRadius:  BorderRadius.all(Radius.circular(10)),
                       
                    ),

                    
                  ),
                  onTap: () {
                    showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: const Color.fromRGBO(255, 255, 255, 0.945),
                        contentPadding: EdgeInsets.zero, // Removes extra padding
                        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 170), // Adjusts padding
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // Rounded corners
                        title: const Text('Input', textAlign: TextAlign.center, style: TextStyle(color:  Colors.black), ),
                        content: SizedBox(
                          width: screenWidth * 2, // 80% of screen width
                          height: screenHeight * 0.55, // 50% of screen height
                          child: Padding(
                            padding: const EdgeInsets.all(20.0), // Internal padding
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                    _buildInputCard("🎂", "Age", userData.age.toString()),
                                    _buildInputCard("📏", "Height", userData.height.toString()),
                                    
                              ],
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Close",style: TextStyle(color: Colors.black),),
                          ),
                        ],
                      );
                    },
                  );

                  },

                
                  

                
                ),
              ),



                


                // ✅ Proceed Button (Same Style & Position)
                buildAnimatedButton(
                  screenHeight * 1.03,
                  screenWidth,
                  0.85,
                  "Proceed",
                  const RecommendationoneScreen(),
                  1,
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

  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildInputCard(String emoji, String label, String value) {
  return Card(
    elevation: 30,
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Aligns text and trailing
        children: [
          // Leading Icon & Text
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
    const SizedBox(width: 15),
              Column(          
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ],
              ),
            ],
          ),
          
          // **Trailing Icon (Example: Edit Icon)**
          const Icon(Icons.check, color:  Color.fromARGB(255, 21, 180, 0)),
        ],
      ),
    ),
  );
}


Widget _buildInputCardclone(String emoji, String label, String value) {
  return Card(
    elevation: 3,
    margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 25),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: Padding(
      padding: const EdgeInsets.all(5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Aligns text and trailing
        children: [
          
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  
                ],
              ),
            ],
          ),
          
          // **Trailing Icon (Example: Edit Icon)**
          const Icon(Icons.check, color:  Color.fromARGB(255, 21, 180, 0)),
        ],
      ),
    ),
  );
}


  // Method to create an animated button
  Widget buildAnimatedButton(double screenHeight, double screenWidth,
      double topPosition,String label, Widget destination, int index) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      top: _buttonVisible[index] ? screenHeight * topPosition : screenHeight,
      left: screenWidth * 0.45 - 50,
      child: ElevatedButton(
        onPressed: () {
          
         Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => destination),
      );
        },
        style: ButtonStyle(
                    // Dynamic background color based on button state
                    backgroundColor: WidgetStateProperty.resolveWith(
                      (states) {
                        if (states.contains(WidgetState.pressed)) {
                          return const Color.fromARGB(255, 255, 255, 255); // Background color when pressed
                        }
                        return const Color.fromRGBO(29, 29, 44, 1.0); // Default background color
                      },
                    ),
                    // Dynamic text color based on button state
                    foregroundColor: WidgetStateProperty.resolveWith(
                      (states) {
                        if (states.contains(WidgetState.pressed)) {
                          return const Color.fromARGB(255, 0, 0, 0); // Text color when pressed
                        }
                        return const Color.fromARGB(255, 255, 255, 255); // Default text color
                      },
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
}
