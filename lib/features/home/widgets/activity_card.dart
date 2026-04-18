import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/module.dart';
import '../../../shared/widgets/breathing_widget.dart';
import 'package:go_router/go_router.dart';

class ActivityCard extends StatelessWidget {
  final Module module;

  const ActivityCard({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return BreathingWidget(
      child: GestureDetector(
        onTap: () {
          // Play click sound/haptics in future if desired
          context.push(module.route);
        },
        child: Container(
          decoration: cardDecoration,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  module.icon,
                  fit: BoxFit.cover,
                  // Fallback
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(
                      Icons.extension_rounded,
                      size: 80,
                      color: AppColors.subtitleText,
                    ),
                  ),
                ),
                // Image contains the text baked into the thumbnail
              ],
            ),
          ),
        ),
      ),
    );
  }
}
