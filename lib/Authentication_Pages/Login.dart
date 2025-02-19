import 'package:ai_study_assistant/Authentication_Pages/SignUp.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ai_study_assistant/main.dart'; // Adjust import according to your app's structure
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ai_study_assistant/Home/Home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              Image.asset(
                "assets/images/sp.png", // Adjust image path accordingly
                height: 200,
                width: 200,
              ),
              const SizedBox(height: 40),
              Text(
                "LOGIN TO YOUR ACCOUNT",
                style: GoogleFonts.lato(fontSize: 26, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Container(
                  width: 400,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(width: 3, color: Colors.white),
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.lato(fontSize: 20, color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Enter Email",
                          hintStyle: GoogleFonts.lato(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          prefixIcon: const Icon(Icons.email, color: Colors.white),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Email cannot be empty";
                          } else if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value)) {
                            return "Enter a valid email";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: passController,
                        style: GoogleFonts.lato(fontSize: 20, color: Colors.white),
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "Enter Password",
                          hintStyle: GoogleFonts.lato(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          prefixIcon: const Icon(Icons.lock, color: Colors.white),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Password cannot be empty";
                          } else if (value.length < 6) {
                            return "Password must be at least 6 characters";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            auth.signInWithEmailAndPassword(
                              email: emailController.text.trim(),
                              password: passController.text.trim(),
                            ).then((value) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const Home()), // Adjust navigation accordingly
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Logged in Successfully",
                                    style: GoogleFonts.lato(color: Colors.white, fontSize: 20),
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 3),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }).catchError((error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    error.toString(),
                                    style: GoogleFonts.lato(fontSize: 16, color: Colors.white),
                                  ),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "LOGIN NOW",
                          style: GoogleFonts.lato(fontSize: 20),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: GoogleFonts.lato(fontSize: 20, color: Colors.white),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const Signup()), // Adjust navigation to registration screen
                              );
                            },
                            child: Text(
                              "Register Now",
                              style: GoogleFonts.lato(fontSize: 20, color: Colors.blue),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
