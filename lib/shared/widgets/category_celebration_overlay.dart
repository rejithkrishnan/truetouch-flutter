import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../../core/theme/app_theme.dart';

class CategoryCelebrationOverlay extends StatefulWidget {
  final String categoryName;
  final VoidCallback onDismiss;

  const CategoryCelebrationOverlay({
    super.key,
    required this.categoryName,
    required this.onDismiss,
  });

  @override
  State<CategoryCelebrationOverlay> createState() => _CategoryCelebrationOverlayState();
}

class _CategoryCelebrationOverlayState extends State<CategoryCelebrationOverlay> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.7),
      child: GestureDetector(
        onTap: widget.onDismiss,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // Center Content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // The Trophy Icon
                  Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withValues(alpha: 0.5),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      size: 150,
                      color: Colors.amber,
                    ),
                  )
                  .animate()
                  .scale(
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                    begin: const Offset(0, 0),
                  )
                  .shimmer(delay: 800.ms, duration: 1.seconds),

                  const SizedBox(height: 48),

                  // Celebration Text
                  Text(
                    'Great Job!',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 64,
                      shadows: [
                        const Shadow(
                          color: Colors.black45,
                          offset: Offset(0, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .slideY(begin: 1.0, end: 0, delay: 300.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                  .fadeIn(delay: 300.ms),

                  const SizedBox(height: 12),

                  Text(
                    'You finished ${widget.categoryName}!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 600.ms),

                  const SizedBox(height: 60),

                  // Continue button area
                  Text(
                    'Tap anywhere to keep playing',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .fadeIn(duration: 800.ms),
                ],
              ),
            ),

            // Confetti - Left Side
            Align(
              alignment: Alignment.bottomLeft,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: -3.14 / 4, // 45 degrees up and right
                emissionFrequency: 0.05,
                numberOfParticles: 20,
                maxBlastForce: 40,
                minBlastForce: 20,
                gravity: 0.1,
                colors: AppColors.nurseryPalette,
              ),
            ),

            // Confetti - Right Side
            Align(
              alignment: Alignment.bottomRight,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: -3 * 3.14 / 4, // 135 degrees up and left
                emissionFrequency: 0.05,
                numberOfParticles: 20,
                maxBlastForce: 40,
                minBlastForce: 20,
                gravity: 0.1,
                colors: AppColors.nurseryPalette,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
