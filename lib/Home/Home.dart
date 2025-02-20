import 'package:ai_study_assistant/Authentication_Pages/SignUp.dart';
import 'package:ai_study_assistant/Screens/daily_task.dart';
import 'package:ai_study_assistant/Screens/study_tips.dart';
import 'package:ai_study_assistant/widgets/custom_appbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ai_study_assistant/Screens/Weekly.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ai_study_assistant/Screens/study_plan.dart';
import 'package:ai_study_assistant/Screens/progress_tracker.dart';
import 'package:ai_study_assistant/Screens/settings.dart';
import 'package:ai_study_assistant/Authentication_Pages/Login.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  String getFormattedDateTime() {
    return DateFormat('EEEE, MMM d, yyyy - HH:mm').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    String? email = FirebaseAuth.instance.currentUser?.email;
    String username = email != null ? email.split('@').first.capitalize() : 'Guest';
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(

      ),

      drawer: _buildDrawer(context, username, email, isDarkMode),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildWelcomeMessage(username, isDarkMode),
            const SizedBox(height: 5),
            Text(
              getFormattedDateTime(),
              style: GoogleFonts.lato(fontSize: 18, color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildCard(context, "Daily Scheduler", Icons.schedule, Colors.blue, TaskSchedulerPage()),

                  _buildCard(context, "AI Created Study Plan", Icons.auto_graph, Colors.orange, StudyPlanPage()),
                  _buildCard(context, "AI Study Tips", Icons.lightbulb, Colors.teal, ChatScreen()),

                  _buildCard(context, "Exam Countdown", Icons.alarm, Colors.purple, StudyPlanPage()),
                  _buildCard(context, "Weekly  Scheduler", Icons.bar_chart, Colors.green, WeeklySchedulerPage()),
                  _buildCard(context, "Focus Mode", Icons.timer, Colors.red, StudyPlanPage()),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: BottomNavigationBar(
          currentIndex: 0,
          onTap: (index) {},
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home', backgroundColor: Colors.blue),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
          ],
        ),
      ),

    );
  }

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
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context, String username, String? email, bool isDarkMode) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: isDarkMode ? Colors.black : Colors.blue),
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
                      style: GoogleFonts.lato(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      email ?? "Not Logged In",
                      style: GoogleFonts.lato(fontSize: 15, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _drawerItem(Icons.home, "Home", () => Navigator.pop(context)),
          _drawerItem(Icons.phone, "Contact Us", () {}),
          _drawerItem(Icons.privacy_tip, "Privacy Policy", () {}),
          _drawerItem(Icons.share, "Share", () {}),
          _drawerItem(Icons.star, "Rate App", () {}),
          _drawerItem(Icons.settings, "Settings", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
          }),
          _drawerItem(Icons.logout, "Logout", () async {
            await FirebaseAuth.instance.signOut();
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Signup()));
          }),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: GoogleFonts.lato(fontSize: 18)),
      onTap: onTap,
    );
  }

  Widget _buildCard(BuildContext context, String title, IconData icon, Color color, Widget page) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => page));
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 45, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return isNotEmpty ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : this;
  }
}
