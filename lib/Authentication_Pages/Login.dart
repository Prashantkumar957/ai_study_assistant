import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ai_study_assistant/Home/Home.dart';
import 'package:ai_study_assistant/Authentication_Pages/SignUp.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  void login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passController.text.trim(),
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMsg = "Login failed. Please try again.";
      if (e.code == 'user-not-found') {
        errorMsg = "No user found with this email.";
      } else if (e.code == 'wrong-password') {
        errorMsg = "Incorrect password. Try again.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg, style: GoogleFonts.lato(fontSize: 16, color: Colors.white)),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001FA3),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 100),
              Image.asset("assets/images/logoai.png", height: 200, width: 200),
              const SizedBox(height: 40),
              Text(
                "LOGIN TO YOUR ACCOUNT",
                style: GoogleFonts.lato(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold),
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
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          prefixIcon: const Icon(Icons.email, color: Colors.white),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Email cannot be empty";
                          if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value)) {
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
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          prefixIcon: const Icon(Icons.lock, color: Colors.white),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Password cannot be empty";
                          if (value.length < 6) return "Password must be at least 6 characters";
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: isLoading ? null : login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text("LOGIN NOW", style: GoogleFonts.lato(fontSize: 20)),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account?", style: GoogleFonts.lato(fontSize: 17, color: Colors.white)),
                          TextButton(
                            onPressed: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const Signup()),
                            ),
                            child: Text(
                              "Register Now",
                              style: GoogleFonts.lato(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
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
