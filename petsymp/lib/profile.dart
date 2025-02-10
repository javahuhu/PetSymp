import 'package:flutter/material.dart';


class Profilescreen extends StatefulWidget {
   const Profilescreen({super.key});


  @override
  ProfilescreenState createState() => ProfilescreenState();
}

class ProfilescreenState extends State<Profilescreen> {
  // State to track the selected tab
   // Animation toggle


Map<String, String> hashmap = {
  "img1": "assets/basicinfo.png",
  "img2": "assets/language.png",
  "img3": "assets/location.png",
  "img4": "assets/security.png",
  "img5": "assets/support.png",
  "img6": "assets/condition.png",
  "img7": "assets/editprofile.png",
  "img8": "assets/logout.png",
};

  

  @override
  Widget build(BuildContext context) {
    // Screen dimensions
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
       backgroundColor: const Color(0xFFCFCFCC),
      body: Stack(

        
        children: [
          
       
            Positioned(
              top: screenHeight * 0.001, // 20% from the top of the screen
              left: screenWidth * 0.001, // 10% from the left of the screen
              child: Column(
              
                children: [
                  Row(
                    
                    children: [
                      // Circular Image
                        Container(
                        width: screenWidth * 3, // 15% of screen width
                        height: screenWidth * 0.8, // Equal height for circular image
                        color: const Color.fromRGBO(61, 47, 40, 1),

                        child: Stack(
                           fit: StackFit.expand,
                          clipBehavior: Clip.none, // ✅ Use this instead of 'overflow: Overflow.visible'
                          children: <Widget>[
                     
                      
                        // 🐾 Paw Image Inside Yellow Background
                        

                        // 📌 "Summary of Input" Title Inside Yellow Background
                        Positioned(
                          top: 50,
                          left: screenWidth * 0.34,
                          child: const CircleAvatar(
                          radius: 75.0,
                          backgroundColor: Color.fromARGB(136, 0, 0, 0),
                          backgroundImage: AssetImage('assets/profile.jpg'),
                        ),
                        ),

                        Positioned(
                          top: 200,
                          left: screenWidth * 0.25,
                          child: Container(
                    width: screenWidth * 0.5,
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(0, 255, 255, 255),
                      borderRadius: BorderRadius.circular(20),
                     
                    ),
                     child:const  Center(
                    child: Text(
                      "Saul ArmStrong", // ✅ Longer text will still be centered
                      textAlign: TextAlign.center, // ✅ Ensures center alignment
                      style:  TextStyle(
                        fontSize: 28, // Adjust size if needed
                        fontWeight: FontWeight.normal,
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                  ),
                        ),

                        ),
                        
                        
                        Positioned(
                          top: 250,
                          left: screenWidth * 0.25,
                          child: Container(
                    width: screenWidth * 0.5,
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(0, 255, 255, 255),
                      borderRadius: BorderRadius.circular(20),
                     
                    ),
                     child:const  Center(
                    child: Text(
                      "Saul@gmail.com", // ✅ Longer text will still be centered
                      textAlign: TextAlign.center, // ✅ Ensures center alignment
                      style:  TextStyle(
                        fontSize: 20, // Adjust size if needed
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                  ),
                        ),

                        ),

                    Positioned(
                top: 315, // Adjust position
                left: screenWidth * 0.05,
                child:  Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    SizedBox(width: screenWidth * 0.1),
                     Container(
                      width: screenWidth * 0.1, // Set a width
                      height: screenWidth * 0.1,
                      decoration: const BoxDecoration(
                      image: DecorationImage(
                      image: AssetImage("assets/email1.png"),
                  fit: BoxFit.contain,
                  
                  ),
                  ),
                  
                  ),
                  SizedBox(width: screenWidth * 0.07),
                  Container(
                    width: screenWidth * 0.1, // Set a width
                      height: screenWidth * 0.1,
                      decoration: const BoxDecoration(
                        
                      image: DecorationImage(
                      image: AssetImage("assets/phone.png"),
                  fit: BoxFit.contain,
                  alignment: Alignment.topCenter,
                  ),
                  ),
                  
                  ),
               SizedBox(width: screenWidth * 0.065), 

    
                SizedBox(
                  height: screenWidth * 0.1, 
                  child: const VerticalDivider(
                    color: Colors.white,
                    thickness: 3,
                    width: 20, 
                  ),
                ),

                  SizedBox(width: screenWidth * 0.06),
                  Container(
                     width: screenWidth * 0.1, // Set a width
                      height: screenWidth * 0.1,
                      decoration: const BoxDecoration(
                       
                      image: DecorationImage(
                      image: AssetImage("assets/pawhistory.png"),
                  fit: BoxFit.contain,
                  alignment: Alignment.topCenter,
                  ),
                  ),
                  
                  ),

                  SizedBox(width: screenWidth * 0.07),
                  Container(
                     width: screenWidth * 0.1, // Set a width
                      height: screenWidth * 0.1,
                      decoration: const BoxDecoration(
                        
                      image: DecorationImage(
                      image: AssetImage("assets/favourite.png"),
                  fit: BoxFit.contain,
                  alignment: Alignment.topCenter,
                  ),
                  ),
                  
                  ),


                  ],
                )),
                        


                        /*
                         Positioned(
                          top: 306,
                          left: screenWidth * 0.1,
                          child: Container(
                            height: screenHeight  * 0.15,
                    width: screenWidth * 0.8,
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 245, 245, 245),
                      borderRadius: BorderRadius.circular(5),
                     
                    ),
                     
                        ),

                        ),*/

                       
                        
                        ],
                       
                    ),
                       
                      ),



                  
                   
        
                     
                    ],
                   ),

                  

                  

                 
                ],
              ),
            ),

            


             Positioned(
                  top: screenHeight * 0.350,
                  left: screenWidth * -0.04,
                  child: Container(
                    width: 510,
                    height: screenHeight * 0.6,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(0, 255, 255, 255), // Set Background Color
                      borderRadius: BorderRadius.circular(25), // Optional rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.0), // Light shadow
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10), // Add padding inside container
                      child: ListView(
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildInputCard("img1", "Basic Information"),
                          _buildInputCard("img2",  "Language"),
                          _buildInputCard("img3", "Location"),
                          _buildInputCard("img4", "Security"),
                          _buildInputCard("img5", "Help and Support"),
                          _buildInputCard("img6",  "Terms and Conditions"),
                          _buildInputCard("img7",  "Edit Profile"),
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
  return Card(
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
                  hashmap[index]!, // Fetch image path from hashmap
                  width: 30, // Adjust as needed
                  height: 30,
                  fit: BoxFit.contain,
                ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  Text(
                    value,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.normal, color: Colors.black),
                  ),
                ],
              ),
            ],
          ),
          
          // **Trailing Icon (Example: Edit Icon)**
          Image.asset(
                  "assets/arrowright.png", // Fetch image path from hashmap
                  width: 30, // Adjust as needed
                  height: 30,
                  fit: BoxFit.contain,
                ),
        ],
      ),
    ),
  );
}
}

