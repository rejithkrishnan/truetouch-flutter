import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'components/bubble_component.dart';
import 'components/water_component.dart';

class BubblePopGame extends FlameGame with HasCollisionDetection {
  final void Function(String value) onPop;
  final void Function() onJiggle;
  
  final Random _random = Random();
  
  final List<String> _letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
  final List<String> _numbers = '12345678910'.split('');
  
  List<String> _availablePool = [];
  
  final bool showLetters;
  final bool showNumbers;
  final int maxBubbles;
  final double speedMultiplier;

  BubblePopGame({
    required this.onPop,
    required this.onJiggle,
    this.showLetters = true,
    this.showNumbers = true,
    this.maxBubbles = 5,
    this.speedMultiplier = 1.0,
  });

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Render the water safe zone (bottom 25%) in front of the bubbles
    final water = WaterComponent()
      ..position = Vector2(0, size.y * 0.75)
      ..size = Vector2(size.x, size.y * 0.25)
      ..priority = 10;
    add(water);

    // Spawn initial bubbles distributed across the screen height
    for (int i = 0; i < maxBubbles; i++) {
      _spawnBubble(initialYOffset: i * (150.0 / (maxBubbles / 5)));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Keep exactly maxBubbles on screen at all times
    final bubbleCount = children.whereType<BubbleComponent>().length;
    if (bubbleCount < maxBubbles) {
      _spawnBubble();
    }
  }

  void _spawnBubble({double initialYOffset = 0}) {
    if (size.x == 0 || size.y == 0) return;

    final radius = _random.nextDouble() * 40 + 60; // 60 to 100 pixels radius
    final xPosition = _random.nextDouble() * (size.x - radius * 2) + radius;
    final yPosition = size.y + radius - initialYOffset;
    
    // Draw from a shuffled pool to prevent repeats
    if (_availablePool.isEmpty) {
      if (showLetters) _availablePool.addAll(_letters);
      if (showNumbers) _availablePool.addAll(_numbers);
      // Fallback if both are disabled somehow
      if (_availablePool.isEmpty) _availablePool.addAll(_letters);
      _availablePool.shuffle(_random);
    }
    final String text = _availablePool.removeLast();

    final bubble = BubbleComponent(
      text: text,
      radius: radius,
      position: Vector2(xPosition, yPosition),
      screenWidth: size.x,
      screenHeight: size.y,
      onPop: onPop,
      onJiggle: onJiggle,
      speedMultiplier: speedMultiplier,
    )..priority = 1; // Render in front of water
    
    add(bubble);
  }
}
