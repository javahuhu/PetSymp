
import 'package:flutter/material.dart';
import 'homepage.dart';


class Basicinfoscreen extends StatefulWidget {
   const Basicinfoscreen({super.key});


  @override
 BasicinfoscreenState createState() => BasicinfoscreenState();
}

class BasicinfoscreenState extends State<Basicinfoscreen> {
  // State to track the selected tab
  // State to track the selected tab
   // Animation toggle


Map<String, Map<String, dynamic>> hashmap = {
  "img1": {
    "image": "history",
    "screen": (BuildContext context) => const HomePageScreen(),
  },
  "img2": {
    "image": "assets/support.png",
    "screen": (BuildContext context) => const HomePageScreen(),
  },
  "img6": {
    "image": "assets/condition.png",
    "screen": (BuildContext context) => const HomePageScreen(),
  },
  "img8": {
    "image": "assets/logout.png",
    "screen": (BuildContext context) => const HomePageScreen(), // Call logout function
  },
};





  

  @override
  Widget build(BuildContext context) {
    // Screen dimensions
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
       backgroundColor:const Color.fromRGBO(29, 29, 44, 1.0),
      body: Stack(

        
        children: [

             Positioned(
                  top: screenHeight * 0.03,
                  left: screenWidth * -0.04,
                  child: Container(
                    width: 510,
                    height: screenHeight * 0.6,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(0, 255, 255, 255), // Set Background Color
                      borderRadius: BorderRadius.circular(25), // Optional rounded corners
                     
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10), // Add padding inside container
                      child: ListView(
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildInputCard("img4", "Security"),
                          _buildInputCard("img5", "Help and Support"),
                          _buildInputCard("img6",  "Terms and Conditions"),
                           _buildInputCard("img8",  "Log out"),
                        ],
                      ),
                    ),
                  ),
),

              

          // Rotated Image Positioned at the Bottom with Animation

          // Placeholder for other tabs
          // Display corresponding content for other tabs
             
        ],
        
      ),

      

      
      
    );

    

    
  }

  Widget _buildInputCard(String index, String value) {
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
    child: Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Aligns text and trailing
          children: [
            // Leading Icon & Text
            Row(
              children: [
                if (hashmap.containsKey(index))
                  Image.asset(
                    hashmap[index]!["image"], // Fetch image path from hashmap
                    width: 30, // Adjust as needed
                    height: 30,
                    fit: BoxFit.contain,
                    color: const Color.fromRGBO(82, 170, 164, 1),
                  ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.normal, color: Color.fromRGBO(82, 170, 164, 1)),
                    ),
                  ],
                ),
              ],
            ),
            // **Trailing Icon (Example: Arrow Icon)**
            Image.asset(
              "assets/arrowright.png",
              width: 30,
              height: 30,
              fit: BoxFit.contain,
              color: const Color.fromRGBO(82, 170, 164, 1),
            ),
          ],
        ),
      ),
    ),
  );
}

}