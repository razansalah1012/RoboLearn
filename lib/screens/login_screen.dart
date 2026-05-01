import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/tech_background_animation.dart';
import '../widgets/animated_interactive_card.dart';
import '../services/auth_service.dart';

import 'sign_up_screen.dart';
import 'admin_home_screen.dart';
import 'club_member_home_screen.dart';
import 'student_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool isResettingPassword = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _translateAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _translateAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> loginUser() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and password.")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final role = await AuthService().loginUser(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      Widget nextScreen;

      if (role == 'admin') {
        nextScreen = const AdminHomeScreen();
      } else if (role == 'club_member') {
        nextScreen = const ClubMemberHomeScreen();
      } else {
        nextScreen = const StudentHomeScreen();
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => nextScreen),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(getAuthErrorMessage(e))),
      );
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Future<void> forgotPassword() async {
    if (emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your email first.")),
      );
      return;
    }

    setState(() => isResettingPassword = true);

    try {
      await AuthService().resetPassword(emailController.text.trim());

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password reset email sent. Check your inbox."),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(getAuthErrorMessage(e))),
      );
    }

    if (mounted) {
      setState(() => isResettingPassword = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.beige,
      body: Stack(
        children: [
          const Positioned.fill(
            child: TechBackgroundAnimation(),
          ),

          SafeArea(
            child: Center(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  scrollbars: false,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 40.0,
                  ),
                  child: AnimatedBuilder(
                    animation: _fadeController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value,
                        child: Transform.translate(
                          offset: Offset(0, _translateAnimation.value),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 450),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Image.asset(
                              'assets/logo.png',
                              height: 100,
                              errorBuilder: (context, error, stackTrace) {
                                return Text(
                                  "RoboLearn",
                                  style: theme.textTheme.displayMedium,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),

                          Text(
                            "RoboLearn",
                            style: theme.textTheme.displaySmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),

                          Text(
                            "Learn robotics, track progress, never miss a workshop",
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),

                          Text(
                            "Welcome back! Login to continue",
                            style: theme.textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),

                          AnimatedInteractiveCard(
                            padding: const EdgeInsets.all(30.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  "User Portal",
                                  style: theme.textTheme.titleLarge,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),

                                TextField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    labelText: "Email",
                                    prefixIcon: Icon(Icons.email_outlined),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                TextField(
                                  controller: passwordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    labelText: "Password",
                                    prefixIcon: Icon(Icons.lock_outline),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: isResettingPassword
                                        ? null
                                        : forgotPassword,
                                    child: isResettingPassword
                                        ? const Text("Sending...")
                                        : const Text("Forgot Password?"),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                ElevatedButton(
                                  onPressed: isLoading ? null : loginUser,
                                  child: isLoading
                                      ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                      : const Text("LOGIN"),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don’t have an account? ",
                                style: theme.textTheme.bodyMedium,
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SignUpScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Sign Up",
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}