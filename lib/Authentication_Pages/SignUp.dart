import 'package:ai_study_assistant/Authentication_Pages/Login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ai_study_assistant/Home/Home.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  FirebaseAuth auth = FirebaseAuth.instance;
  GoogleSignIn googleSignIn = GoogleSignIn();

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passController.dispose();
    confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final formWidth = screenWidth * 0.85; // Adjust form width dynamically

    return Scaffold(
      backgroundColor: const Color(0xFF001FA3),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                const SizedBox(height: 80),
                Image.asset(
                  "assets/images/logoai.png",
                  height: 150,
                  width: 150,
                ),
                const SizedBox(height: 30),
                Text(
                  "CREATE ACCOUNT",
                  style: GoogleFonts.lato(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Container(
                    width: formWidth,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(width: 2, color: Colors.white),
                    ),
                    child: Column(
                      children: [
                        _buildTextField(usernameController, "Enter Username", Icons.person),
                        const SizedBox(height: 12),
                        _buildTextField(emailController, "Enter Email", Icons.email, isEmail: true),
                        const SizedBox(height: 12),
                        _buildTextField(passController, "Enter Password", Icons.lock, isPassword: true),
                        const SizedBox(height: 12),
                        _buildTextField(confirmPassController, "Confirm Password", Icons.lock, isPassword: true),
                        const SizedBox(height: 18),

                        // Register Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _registerUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              "REGISTER NOW",
                              style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Google Sign-Up Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _signUpWithGoogle,
                            icon: Image.asset(
                              "assets/images/google_logo.png",
                              height: 20,
                            ),
                            label: Text(
                              "Sign Up with Google",
                              style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                "Already have an account?",
                                style: GoogleFonts.lato(fontSize: 13, color: Colors.white),
                                overflow: TextOverflow.ellipsis, // Prevents overflow
                                softWrap: true, // Allows wrapping if needed
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                                );
                              },
                              child: Text(
                                "Login Now",
                                style: GoogleFonts.lato(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isPassword = false, bool isEmail = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      style: GoogleFonts.lato(fontSize: 16, color: Colors.white),
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.lato(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white, width: 1),
        ),
        prefixIcon: Icon(icon, color: Colors.white),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "$hint cannot be empty";
        }
        if (isEmail && !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value)) {
          return "Enter a valid email";
        }
        if (isPassword && value.length < 6) {
          return "Password must be at least 6 characters";
        }
        if (hint == "Confirm Password" && value != passController.text) {
          return "Passwords do not match";
        }
        return null;
      },
    );
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        await auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passController.text.trim(),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Registered Successfully", style: GoogleFonts.lato(color: Colors.white, fontSize: 16)),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}", style: GoogleFonts.lato(fontSize: 16, color: Colors.white)),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _signUpWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await auth.signInWithCredential(credential);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Home()));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Google Sign-In Successful", style: GoogleFonts.lato(color: Colors.white, fontSize: 16)),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.red));
    }
  }
}
