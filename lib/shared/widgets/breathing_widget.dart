import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Wraps any child widget in a subtle, randomized idle animation
/// consisting of scale (breathing) and rotation (sway).
class BreathingWidget extends StatelessWidget {
  final Widget child;

  const BreathingWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Generate randomized values at build time so each instance looks organic.
    final rand = Random();
    
    // Duration between 3.0s and 5.0s for a very slow, calm breathe
    final duration = (3000 + rand.nextInt(2000)).ms; 
    
    // Max scale between 1.005 and 1.015 (extremely subtle)
    final maxScale = 1.005 + rand.nextDouble() * 0.01; 
    
    // Tilt between -0.01 rad and +0.01 rad
    final tilt = (rand.nextDouble() - 0.5) * 0.02; 

    return child.animate(onPlay: (controller) => controller.repeat(reverse: true))
      .scale(
        duration: duration,
        curve: Curves.easeInOutSine,
        begin: const Offset(1.0, 1.0),
        end: Offset(maxScale, maxScale),
      )
      .rotate(
        duration: duration,
        curve: Curves.easeInOutSine,
        begin: -tilt,
        end: tilt,
      );
  }
}
