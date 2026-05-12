import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ClubMemberHomeScreen extends StatelessWidget {
  const ClubMemberHomeScreen({super.key});

  Future<void> logout(BuildContext context) async {
    await AuthService().logout();

    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Club Member Dashboard"),
        actions: [
          IconButton(
            onPressed: () => logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: const Center(
        child: Text(
          "Club Member: Add learning materials, workshops, and club updates.",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}