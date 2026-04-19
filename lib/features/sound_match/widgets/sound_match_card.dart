import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/content_item.dart';
import '../../../shared/widgets/breathing_widget.dart';
import '../../../shared/widgets/premium_animated_text.dart';

class SoundMatchCard extends StatefulWidget {
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
  State<SoundMatchCard> createState() => _SoundMatchCardState();
}

class _SoundMatchCardState extends State<SoundMatchCard> {
  late ConfettiController _confettiController;
  bool _isPressing = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 15));
  }

  @override
  void didUpdateWidget(SoundMatchCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If we just found out this is correct AND the user is still holding it, shower!
    if (!oldWidget.isCorrect && widget.isCorrect && _isPressing) {
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BreathingWidget(
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressing = true);
          widget.onTap();
          
          // If it was already known to be correct (e.g. repeat tap), shower immediately
          if (widget.isCorrect) {
            _confettiController.play();
          }
        },
        onTapUp: (_) async {
          setState(() => _isPressing = false);
          // Wait a tiny bit so quick taps still show some confetti
          await Future.delayed(const Duration(milliseconds: 250));
          if (!_isPressing) {
            _confettiController.stop();
          }
        },
        onTapCancel: () {
          setState(() => _isPressing = false);
          _confettiController.stop();
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15), // Glassmorphism
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: widget.isSelected 
                    ? (widget.isCorrect ? AppColors.softMint : AppColors.softCoral)
                    : Colors.white.withValues(alpha: 0.2),
                  width: widget.isSelected ? 4 : 2,
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
                        widget.item.imagePath,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  if (widget.isSelected && widget.isCorrect)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: PremiumAnimatedText(
                        text: widget.item.name,
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
                .animate(target: widget.isSelected && !widget.isCorrect ? 1 : 0)
                .shake(duration: 500.ms, curve: Curves.easeInOut),

            // Confetti spray
            Align(
              alignment: Alignment.center,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0.1,
                numberOfParticles: 20,
                maxBlastForce: 15,
                minBlastForce: 5,
                gravity: 0.05,
                colors: AppColors.nurseryPalette,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
