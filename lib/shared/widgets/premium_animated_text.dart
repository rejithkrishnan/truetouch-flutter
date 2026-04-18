import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum AnimationType {
  bobbing, // Up and down (TrueTouch Title style)
  drifting, // Organic X/Y drift (Card style)
  none
}

class PremiumAnimatedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final bool animateCharacters;
  final AnimationType animationType;
  final bool hasShimmer;
  final Duration staggerDelay;
  final Duration? shimmerDelay;
  final double bobAmount;
  final double driftAmount;
  final bool hasDrift;

  const PremiumAnimatedText({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.center,
    this.animateCharacters = true,
    this.animationType = AnimationType.bobbing,
    this.hasShimmer = true,
    this.hasDrift = false,
    this.staggerDelay = const Duration(milliseconds: 90),
    this.shimmerDelay,
    this.bobAmount = 7.0,
    this.driftAmount = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    if (!animateCharacters) {
      return _buildCharacter(text, 0, context);
    }

    final letters = text.characters.toList();
    Widget row = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(letters.length, (i) {
        if (letters[i] == ' ') return const SizedBox(width: 8);
        return _buildCharacter(letters[i], i, context);
      }),
    );

    // Apply Row-level loop if drifting is enabled or requested
    if (hasDrift || animationType == AnimationType.drifting) {
      row = row
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveX(
            begin: -driftAmount,
            end: driftAmount,
            duration: 4000.ms,
            curve: Curves.easeInOutSine,
          )
          .moveY(
            begin: driftAmount,
            end: -driftAmount,
            duration: 5200.ms,
            curve: Curves.easeInOutSine,
          );
    }

    return row;
  }

  Widget _buildCharacter(String char, int index, BuildContext context) {
    // 1. Static Text
    Widget character = Text(char, style: style, textAlign: textAlign);

    // 2. Initial ENTRANCE Animation (Fade + Scale)
    // This happens once when the widget is built
    character = character.animate().fadeIn(
          delay: (index * staggerDelay.inMilliseconds).ms,
          duration: 600.ms,
        ).scale(
          delay: (index * staggerDelay.inMilliseconds).ms,
          duration: 900.ms,
          curve: Curves.elasticOut,
          begin: const Offset(0.5, 0.5),
          end: const Offset(1.0, 1.0),
        );

    // 3. Continuous LOOP Animation (Character level)
    if (animationType == AnimationType.bobbing) {
      character = character
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(
            begin: 0,
            end: -bobAmount,
            duration: 1200.ms,
            delay: (index * staggerDelay.inMilliseconds).ms,
            curve: Curves.easeInOut,
          );
    }

    // 4. Shimmer Overlay (Continuous)
    if (hasShimmer) {
      character = character
          .animate(onPlay: (c) => c.repeat())
          .shimmer(
            duration: 2600.ms,
            delay: (shimmerDelay ?? (index * staggerDelay.inMilliseconds).ms),
            color: Colors.white.withValues(alpha: 0.5),
          );
    }

    return character;
  }
}
