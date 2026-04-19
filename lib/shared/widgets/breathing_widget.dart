import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Wraps any child widget in a subtle, randomized idle animation
/// consisting of scale (breathing) and rotation (sway).
class BreathingWidget extends StatefulWidget {
  final Widget child;

  const BreathingWidget({super.key, required this.child});

  @override
  State<BreathingWidget> createState() => _BreathingWidgetState();
}

class _BreathingWidgetState extends State<BreathingWidget> {
  late Duration _duration;
  late double _maxScale;
  late double _tilt;

  @override
  void initState() {
    super.initState();
    final rand = Random();
    
    // Duration between 3.0s and 5.0s for a very slow, calm breathe
    _duration = (3000 + rand.nextInt(2000)).ms; 
    
    // Max scale between 1.005 and 1.015 (extremely subtle)
    _maxScale = 1.005 + rand.nextDouble() * 0.01; 
    
    // Tilt between -0.01 rad and +0.01 rad
    _tilt = (rand.nextDouble() - 0.5) * 0.02; 
  }

  @override
  Widget build(BuildContext context) {
    return widget.child.animate(onPlay: (controller) => controller.repeat(reverse: true))
      .scale(
        duration: _duration,
        curve: Curves.easeInOutSine,
        begin: const Offset(1.0, 1.0),
        end: Offset(_maxScale, _maxScale),
      )
      .rotate(
        duration: _duration,
        curve: Curves.easeInOutSine,
        begin: -_tilt,
        end: _tilt,
      );
  }
}
