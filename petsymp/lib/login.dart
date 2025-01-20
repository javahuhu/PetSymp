import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'getstarted.dart';  // For launching URLs

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Helper method to launch Facebook URL
  Future<void> gotoPage(String urlString) async {
    final Uri url = Uri.parse(urlString); 
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/catlogin.jpg'),
              ),
            ),
          ),
          // Content on top of the image
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               // Spacing at the top
              Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Image.asset(
                  'assets/logo.png',
                  width: 300,
                  height: 300,
                ),
              ),
              const SizedBox(height: 187.5), // Spacing between logo and text
              const Padding(
                padding: EdgeInsets.only(left: 35.0),
                child: Text(
                  'Welcome!',
                  style: TextStyle(
                    fontSize: 35.0,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ),
              const SizedBox(height: 120.0), // Spacing before text field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35.0),
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    label: Center(
                      child: Text("Enter your phone number"),
                    ),
                    labelStyle: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000000),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25.0),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const GetstartedScreen()),
                        );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCFCFCF), // Button background color
                    foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    fixedSize: const Size(400, 65), // Button width and height
                  ),
                  child: const Text(
                    "Log In",
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25.0),

              // Divider + "OR" + Divider
              const Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.black,
                      thickness: 2,
                      indent: 20,
                      endIndent: 5,
                    ),
                  ),
                  Text(
                    "OR",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.black,
                      thickness: 2,
                      indent: 5,
                      endIndent: 20,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25.0),

              // Clickable Circle Image for google
              Row( children: [ Padding(padding: const EdgeInsets.only(left: 116), 
                 child: InkWell(
                  onTap: () async {
                  await  gotoPage("https://accounts.google.com/");
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      // Add a background color if desired
                    ),
                    // Show the Facebook image in a circle
                    child: ClipOval(
                      child: Image.asset(
                        'assets/googlelogo.png', 
                        fit: BoxFit.cover, // Crop/scale the image
                      ),
                    ),
                  ),
                ),),

                // Clickable Circle Image for Facebook
                Padding(padding: const EdgeInsets.only(left: 25), 
                 child: InkWell(
                  onTap: () async {
                  await  gotoPage("https://www.facebook.com/");
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      // Add a background color if desired
                    ),
                    // Show the Facebook image in a circle
                    child: ClipOval(
                      child: Image.asset(
                        'assets/facebooklogo.png', 
                        fit: BoxFit.cover, // Crop/scale the image
                      ),
                    ),
                  ),
                ),),


                
                Padding(padding: const EdgeInsets.only(left: 25), 
                 child: InkWell(
                  onTap: () async {
                  await  gotoPage("https://www.instagram.com/");
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      // Add a background color if desired
                    ),
                    // Show the Facebook image in a circle
                    child: ClipOval(
                      child: Image.asset(
                        'assets/instagramlogo.png', 
                        fit: BoxFit.cover, // Crop/scale the image
                      ),
                    ),
                  ),
                ),),


               ],)
              
            ],
          ),
        ],
      ),
    );
  }
}
