import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('EEEE, MMM d, yyyy - HH:mm').format(DateTime.now());
    final themeProvider = Provider.of<ThemeProvider>(context);

    return AppBar(
      backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.deepPurple, // Black in dark mode
      elevation: 4,
      iconTheme: const IconThemeData(color: Colors.white), // Ensures the drawer icon is always white
      title: Text(
        'AI Study Planner',
        style: GoogleFonts.lato(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white, // Keeps text color white
        ),
      ),
      actions: [
        IconButton(
          icon: themeProvider.isDarkMode
              ? const Icon(Icons.light_mode, color: Colors.white)
              : const Icon(Icons.dark_mode, color: Colors.white),
          onPressed: () {
            themeProvider.toggleTheme();
          },
        ),
      ],
    );
  }
}
