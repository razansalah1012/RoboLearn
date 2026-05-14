import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'student_home_screen.dart';
import 'admin_home_screen.dart';
import 'login_screen.dart';
import 'committee_dashboard.dart';
import 'intro_screen.dart';
import '../models/user_model.dart';
import '../theme/app_colors.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<UserModel?>(
            future: authService.getUserData(snapshot.data!.uid),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              final userData = userSnapshot.data;
              
              if (userData == null) {
                // If user exists in Auth but not in Firestore, log them out
                return FutureBuilder(
                  future: authService.logout(),
                  builder: (context, _) => const IntroScreen(),
                );
              }

              if (userData.isBlocked) {
                return const SuspendedAccountScreen();
              }

              if (!userData.isApproved) {
                return const PendingApprovalScreen();
              }

              // Route based on role
              if (userData.role == 'admin') {
                return const AdminHomeScreen();
              } else if (userData.role == 'committee') {
                return const CommitteeDashboard();
              } else {
                return const StudentHomeScreen();
              }
            },
          );
        }

        return const IntroScreen();
      },
    );
  }
}

class SuspendedAccountScreen extends StatelessWidget {
  const SuspendedAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.block_flipped, size: 100, color: Colors.red),
              const SizedBox(height: 32),
              Text(
                "ACCOUNT SUSPENDED",
                style: GoogleFonts.orbitron(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cranberry,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                "Your access to RoboLearn has been revoked by a system administrator. If you believe this is an error, please contact the Hub support team.",
                style: GoogleFonts.exo2(color: AppColors.taupe),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () => AuthService().logout(),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.cranberry),
                child: const Text("SIGN OUT"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.hourglass_empty, size: 80, color: Colors.orange),
              const SizedBox(height: 24),
              Text(
                "Access Pending",
                style: GoogleFonts.orbitron(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                "Your registration is being reviewed. You will gain access once an admin approves your request.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => AuthService().logout(),
                child: const Text("LOGOUT"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
