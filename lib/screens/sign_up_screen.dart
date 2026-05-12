import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/tech_background_animation.dart';
import '../widgets/animated_interactive_card.dart';
import 'home_screen.dart';
import 'admin_screen.dart';
import '../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _translateAnimation;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();

  String _selectedRole = 'student';
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

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.beige,
      body: Stack(
        children: [
          // Background Animation
          const Positioned.fill(child: TechBackgroundAnimation()),

          // Main Content
          SafeArea(
            child: Center(
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
                        // 🔷 App Logo area
                        Center(
                          child: Image.asset(
                            'assets/logo.png',
                            height: 80,
                            errorBuilder: (context, error, stackTrace) {
                              return Text(
                                "RoboLearn",
                                style: theme.textTheme.displaySmall,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            "Create Account",
                            style: theme.textTheme.displaySmall,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            "Sign up to get started",
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
                                "Registration",
                                style: theme.textTheme.titleLarge,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),

                              // 👤 Name Field
                              TextField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  labelText: "Name",
                                  prefixIcon: const Icon(Icons.person_outline),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // 📧 Email Field
                              TextField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  labelText: "Email",
                                  prefixIcon: const Icon(Icons.email_outlined),
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
                              const SizedBox(height: 20),

                              // 🎭 Role Selection
                              DropdownButtonFormField<String>(
                                value: _selectedRole,
                                decoration: InputDecoration(
                                  labelText: "Role",
                                  prefixIcon: const Icon(Icons.badge_outlined),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'student',
                                    child: Text("Student"),
                                  ),
                                  DropdownMenuItem(
                                    value: 'committee',
                                    child: Text("Committee Member"),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _selectedRole = value);
                                  }
                                },
                              ),
                              const SizedBox(height: 32),

                              // 🔘 Sign Up Button
                              ElevatedButton(
                                onPressed: _isLoading
                                    ? null
                                    : () async {
                                        setState(() => _isLoading = true);
                                        String name = nameController.text.trim();
                                        String email = emailController.text.trim();
                                        String password = passwordController.text.trim();

                                        final user = await authService.signUp(
                                          email: email,
                                          password: password,
                                          name: name,
                                          role: _selectedRole,
                                        );

                                        if (user != null) {
                                          if (_selectedRole == 'committee') {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const AdminScreen(),
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
                                              content: Text("Sign Up Failed. Try again."),
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
                                    : const Text("SIGN UP"),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        // 🧾 Login Options
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: theme.textTheme.bodyMedium,
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Login",
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
        ],
      ),
    );
  }
}
