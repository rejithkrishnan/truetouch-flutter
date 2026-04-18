import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routing/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to Home Hub after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.go(AppRoutes.home);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splash,
      body: SizedBox.expand(
        child: Image.asset(
          'assets/images/splash_screen.png',
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          // Fallback if image doesn't exist yet
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Icon(
              Icons.child_care_rounded,
              size: 150,
              color: Colors.white,
            ),
          ),
        )
        .animate()
        .fade(duration: 1000.ms, curve: Curves.easeOut),
      ),
    );
  }
}
