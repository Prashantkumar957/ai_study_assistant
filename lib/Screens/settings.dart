import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ai_study_assistant/Authentication_Pages/SignUp.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

import '../ad_helper.dart';

class SettingsPage extends StatefulWidget {

  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AdHelper _adHelper = AdHelper();
 // Instance of AdHelper
  @override
  void initState() {
    super.initState();
    _adHelper.loadBannerAd1();
    _adHelper.loadBannerAd2(); // Load a single banner ad
    _adHelper.loadBannerAd3(); // Load a banner ad
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String email = user?.email ?? "No Email Found";
    String username = email.split('@')[0];

    return Scaffold(
      appBar: AppBar(
        title: Text("Settings", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.deepPurple,
                    child: Text(
                      username[0].toUpperCase(),
                      style: GoogleFonts.lato(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(username, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600)),
                  Text(email, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ),

            SizedBox(height: 30),

            // Settings Options
            _buildSettingTile(Icons.contact_mail, "Contact Us", () {
              _showDialog(
                context,
                "Contact Us",
                "For any queries, write an email to:\n\nprashantkumar.789@yahoo.com",
              );
            }),

            _buildSettingTile(Icons.info, "About App", () {
              _showDialog(
                context,
                "About AI Study Assistant",
                "AI Study Assistant is an intelligent learning companion that helps students with notes, quizzes, and interactive study resources.\n\n"
                    "Version: 02.2025",
              );
            }),

            SizedBox(height: 20),

            // Logout Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Signup()));
                },
                icon: Icon(Icons.logout, color: Colors.white),
                label: Text("Logout", style: GoogleFonts.poppins(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),

            SizedBox(height: 40),

            // About Developer (Unchanged)
            ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage('https://assets.leetcode.com/users/prashantkumar957/avatar_1737888694.png'),
              ),
              title: Text("About Developer"),
              subtitle: Text("This app is created by Prashant Kumar. Connect with me on LinkedIn."),
              onTap: () async {
                final Uri url = Uri.parse("https://www.linkedin.com/in/prashantkumar957/");

                if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Could not open LinkedIn")),
                  );
                }
              },
            ),
              SizedBox(height:25,),
            _adHelper.getBannerAdWidget1(),
            _adHelper.getBannerAdWidget2(),
            _adHelper.getBannerAdWidget3(),

          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 16)),
      trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(content, style: GoogleFonts.poppins(fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("OK")),
        ],
      ),
    );
  }
}
