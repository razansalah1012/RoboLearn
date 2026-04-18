import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark background matching logo
      appBar: AppBar(
        title: const Text(
          "Dashboard",
          style: TextStyle(color: Color(0xFF121212), fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFFD700), // Gold
        iconTheme: const IconThemeData(color: Color(0xFF121212)),
      ),
      body: const Center(
        child: Text(
          "Dashboard",
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFD700), // Gold
          ),
        ),
      ),
    );
  }
}
