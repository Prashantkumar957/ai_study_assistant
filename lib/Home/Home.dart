import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:ai_study_assistant/Screens/settings.dart';
import 'package:ai_study_assistant/Authentication_Pages/SignUp.dart';
import 'package:ai_study_assistant/widgets/custom_appbar.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  String getFormattedDateTime() {
    return DateFormat('EEEE, MMM d, yyyy - HH:mm').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    String? email = FirebaseAuth.instance.currentUser?.email;
    String username = email != null ? email.split('@').first.capitalize() : 'Guest';

    return Scaffold(
      appBar: CustomAppBar(),
      drawer: _buildDrawer(context, username, email, themeProvider.isDarkMode),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildWelcomeMessage(username, themeProvider.isDarkMode),
            const SizedBox(height: 5),
            Text(
              getFormattedDateTime(),
              style: GoogleFonts.lato(fontSize: 18, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  // **Welcome Message**
  Widget _buildWelcomeMessage(String username, bool isDarkMode) {
    return Row(
      children: [
        Icon(Icons.waving_hand, color: Colors.amber, size: 28),
        const SizedBox(width: 8),
        Text(
          "Welcome, $username!",
          style: GoogleFonts.lato(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black, // White in dark mode
          ),
        ),
      ],
    );
  }

  // **Drawer with Dynamic Header**
  Widget _buildDrawer(BuildContext context, String username, String? email, bool isDarkMode) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: isDarkMode ? Colors.black : Colors.deepPurple), // Black in dark mode
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text(
                    username[0].toUpperCase(),
                    style: GoogleFonts.lato(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Hello, $username!",
                      style: GoogleFonts.lato(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      email ?? "Not Logged In",
                      style: GoogleFonts.lato(fontSize: 16, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// **Extension for Capitalization**
extension StringExtension on String {
  String capitalize() {
    return isNotEmpty ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : this;
  }
}
