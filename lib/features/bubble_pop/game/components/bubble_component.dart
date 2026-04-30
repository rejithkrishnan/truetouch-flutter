import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class BubbleComponent extends PositionComponent
    with TapCallbacks, CollisionCallbacks {
  final String text;
  final double radius;
  final double screenWidth;
  final double screenHeight;
  final void Function(String) onPop;
  final void Function() onJiggle;
  final double speedMultiplier;

  final Random _random = Random();
  late Vector2 velocity;
  late double _baseSpeedY;
  late double _wobbleSpeed;
  late double _wobbleAmount;
  double _time = 0;

  bool _isJiggling = false;
  double _jiggleTimer = 0;

  bool _isPopped = false;
  late Color _baseColor;

  BubbleComponent({
    required this.text,
    required this.radius,
    required Vector2 position,
    required this.screenWidth,
    required this.screenHeight,
    required this.onPop,
    required this.onJiggle,
    this.speedMultiplier = 1.0,
  }) : super(
         position: position,
         size: Vector2.all(radius * 2),
         anchor: Anchor.center,
       ) {
    _baseSpeedY = (_random.nextDouble() * 30 + 50) * speedMultiplier; // 50 to 80 pixels per second
    velocity = Vector2(0, -_baseSpeedY);
    _wobbleSpeed = _random.nextDouble() * 2 + 1;
    _wobbleAmount = _random.nextDouble() * 20 + 10;

    // Pick a random nursery color for the bubble tint
    _baseColor =
        AppColors.nurseryPalette[_random.nextInt(
          AppColors.nurseryPalette.length,
        )];
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add exact circular hit box for collisions and taps
    add(CircleHitbox());

    // Add Text
    final textPaint = TextPaint(
      style: const TextStyle(
        fontSize: 64,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        shadows: [
          Shadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4),
        ],
        fontFamily: 'Quicksand',
      ),
    );

    final textComponent = TextComponent(
      text: text,
      textRenderer: textPaint,
      anchor: Anchor.center,
      position: size / 2,
    );
    add(textComponent);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isPopped) return;

    _time += dt;

    final bool isUnderwater = y > screenHeight * 0.75;
    final double targetSpeedY = isUnderwater ? -(_baseSpeedY * 2.5) : -_baseSpeedY;

    // Smoothly adjust vertical velocity towards target speed
    if (velocity.y < targetSpeedY) {
      velocity.y += 150 * dt; // Slow down when hitting air
      if (velocity.y > targetSpeedY) velocity.y = targetSpeedY;
    } else if (velocity.y > targetSpeedY) {
      velocity.y -= 250 * dt; // Speed up while underwater
      if (velocity.y < targetSpeedY) velocity.y = targetSpeedY;
    }

    // Softly recover horizontal velocity back to 0
    if (velocity.x > 0) {
      velocity.x = max(0.0, velocity.x - 50 * dt);
    } else if (velocity.x < 0) {
      velocity.x = min(0.0, velocity.x + 50 * dt);
    }

    // Move via velocity
    position += velocity * dt;

    // Bounce off screen edges (left and right)
    if (position.x - radius < 0) {
      position.x = radius;
      velocity.x = velocity.x.abs(); // Force right
    } else if (position.x + radius > screenWidth) {
      position.x = screenWidth - radius;
      velocity.x = -velocity.x.abs(); // Force left
    }

    // Apply Jiggle or organic wobble
    if (_isJiggling) {
      _jiggleTimer -= dt;
      if (_jiggleTimer <= 0) {
        _isJiggling = false;
      } else {
        x += sin(_time * 60) * 100 * dt; // Rapid shake
      }
    } else {
      x += sin(_time * _wobbleSpeed) * (_wobbleAmount * dt);
    }

    // Remove if it goes off screen
    if (y < -radius * 2) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    if (_isPopped) return;

    // Glassmorphism Base
    final paint =
        Paint()
          ..color = _baseColor.withValues(alpha: 0.6)
          ..style = PaintingStyle.fill;

    final borderPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    final center = Offset(radius, radius);
    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(center, radius, borderPaint);

    // Reflection Highlight (top left)
    final highlightPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.6)
          ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromLTWH(radius * 0.4, radius * 0.3, radius * 0.6, radius * 0.3),
      highlightPaint,
    );
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    final centerPoint = size / 2;
    return point.distanceTo(centerPoint) <= radius;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is BubbleComponent) {
      // Vector pointing away from the other bubble
      final pushDirection = (position - other.position).normalized();

      // Apply bounce force
      velocity = pushDirection * 60.0;

      // Move slightly to prevent getting stuck inside each other
      position += pushDirection * 2.0;
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_isPopped) return;

    // Only allow popping if the bubble is at least 25% up from the bottom of the screen
    if (y > screenHeight * 0.75) {
      if (!_isJiggling) {
        _isJiggling = true;
        _jiggleTimer = 0.4; // Jiggle for 400ms
        onJiggle(); // Trigger tactile feedback
      }
      return;
    }

    _isPopped = true;

    onPop(text);
    _spawnConfetti();
    removeFromParent();
  }

  void _spawnConfetti() {
    parent?.add(
      ParticleSystemComponent(
        particle: Particle.generate(
          count: 15,
          lifespan: 4.0,
          generator: (i) {
            final angle = _random.nextDouble() * 2 * pi;
            final speed = _random.nextDouble() * 150 + 50;
            final velocity = Vector2(cos(angle), sin(angle)) * speed;
            
            final waterColors = [
              const Color(0xFF73A6FF).withValues(alpha: 0.8), // Soft Sky
              const Color(0xFFB3D4FF).withValues(alpha: 0.8), // Lighter blue
              Colors.white.withValues(alpha: 0.8),
              Colors.white.withValues(alpha: 0.5),
            ];
            final color = waterColors[_random.nextInt(waterColors.length)];
            final particleRadius = _random.nextDouble() * 4 + 2.0;

            return AcceleratedParticle(
              acceleration: Vector2(0, 300), // Water drops fall faster
              speed: velocity,
              position: position.clone(), // Start at bubble center
              child: CircleParticle(
                radius: particleRadius, 
                paint: Paint()..color = color,
              ),
            );
          },
        ),
      ),
    );
  }
}
