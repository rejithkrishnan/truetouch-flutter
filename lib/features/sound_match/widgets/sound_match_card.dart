import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/content_item.dart';
import '../../../shared/widgets/breathing_widget.dart';

class SoundMatchCard extends StatefulWidget {
  final ContentItem item;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrongHistory;
  final VoidCallback onTap;

  const SoundMatchCard({
    super.key,
    required this.item,
    required this.isSelected,
    required this.isCorrect,
    required this.isWrongHistory,
    required this.onTap,
  });

  @override
  State<SoundMatchCard> createState() => _SoundMatchCardState();
}

class _SoundMatchCardState extends State<SoundMatchCard>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;

  /// One-shot shake controller — only plays forward, never reverses
  late AnimationController _shakeController;

  /// Accent color locked in initState — stable across rebuilds
  late Color _accentColor;
  bool _isPressing = false;

  @override
  void initState() {
    super.initState();
    _accentColor = AppColors.nurseryPalette[
        Random().nextInt(AppColors.nurseryPalette.length)];
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 15));
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void didUpdateWidget(SoundMatchCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Confetti: trigger when THIS card becomes correct
    if (!oldWidget.isCorrect && widget.isCorrect && _isPressing) {
      _confettiController.play();
    }

    // Shake: only when transitioning into wrong-selected state (never on deselect)
    final wasWrong = oldWidget.isSelected && !oldWidget.isCorrect;
    final isWrong = widget.isSelected && !widget.isCorrect;
    if (!wasWrong && isWrong) {
      _shakeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Color get _borderColor {
    if (widget.isSelected) {
      return widget.isCorrect ? AppColors.softMint : AppColors.softCoral;
    }
    return Colors.white.withValues(alpha: 0.25);
  }

  @override
  Widget build(BuildContext context) {
    return BreathingWidget(
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressing = true);
          widget.onTap();
          if (widget.isCorrect) _confettiController.play();
        },
        onTapUp: (_) async {
          setState(() => _isPressing = false);
          await Future.delayed(const Duration(milliseconds: 250));
          if (!_isPressing) _confettiController.stop();
        },
        onTapCancel: () {
          setState(() => _isPressing = false);
          _confettiController.stop();
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _borderColor,
                  width: widget.isSelected ? 1.5 : 0.5,
                ),
                boxShadow: [
                  if (widget.isWrongHistory && !widget.isSelected)
                    BoxShadow(
                      color: AppColors.softCoral.withValues(alpha: 0.35),
                      blurRadius: 18,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    )
                  else
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    color: Colors.white,
                    child: Image.asset(
                      widget.item.imagePath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            )
                // Uses controller — plays once forward on wrong tap, never reverses
                .animate(controller: _shakeController, autoPlay: false)
                .shake(duration: 500.ms, curve: Curves.easeInOut),

            // Confetti
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
