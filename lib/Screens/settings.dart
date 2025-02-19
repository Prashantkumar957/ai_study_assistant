import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ai_study_assistant/Authentication_Pages/SignUp.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current logged-in user
    User? user = FirebaseAuth.instance.currentUser;

    // Extract email & username (before '@')
    String email = user?.email ?? "No Email Found";
    String username = email.split('@')[0]; // Get username from email

    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image (Custom Icon)
            Center(
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Text(
                  username[0].toUpperCase(),
                  style: GoogleFonts.lato(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Username
            ListTile(
              leading: Icon(Icons.account_circle, color: Colors.blueAccent),
              title: Text(username, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),

            // Qualification (Static or Fetch from Firestore)
            ListTile(
              leading: Icon(Icons.school, color: Colors.blueAccent),
              title: Text("Student", style: TextStyle(fontSize: 16)),
            ),

            // Email ID
            ListTile(
              leading: Icon(Icons.email, color: Colors.blueAccent),
              title: Text(email, style: TextStyle(fontSize: 16)),
            ),

            SizedBox(height: 30),

            // Logout Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut(); // Firebase Logout
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Signup()));
                },
                icon: Icon(Icons.logout, color: Colors.white),
                label: Text("Logout", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent, // Button Color
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
