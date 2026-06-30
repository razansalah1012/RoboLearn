import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/brand_logo.dart';
import '../widgets/robotics_blueprint.dart';
import '../widgets/tech_background_animation.dart';
import 'login_screen.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.beige,
      body: Stack(
        children: [
          const Positioned.fill(child: TechBackgroundAnimation()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const BrandLogoLockup(markSize: 118, titleSize: 34),
                  const SizedBox(height: 26),
                  const RoboticsBlueprintVisual(height: 120),
                  const SizedBox(height: 22),
                  Text(
                    "Build Robotics Skills",
                    style: theme.textTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Learn robotics, join workshops, track your progress, and access club materials in one place.",
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text("GET STARTED"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
