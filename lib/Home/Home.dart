import 'package:ai_study_assistant/Authentication_Pages/SignUp.dart';
import 'package:ai_study_assistant/Screens/calendar.dart';
import 'package:ai_study_assistant/Screens/daily_task.dart';
import 'package:ai_study_assistant/Screens/focus.dart';
import 'package:ai_study_assistant/Screens/notification.dart';
import 'package:ai_study_assistant/Screens/study_tips.dart';
import 'package:ai_study_assistant/widgets/custom_appbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/material.dart';
import 'package:ai_study_assistant/Screens/Weekly.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ai_study_assistant/Screens/study_plan.dart';
import 'package:ai_study_assistant/Screens/settings.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomeContent(),
    CalendarPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: _buildDrawer(context),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    String? email = FirebaseAuth.instance.currentUser?.email;
    String username = email != null ? email.split('@').first.capitalize() : 'Guest';
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: isDarkMode ? Colors.black : Colors.blue),
            child: Row(
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
          _drawerItem(Icons.home, "Home",() {
          Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
          }),

          _drawerItem(Icons.smart_toy, "Chat with AI", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen()));
          }),

          _drawerItem(Icons.notifications_active, "Notifications", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationsPage()));
          }),



          _drawerItem(Icons.policy, "Privacy Policy", () {
            _showPopup(
              context,
              "Privacy Policy",
              "We respect your privacy. Your data is securely stored and not shared with third parties.",
              url: "https://aistudyplanner.blogspot.com/2025/02/ai-study-planner-smart-task-exam.html",
            );
          }),

          _drawerItem(Icons.feedback, "Help or Feedback", () {
            _showPopup(context, "Feedback", "We value your feedback! If you have any suggestions, email us at prashantkumar.789@yahoo.com.");
          }),

          _drawerItem(Icons.info, "About App", () {
            _showPopup(context, "About AI Study Assistant", "AI Study Assistant helps students with notes, quizzes & AI-powered learning.\nVersion: 02.2025");
          }),
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
  void _showPopup(BuildContext context, String title, String content, {String? url}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(content, style: TextStyle(fontSize: 16)),
          actions: [
            if (url != null) // Show "More" button only if a URL is provided
              TextButton(
                onPressed: () async {
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
                child: Text("Click here for Details", style: TextStyle(color: Colors.green)),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the popup
              },
              child: Text("OK", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }


  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: GoogleFonts.lato(fontSize: 18)),
      onTap: onTap,
    );
  }
}

class HomeContent extends StatelessWidget {
  String getFormattedDateTime() {
    return DateFormat('EEEE, MMM d, yyyy - HH:mm').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    String? email = FirebaseAuth.instance.currentUser?.email;
    String username = email != null ? email.split('@').first.capitalize() : 'Guest';
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
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
                _buildCard(context, "AI Chat", Icons.lightbulb, Colors.teal, ChatScreen()),
                _buildCard(context, "Weekly Scheduler", Icons.bar_chart, Colors.green, WeeklySchedulerPage()),

                _buildCard(context, "Exam Countdown", Icons.alarm, Colors.purple, CalendarPage()),
                _buildCard(context, "Focus Mode", Icons.timer, Colors.red, FocusScreen()),
              ],
            ),
          ),
        ],
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