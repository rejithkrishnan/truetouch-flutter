import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class WaterComponent extends PositionComponent {
  double _time = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    if (size.x == 0 || size.y == 0) return;

    // The "Soft Sky" from the Nursery Palette, but highly translucent
    final paint =
        Paint()
          ..color = const Color(0xFF73A6FF).withValues(alpha: 0.75)
          ..style = PaintingStyle.fill;

    final path = Path();
    const waveHeight = 10.0;
    const waveLength = 80.0;

    // Start drawing the wave at the top of the component's bounding box
    path.moveTo(0, waveHeight * sin(_time * 2));

    for (double i = 0; i <= size.x; i += 5) {
      // Create a fluid sine wave across the width
      path.lineTo(i, waveHeight * sin((i / waveLength) + (_time * 1.5)));
    }

    path.lineTo(size.x, size.y); // Down to bottom right
    path.lineTo(0, size.y); // Across to bottom left
    path.close();

    canvas.drawPath(path, paint);

    // A slightly stronger stroke for the surface tension
    final strokePaint =
        Paint()
          ..color = const Color(0xFF73A6FF).withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4;

    final surfacePath = Path();
    surfacePath.moveTo(0, waveHeight * sin(_time * 2));
    for (double i = 0; i <= size.x; i += 5) {
      surfacePath.lineTo(i, waveHeight * sin((i / waveLength) + (_time * 1.5)));
    }
    canvas.drawPath(surfacePath, strokePaint);
  }
}
