
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class Profilescreen extends StatefulWidget {
   const Profilescreen({super.key});


  @override
  ProfilescreenState createState() => ProfilescreenState();
}

class ProfilescreenState extends State<Profilescreen> {
  String nickname = "Loading...";
  String email = "Loading...";

  @override
  void initState(){
    super.initState();
    fetchUserNickname();
  }

 Future<void> fetchUserNickname() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userId = user.uid; // ✅ Use Firebase Auth UID as the document ID

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId) // ✅ Fetch by UID (document ID)
          .get();

      if (userDoc.exists) {
        setState(() {
          nickname = userDoc.get('Username') ?? "No Username"; 
          email = userDoc.get('Email') ?? "No Email";
        });
      } else {
        setState(() {
          nickname = "User Not Found";
          email = "Email Not Found";
        });
      }
    } else {
      setState(() {
        nickname = "Not Logged In";
        email = "Not Logged In";
      });
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }
}


  

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
              top: screenHeight * 0.001, // 20% from the top of the screen
              left: screenWidth * 0.001, // 10% from the left of the screen
              child: Column(
              
                children: [
                  Row(
                    
                    children: [
                      // Circular Image
                        Container(
                        width: screenWidth * 1, // 15% of screen width
                        height: screenWidth * 0.8, // Equal height for circular image 
                        decoration: const BoxDecoration(color: Color.fromARGB(255, 219, 230, 233), 
                        borderRadius: BorderRadius.only(bottomRight: Radius.circular(100), bottomLeft: Radius.circular(100))),

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
                     child:  Center(
                    child: Text(
                      nickname, // ✅ Longer text will still be centered
                      textAlign: TextAlign.center, // ✅ Ensures center alignment
                      style:  const TextStyle(
                        fontSize: 28, // Adjust size if needed
                        fontWeight: FontWeight.normal,
                        color: Color.fromRGBO(29, 29, 44, 1.0),
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
                     child:  Center(
                    child: Text(
                      email, // ✅ Longer text will still be centered
                      textAlign: TextAlign.center, // ✅ Ensures center alignment
                      style: const TextStyle(
                        fontSize: 20, // Adjust size if needed
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(29, 29, 44, 1.0),
                      ),
                    ),
                  ),
                        ),

                        ),

                      


                  
                        


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

            


           

              

          // Rotated Image Positioned at the Bottom with Animation

          // Placeholder for other tabs
          // Display corresponding content for other tabs

           Stack( children: [
                      
                      Positioned( top:screenHeight * 0.4, left: screenWidth * 0.05, width: screenWidth * 5,
                        child:  Text("Nickname: $nickname", 
                        style: const TextStyle(fontSize: 26, 
                        fontWeight: FontWeight.bold, color: Color.fromRGBO(82, 170, 164, 1)),),
                        ),

                        const Column(children: [
                           Divider(height: 20, thickness: 5, indent: 0, endIndent: 0, color: Color.fromARGB(255, 219, 230, 233),)
                        ],),
                        
                        Positioned( top:screenHeight * 0.5, left: screenWidth * 0.05, width: screenWidth * 5,
                        child:  const Text("Age:", 
                        style:  TextStyle(fontSize: 26, 
                        fontWeight: FontWeight.bold, color: Color.fromRGBO(82, 170, 164, 1)),)),

                        Positioned( top:screenHeight * 0.6, left: screenWidth * 0.05, width: screenWidth * 5,
                        child:  const Text("Number:", 
                        style:  TextStyle(fontSize: 26, 
                        fontWeight: FontWeight.bold, color: Color.fromRGBO(82, 170, 164, 1)),)),

                        Positioned( top:screenHeight * 0.7, left: screenWidth * 0.05, width: screenWidth * 5,
                        child:  const Text("Gender:", 
                        style:  TextStyle(fontSize: 26, 
                        fontWeight: FontWeight.bold, color: Color.fromRGBO(82, 170, 164, 1)),)),
                   ],)
             
        ],
        
      ),

      

      
      
    );

    

    
  }

}