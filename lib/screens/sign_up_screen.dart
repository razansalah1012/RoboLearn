import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/tech_background_animation.dart';
import '../widgets/animated_interactive_card.dart';
import 'student_home_screen.dart';
import 'committee_dashboard.dart';
import 'admin_home_screen.dart';
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

  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController matricController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final AuthService authService = AuthService();

  String _selectedRole = 'student';
  bool _isLoading = false;

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
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    matricController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final result = await authService.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        name: nameController.text.trim(),
        role: _selectedRole,
        matricNumber: matricController.text.trim().isEmpty ? null : matricController.text.trim(),
        phoneNumber: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
      );

      if (result == null) {
        // Success
        if (_selectedRole == 'committee') {
          // Committee members require approval
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Registration successful! Your committee account is pending admin approval."),
              backgroundColor: Colors.orange,
            ),
          );
          Navigator.pop(context); // Go back to login
        } else {
          // Redirect based on role
          Widget nextScreen;
          if (_selectedRole == 'admin') {
            nextScreen = const AdminHomeScreen();
          } else {
            nextScreen = const StudentHomeScreen();
          }
          
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => nextScreen),
            (route) => false,
          );
        }
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result),
            backgroundColor: Colors.red,
          ),
        );
      }
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
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Text(
                            "RoboLearn",
                            style: theme.textTheme.displaySmall,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            "Create Your Account",
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                        const SizedBox(height: 30),
                        AnimatedInteractiveCard(
                          padding: const EdgeInsets.all(24.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  "Registration Details",
                                  style: theme.textTheme.titleLarge,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                
                                // Name
                                TextFormField(
                                  controller: nameController,
                                  decoration: const InputDecoration(
                                    labelText: "Full Name",
                                    prefixIcon: Icon(Icons.person_outline),
                                  ),
                                  validator: (value) => value == null || value.isEmpty ? "Required" : null,
                                ),
                                const SizedBox(height: 16),

                                // Email
                                TextFormField(
                                  controller: emailController,
                                  decoration: const InputDecoration(
                                    labelText: "Email Address",
                                    prefixIcon: Icon(Icons.email_outlined),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return "Required";
                                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                      return "Invalid email format";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Password
                                TextFormField(
                                  controller: passwordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    labelText: "Password",
                                    prefixIcon: Icon(Icons.lock_outline),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return "Required";
                                    if (value.length < 6) return "Password must be at least 6 characters";
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Phone Number
                                TextFormField(
                                  controller: phoneController,
                                  decoration: const InputDecoration(
                                    labelText: "Phone Number",
                                    prefixIcon: Icon(Icons.phone_outlined),
                                  ),
                                  keyboardType: TextInputType.phone,
                                  validator: (value) => value == null || value.isEmpty ? "Required" : null,
                                ),
                                const SizedBox(height: 16),

                                // Matric Number
                                TextFormField(
                                  controller: matricController,
                                  decoration: const InputDecoration(
                                    labelText: "Matric Number (Optional for Admin)",
                                    prefixIcon: Icon(Icons.assignment_ind_outlined),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Role Selection
                                DropdownButtonFormField<String>(
                                  value: _selectedRole,
                                  decoration: const InputDecoration(
                                    labelText: "Role",
                                    prefixIcon: Icon(Icons.badge_outlined),
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 'student', child: Text("Student")),
                                    DropdownMenuItem(value: 'committee', child: Text("Committee Member")),
                                    DropdownMenuItem(value: 'admin', child: Text("Admin")),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _selectedRole = value);
                                    }
                                  },
                                ),
                                const SizedBox(height: 32),

                                ElevatedButton(
                                  onPressed: _isLoading ? null : _handleSignUp,
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                        )
                                      : const Text("REGISTER"),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Already have an account? ", style: theme.textTheme.bodyMedium),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("Login", style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
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
