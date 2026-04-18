import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets/animated_background.dart';

class SoundMatchScreen extends StatelessWidget {
  const SoundMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(
            imagePath: 'assets/images/backgrounds/home_hub_bg.png', 
            scaleFactor: 1.15,
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Top Bar (Category Title & Home Button)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.home_rounded, size: 40, color: AppColors.titleText),
                        onPressed: () => context.pop(),
                      ),
                      Text(
                        'Sound Match',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 40),
                      ),
                      const SizedBox(width: 40), 
                    ],
                  ),
                ),
                
                Expanded(
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        // Play random sound logic here (coming soon)
                      },
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          color: AppColors.cardWhite,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 30,
                              offset: Offset(0, 10),
                            ),
                          ],
                          border: Border.all(color: AppColors.titleText.withValues(alpha: 0.1), width: 4),
                        ),
                        child: const Icon(
                          Icons.volume_up_rounded,
                          size: 150,
                          color: AppColors.titleText,
                        ),
                      )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(
                        duration: 800.ms, 
                        curve: Curves.easeInOutSine, 
                        end: const Offset(1.1, 1.1),
                      ),
                    ),
                  ),
                ),
                Text(
                  'Puzzle game coming soon!',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
