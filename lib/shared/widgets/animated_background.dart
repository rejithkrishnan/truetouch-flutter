import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';

class AnimatedBackground extends StatelessWidget {
  final String imagePath;
  // Controls how extreme the crop/scale is when drifting.
  // 1.1 means we scale to 110% of screen size to allow panning.
  final double scaleFactor;

  const AnimatedBackground({
    super.key,
    required this.imagePath,
    this.scaleFactor = 1.1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.pageBg,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // If the image fails to load, the pageBg color behind it will show.
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          )
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          // Slowly drift in scale and position over 20 seconds
          .scale(
            duration: 20.seconds,
            curve: Curves.easeInOutSine,
            begin: const Offset(1.0, 1.0),
            end: Offset(scaleFactor, scaleFactor),
          )
          .moveX(
            duration: 25.seconds,
            curve: Curves.easeInOutSine,
            begin: 0,
            end: 15,
          )
          .moveY(
            duration: 18.seconds,
            curve: Curves.easeInOutSine,
            begin: 0,
            end: 10,
          ),
        ],
      ),
    );
  }
}
