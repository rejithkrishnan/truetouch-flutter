import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum AnimationType {
  bobbing, // Up and down (TrueTouch Title style)
  drifting, // Organic X/Y drift (Card style)
  none
}

class PremiumAnimatedText extends StatefulWidget {
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
  /// Optional trigger value to re-run entrance/pop animations without resetting the drift movement.
  final int? trigger;

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
    this.trigger,
  });

  @override
  State<PremiumAnimatedText> createState() => _PremiumAnimatedTextState();
}

class _PremiumAnimatedTextState extends State<PremiumAnimatedText> {
  @override
  Widget build(BuildContext context) {
    if (!widget.animateCharacters) {
      return _buildCharacter(widget.text, 0, context);
    }

    final letters = widget.text.characters.toList();
    Widget row = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(letters.length, (i) {
        if (letters[i] == ' ') return const SizedBox(width: 8);
        return KeyedSubtree(
          key: ValueKey('char_${i}_${widget.trigger}'),
          child: _buildCharacter(letters[i], i, context),
        );
      }),
    );

    // Apply Row-level loop if drifting is enabled or requested
    if (widget.hasDrift || widget.animationType == AnimationType.drifting) {
      row = row
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveX(
            begin: -widget.driftAmount,
            end: widget.driftAmount,
            duration: 4000.ms,
            curve: Curves.easeInOutSine,
          )
          .moveY(
            begin: widget.driftAmount,
            end: -widget.driftAmount,
            duration: 5200.ms,
            curve: Curves.easeInOutSine,
          );
    }

    return row;
  }

  Widget _buildCharacter(String char, int index, BuildContext context) {
    // 1. Static Text
    Widget character = Text(char, style: widget.style, textAlign: widget.textAlign);

    // 2. Initial ENTRANCE Animation (Fade + Scale)
    character = character.animate().fadeIn(
          delay: (index * widget.staggerDelay.inMilliseconds).ms,
          duration: 600.ms,
        ).scale(
          delay: (index * widget.staggerDelay.inMilliseconds).ms,
          duration: 900.ms,
          curve: Curves.elasticOut,
          begin: const Offset(0.5, 0.5),
          end: const Offset(1.0, 1.0),
        );

    // 3. Continuous LOOP Animation (Character level)
    if (widget.animationType == AnimationType.bobbing) {
      character = character
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(
            begin: 0,
            end: -widget.bobAmount,
            duration: 1200.ms,
            delay: (index * widget.staggerDelay.inMilliseconds).ms,
            curve: Curves.easeInOut,
          );
    }

    // 4. Shimmer Overlay (Continuous)
    if (widget.hasShimmer) {
      character = character
          .animate(onPlay: (c) => c.repeat())
          .shimmer(
            duration: 2600.ms,
            delay: (widget.shimmerDelay ?? (index * widget.staggerDelay.inMilliseconds).ms),
            color: Colors.white.withValues(alpha: 0.5),
          );
    }

    return character;
  }
}
