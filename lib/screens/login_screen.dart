import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/tech_background_animation.dart';
import '../widgets/animated_interactive_card.dart';
import 'home_screen.dart';
import 'sign_up_screen.dart';
import '../services/auth_service.dart';
import 'committee_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _translateAnimation;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Page Load Animations: 0.6s ease transition
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _translateAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    // Start animation on load
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Responsive Grid/Flexible Typography basics
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.beige, // Eye comfort: Beige backgrounds
      body: Stack(
        children: [
          // Background Animation
          const Positioned.fill(child: TechBackgroundAnimation()),

          // Main Content
          SafeArea(
            child: Center(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(
                  context,
                ).copyWith(scrollbars: false),
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
                      constraints: const BoxConstraints(
                        maxWidth: 450,
                      ), // Mobile-first & Desktop-friendly limit
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 🔷 App Logo area
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
                          Center(
                            child: Text(
                              "RoboLearn",
                              style: theme.textTheme.displaySmall,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Center(
                            child: Text(
                              "Learn robotics, track progress, never miss a workshop",
                              style: theme.textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              "Welcome back! Login to continue",
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Form Encapsulated inside Animated Interactive Card
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

                                // 📧 Email Field
                                TextField(
                                  controller: emailController,
                                  decoration: InputDecoration(
                                    labelText: "Email",
                                    prefixIcon: const Icon(
                                      Icons.email_outlined,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // 🔒 Password Field
                                TextField(
                                  controller: passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: "Password",
                                    prefixIcon: const Icon(Icons.lock_outline),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Forgot Password
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {},
                                    child: const Text("Forgot Password?"),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // 🔘 Login Button
                                ElevatedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () async {
                                          setState(() => _isLoading = true);
                                          String email = emailController.text.trim();
                                          String password = passwordController.text.trim();

                                          final user = await authService.signIn(email, password);

                                          if (user != null) {
                                            final userData = await authService.getUserData(user.uid);
                                            final String role = userData?.role ?? 'student';

                                            if (role == "committee") {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const CommitteeDashboard(),
                                                ),
                                              );
                                            } else {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const HomeScreen(),
                                                ),
                                              );
                                            }
                                          } else {
                                            setState(() => _isLoading = false);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text("Login Failed. Please check your credentials."),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        },
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text("LOGIN"),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),

                          // 🧾 Sign Up
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
                                      builder: (context) =>
                                          const SignUpScreen(),
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
