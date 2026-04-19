import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers.dart';

class CategoryCelebrationOverlay extends ConsumerStatefulWidget {
  final String mainText;
  final String subText;
  final VoidCallback onDismiss;
  final Color trophyColor;
  final Color trophyBgColor;

  const CategoryCelebrationOverlay({
    super.key,
    required this.mainText,
    required this.subText,
    required this.onDismiss,
    this.trophyColor = Colors.amber,
    this.trophyBgColor = Colors.white,
  });

  @override
  ConsumerState<CategoryCelebrationOverlay> createState() => _CategoryCelebrationOverlayState();
}

class _CategoryCelebrationOverlayState extends ConsumerState<CategoryCelebrationOverlay> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();

    // Play the reward sound
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioServiceProvider).playSound('assets/audio/tropy.mp3');
    });
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
                      color: widget.trophyBgColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.trophyColor.withValues(alpha: 0.5),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.emoji_events_rounded,
                      size: 150,
                      color: widget.trophyColor,
                    ),
                  )
                  .animate()
                  .scale(
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                    begin: const Offset(0, 0),
                  )
                  .then()
                  .shimmer(duration: 2.seconds) // Looping shimmer
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 1.seconds),

                  const SizedBox(height: 48),

                  // Celebration Text
                  Text(
                    widget.mainText,
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
                  .fadeIn(delay: 300.ms)
                  .then()
                  .shimmer(duration: 2.seconds) // Looping shimmer on text
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 1.5.seconds),

                  const SizedBox(height: 12),

                  Text(
                    widget.subText,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 600.ms)
                  .then()
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .shake(hz: 1, rotation: 0.03), // Gentle wiggle

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
