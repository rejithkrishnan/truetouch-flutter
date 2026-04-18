import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/services/audio_service.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/animated_background.dart';
import 'widgets/activity_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioServiceProvider).switchTrack(BgmTrack.home);
    });
  }

  @override
  Widget build(BuildContext context) {
    final modulesAsync = ref.watch(modulesProvider);

    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(
            imagePath: 'assets/images/home_hub_bg.png',
            scaleFactor: 1.15,
          ),
          
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 40.0, bottom: 12.0),
                  child: _AnimatedTitle(context),
                ),
                _AnimatedSubtitle(context),
                const SizedBox(height: 40),
                
                Expanded(
                  child: modulesAsync.when(
                    data: (modules) {
                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 30,
                          mainAxisSpacing: 30,
                        ),
                        itemCount: modules.length,
                        itemBuilder: (context, index) {
                          return ActivityCard(module: modules[index]);
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(
                      child: Text('Error loading modules: $error'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Continuous title: each letter bobs in a slow staggered wave ──────────────
Widget _AnimatedTitle(BuildContext context) {
  const text = 'True Touch';
  final style = Theme.of(context).textTheme.displayLarge!;
  final letters = text.characters.toList();

  return Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(letters.length, (i) {
      if (letters[i] == ' ') return const SizedBox(width: 10);
      return Text(letters[i], style: style)
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(
            begin: 0,
            end: -7,
            duration: 1200.ms,
            delay: (i * 90).ms,
            curve: Curves.easeInOut,
          )
          .shimmer(
            duration: 2600.ms,
            delay: (i * 90).ms,
            color: Colors.white.withValues(alpha: 0.5),
          );
    }),
  );
}

// ── Continuous subtitle: gentle float + shimmer loop ─────────────────────────
Widget _AnimatedSubtitle(BuildContext context) {
  return Text(
    'Safe Learning Playroom',
    style: Theme.of(context).textTheme.titleLarge,
  )
      .animate(onPlay: (c) => c.repeat(reverse: true))
      .fadeIn(begin: 0.65, duration: 2000.ms)
      .moveY(begin: 3, end: -3, duration: 2000.ms, curve: Curves.easeInOut)
      .shimmer(
        duration: 3200.ms,
        color: Colors.white.withValues(alpha: 0.4),
      );
}
