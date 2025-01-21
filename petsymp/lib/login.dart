import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'getstarted.dart';
import 'package:flutter/services.dart'; // For launching URLs

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  // Helper method to launch external URLs
  Future<void> gotoPage(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void navigateToNextPage() {
    if (_formKey.currentState?.validate() ?? false) {
      // Navigate only if the input is valid
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const GetstartedScreen()),
      );
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
                child: Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), 
                    FilteringTextInputFormatter.digitsOnly

  ],
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: "Enter your phone number",
                      labelStyle: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF000000),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }

                      if (value.length !=11){
                        return "Phone Number must be 11 digits";
                      }

                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 25.0),
              Center(
                child: ElevatedButton(
                  onPressed: navigateToNextPage, // Validation is handled here
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCFCFCF),
                    foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    fixedSize: const Size(400, 65),
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

              // Clickable Circle Image for external links
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 116),
                    child: InkWell(
                      onTap: () async {
                        await gotoPage("https://accounts.google.com/");
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/googlelogo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: InkWell(
                      onTap: () async {
                        await gotoPage("https://www.facebook.com/");
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/facebooklogo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: InkWell(
                      onTap: () async {
                        await gotoPage("https://www.instagram.com/");
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/instagramlogo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
