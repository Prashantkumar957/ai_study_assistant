import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ai_study_assistant/Home/Home.dart';
import 'package:ai_study_assistant/Authentication_Pages/SignUp.dart';

class Splashscreen extends StatelessWidget {
  const Splashscreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 1), () {
      // Check if user is signed in
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // If signed in, go to Home screen
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const Home()));
      } else {
        // If not signed in, go to Signup screen
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const Signup()));
      }
    });

    return Scaffold(
      backgroundColor: Color(0xFF5271FF),
      body: Center(
        child: Image.asset("assets/images/ailogo.png", height: 250, width: 250),
      ),
    );
  }
}
