import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flame/game.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/providers.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/voice_engine.dart';
import '../../shared/widgets/animated_background.dart';
import '../../shared/widgets/premium_animated_text.dart';
import 'game/bubble_pop_game.dart';
import 'providers/bubble_pop_provider.dart';

class BubblePopScreen extends ConsumerStatefulWidget {
  const BubblePopScreen({super.key});

  @override
  ConsumerState<BubblePopScreen> createState() => _BubblePopScreenState();
}

class _BubblePopScreenState extends ConsumerState<BubblePopScreen> {
  late final AudioService _audio;
  late final VoiceEngine _voice;
  late BubblePopGame _game;
  int _popSequenceId = 0;

  @override
  void initState() {
    super.initState();
    _audio = ref.read(audioServiceProvider);
    _voice = ref.read(voiceEngineProvider);
    final settings = ref.read(settingsServiceProvider);

    _game = BubblePopGame(
      showLetters: settings.bubblePopShowLetters,
      showNumbers: settings.bubblePopShowNumbers,
      maxBubbles: settings.bubblePopMaxBubbles,
      speedMultiplier: settings.bubblePopSpeed,
      onPop: (String value) async {
        ref.read(hapticServiceProvider).heavyImpact();
        ref.read(bubblePopScoreProvider.notifier).state++;
        
        final currentSeq = ++_popSequenceId;
        _voice.stop(); // Stop any currently playing voice
        
        await _audio.playRandomPopSound();
        
        // Only speak if this is still the most recently popped bubble
        if (currentSeq == _popSequenceId && mounted) {
          await _voice.speak(value);
        }
      },
      onJiggle: () {
        ref.read(hapticServiceProvider).lightImpact();
        _audio.playSound('assets/audio/balloon_pop/water_drop.mp3');
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _audio.switchTrack(BgmTrack.bubblePop);
      _voice.speak('Lets Pop the bubbles');
    });
  }

  @override
  void dispose() {
    _voice.stop();
    _audio.cancelSequence();
    _audio.switchTrack(BgmTrack.home);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final score = ref.watch(bubblePopScoreProvider);

    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(
            imagePath: 'assets/images/background_bubble_burst.png',
            scaleFactor: 1.15,
            opacity: 0.5,
          ),
          SafeArea(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Flame Game Engine Surface
                Positioned.fill(child: GameWidget(game: _game)),

                // Top Bar UI
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.home_rounded,
                            size: 40,
                            color: AppColors.titleText,
                          ),
                          onPressed: () => context.pop(),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: PremiumAnimatedText(
                            text: 'Score: $score',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppColors.titleText,
                            ),
                            animationType: AnimationType.bobbing,
                          ),
                        ),
                      ],
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
