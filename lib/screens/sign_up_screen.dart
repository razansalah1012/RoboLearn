import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/tech_background_animation.dart';
import '../widgets/animated_interactive_card.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

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
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _translateAnimation = Tween<double>(
      begin: 30,
      end: 0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _fadeController.forward();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> signUpUser() async {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields.")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await AuthService().registerUser(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        role: 'student',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account created successfully. Please login."),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.beige,
      body: Stack(
        children: [
          const Positioned.fill(child: TechBackgroundAnimation()),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 40,
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Image.asset('assets/logo.png', height: 80),
                        const SizedBox(height: 12),
                        Text(
                          "Create Account",
                          style: theme.textTheme.displaySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Sign up as a student to start learning",
                          style: theme.textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        AnimatedInteractiveCard(
                          padding: const EdgeInsets.all(30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                "Student Registration",
                                style: theme.textTheme.titleLarge,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              TextField(
                                controller: nameController,
                                decoration: const InputDecoration(
                                  labelText: "Name",
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                              ),
                              const SizedBox(height: 20),
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
                              const SizedBox(height: 32),
                              ElevatedButton(
                                onPressed: isLoading ? null : signUpUser,
                                child: isLoading
                                    ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                    : const Text("SIGN UP"),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: theme.textTheme.bodyMedium,
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Login"),
                            ),
                          ],
                        ),
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