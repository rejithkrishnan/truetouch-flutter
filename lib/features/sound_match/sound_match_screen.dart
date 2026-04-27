import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/providers.dart';
import '../../shared/widgets/animated_background.dart';
import '../../shared/widgets/premium_animated_text.dart';
import '../../shared/widgets/category_celebration_overlay.dart';
import 'providers/sound_match_provider.dart';
import 'models/sound_match_state.dart';
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

                      // Central Sound Prompt Button
                      Center(
                        child: _PromptButton(
                          onTap: () {
                            ref.read(hapticServiceProvider).heavyImpact();
                            ref.read(soundMatchProvider.notifier).playPrompt();
                          },
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Card Grid — adapts to difficulty
                      Expanded(
                        flex: 6,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                              childAspectRatio:
                                  state.difficulty == SoundMatchDifficulty.beginner
                                      ? 1.05
                                      : 0.9,
                            ),
                            itemCount: state.difficulty.cardCount,
                            itemBuilder: (context, index) {
                              final item = state.choices[index];
                              final isSelected = state.selectedIndex == index;

                              return SoundMatchCard(
                                key: ValueKey(item.id),
                                item: item,
                                isSelected: isSelected,
                                isCorrect: state.isCorrect && isSelected,
                                isWrongHistory: state.wrongIndices.contains(index),
                                onTap: () => ref
                                    .read(soundMatchProvider.notifier)
                                    .checkSelection(index),
                              );
                            },
                          ),
                        ),
                      ),
                      // Category label
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: PremiumAnimatedText(
                          text: state.isRandomMode
                              ? '✨ Random Category'
                              : state.activeCategoryName ?? 'All Categories',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.titleText,
                            letterSpacing: 0.5,
                          ),
                          animationType: AnimationType.bobbing,
                        ),
                      ),

                      const Spacer(),

                    ],
                  ),

                  // Celebration Overlay
                  if (state.showCelebration)
                    CategoryCelebrationOverlay(
                      mainText: 'Great Job!',
                      subText: 'You found the match!',
                      trophyColor: AppColors.softMint,
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

// ── Tactile Sound Prompt Button ─────────────────────────────────────────────
class _PromptButton extends StatefulWidget {
  final VoidCallback onTap;
  const _PromptButton({required this.onTap});

  @override
  State<_PromptButton> createState() => _PromptButtonState();
}

class _PromptButtonState extends State<_PromptButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnim;
  late Animation<double> _ringsAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );
    _ringsAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    _pressController.forward();
  }

  void _onTapUp(_) {
    _pressController.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _pressController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnim.value,
            child: SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer pulse ring
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.goldenSunbeam.withValues(
                            alpha: 0.25 + _ringsAnim.value * 0.15),
                        width: 2,
                      ),
                    ),
                  ),
                  // Middle ring
                  Container(
                    width: 116,
                    height: 116,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.goldenSunbeam.withValues(
                            alpha: 0.35 + _ringsAnim.value * 0.2),
                        width: 2,
                      ),
                    ),
                  ),
                  // Core button
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.goldenSunbeam
                          .withValues(alpha: 0.9 + _ringsAnim.value * 0.1),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.goldenSunbeam.withValues(
                              alpha: 0.4 + _ringsAnim.value * 0.3),
                          blurRadius: 20 + _ringsAnim.value * 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.volume_up_rounded,
                      size: 44,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
