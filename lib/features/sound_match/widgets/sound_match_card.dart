import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/content_item.dart';
import '../../../shared/widgets/breathing_widget.dart';
import '../../../shared/widgets/premium_animated_text.dart';

class SoundMatchCard extends StatelessWidget {
  final ContentItem item;
  final bool isSelected;
  final bool isCorrect;
  final VoidCallback onTap;

  const SoundMatchCard({
    super.key,
    required this.item,
    required this.isSelected,
    required this.isCorrect,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BreathingWidget(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15), // Glassmorphism
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected 
                ? (isCorrect ? AppColors.softMint : AppColors.softCoral)
                : Colors.white.withValues(alpha: 0.2),
              width: isSelected ? 4 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Image.asset(
                    item.imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // Show label only on success or when specifically revealed
              if (isSelected && isCorrect)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: PremiumAnimatedText(
                    text: item.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.titleText,
                    ),
                    animationType: AnimationType.bobbing,
                    hasDrift: true,
                  ),
                ),
            ],
          ),
        )
        .animate(target: isSelected ? 1 : 0)
        .scale(
          duration: 300.ms,
          curve: Curves.easeIn,
          begin: const Offset(1, 1),
          end: const Offset(0.9, 0.9),
        )
        .then()
        .scale(
          duration: 300.ms,
          curve: Curves.easeOut,
          end: const Offset(1 / 0.9, 1 / 0.9),
        )
        .animate(target: isSelected && !isCorrect ? 1 : 0)
        .shake(duration: 500.ms, curve: Curves.easeInOut),
      ),
    );
  }
}
