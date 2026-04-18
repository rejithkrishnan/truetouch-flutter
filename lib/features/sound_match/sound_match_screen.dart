import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets/animated_background.dart';
import '../../shared/widgets/premium_animated_text.dart';
import '../../shared/widgets/category_celebration_overlay.dart';
import 'providers/sound_match_provider.dart';
import 'widgets/sound_match_card.dart';

class SoundMatchScreen extends ConsumerWidget {
  const SoundMatchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(soundMatchProvider);

    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(
            imagePath: 'assets/images/backgrounds/home_hub_bg.png', 
            scaleFactor: 1.15,
          ),
          
          SafeArea(
            child: stateAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (state) => Stack(
                children: [
                  Column(
                    children: [
                      // Top Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.home_rounded, size: 40, color: AppColors.titleText),
                              onPressed: () => context.pop(),
                            ),
                            const PremiumAnimatedText(
                              text: 'Sound Match',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                color: AppColors.titleText,
                              ),
                              animationType: AnimationType.bobbing,
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh_rounded, size: 40, color: AppColors.titleText),
                              onPressed: () => ref.read(soundMatchProvider.notifier).loadLevel(),
                            ),
                          ],
                        ),
                      ),
                      
                      const Spacer(),

                      // Central "Ear" Prompt Button
                      Center(
                        child: GestureDetector(
                          onTap: () => ref.read(soundMatchProvider.notifier).playPrompt(),
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white38, width: 2),
                            ),
                            child: const Icon(
                              Icons.hearing_rounded,
                              size: 70,
                              color: AppColors.titleText,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 48),

                      // 2x2 Grid of Matching Items
                      Expanded(
                        flex: 6,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                              childAspectRatio: 0.9,
                            ),
                            itemCount: 4,
                            itemBuilder: (context, index) {
                              final item = state.choices[index];
                              final isSelected = state.selectedIndex == index;
                              
                              return SoundMatchCard(
                                key: ValueKey(item.id),
                                item: item,
                                isSelected: isSelected,
                                isCorrect: state.isCorrect && isSelected,
                                onTap: () => ref.read(soundMatchProvider.notifier).checkSelection(index),
                              );
                            },
                          ),
                        ),
                      ),
                      
                      const Spacer(),
                    ],
                  ),

                  // Celebration Overlay
                  if (state.showCelebration)
                    CategoryCelebrationOverlay(
                      categoryName: 'Match',
                      onDismiss: () => ref.read(soundMatchProvider.notifier).loadLevel(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
