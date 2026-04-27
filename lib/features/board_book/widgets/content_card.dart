import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:video_player/video_player.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/content_item.dart';
import '../../../shared/widgets/breathing_widget.dart';
import '../../../shared/widgets/premium_animated_text.dart';
import '../../../shared/widgets/category_celebration_overlay.dart';

class ContentCard extends ConsumerStatefulWidget {
  final ContentItem item;
  final Color backgroundColor;
  // Module ID used as the progress key namespace
  final String moduleId;

  const ContentCard({
    super.key,
    required this.item,
    required this.backgroundColor,
    this.moduleId = 'board_book',
  });

  @override
  ConsumerState<ContentCard> createState() => _ContentCardState();
}

class _ContentCardState extends ConsumerState<ContentCard> {
  late ConfettiController _confettiController;
  VideoPlayerController? _videoController;
  bool _isPlayingVideo = false;
  int _starRating = 0; // 0 = not yet tapped, 1-5 based on tap count
  Offset? _tapPosition;
  int _spellingKey = 0; // Increment to re-run character animations
  bool _isPressing = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 15), // Long duration to allow hold
    );

    // Load initial discovered state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final progress = ref.read(progressServiceProvider);
      setState(() {
        _starRating = progress.getStarRating(widget.moduleId, widget.item.id);
      });
    });

    // Pre-initialize video if available
    if (widget.item.videoPath != null && widget.item.videoPath!.isNotEmpty) {
      _videoController = VideoPlayerController.asset(widget.item.videoPath!)
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    final audioService = ref.read(audioServiceProvider);
    if (audioService.isInteractionLocked) return;

    ref.read(hapticServiceProvider).heavyImpact();
    // Confetti play handled by onTapDown for sustain

    // Record progress and update star rating
    final progress = ref.read(progressServiceProvider);
    await progress.recordTap(widget.moduleId, widget.item.id);

    // Signal progress update to listeners (like BoardBookScreen for celebrations)
    ref.read(progressUpdateProvider.notifier).state++;

    setState(() {
      _starRating = progress.getStarRating(widget.moduleId, widget.item.id);
      _spellingKey++; // Trigger label animation
    });

    if (_videoController != null && _videoController!.value.isInitialized) {
      setState(() => _isPlayingVideo = true);
      _videoController!.seekTo(Duration.zero);
      _videoController!.play();
      _videoController!.setLooping(false);
      _videoController!.addListener(_videoListener);
    }

    await audioService.playTtsCardSequence(
      itemName: widget.item.name,
      soundPath: widget.item.soundPath,
    );

    // 🏆 Milestone: Reach 5 stars for the first time
    if (_starRating == 5 &&
        !progress.isItemCelebrated(widget.moduleId, widget.item.id)) {
      await progress.markItemCelebrated(widget.moduleId, widget.item.id);
      if (mounted) {
        final settings = ref.read(settingsServiceProvider);
        // Trigger voice and visual celebration simultaneously for high-impact feedback
        ref
            .read(voiceEngineProvider)
            .speakMastery(widget.item.name, childName: settings.childName);
        _showMasteryCelebration();
      }
    }
  }

  void _showMasteryCelebration() {
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder:
          (context) => CategoryCelebrationOverlay(
            mainText: 'Mastered!',
            subText: 'You mastered the ${widget.item.name}!',
            trophyColor: widget.backgroundColor,
            onDismiss: () {
              overlayEntry.remove();
            },
          ),
    );
    Overlay.of(context).insert(overlayEntry);
  }

  void _videoListener() {
    if (_videoController != null &&
        _videoController!.value.position >= _videoController!.value.duration) {
      _videoController!.removeListener(_videoListener);
      setState(() => _isPlayingVideo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // The actual card
        BreathingWidget(
          child: GestureDetector(
            onTapDown: (details) {
              final audioService = ref.read(audioServiceProvider);

              // Both visual (confetti) and logic (audio) are now gated by the lock
              if (!audioService.isInteractionLocked) {
                setState(() {
                  _tapPosition = details.localPosition;
                  _isPressing = true;
                });
                _confettiController.play();
                _handleTap();
              }
            },
            onTapUp: (_) async {
              setState(() => _isPressing = false);
              // Wait a tiny bit so quick taps still show some confetti
              await Future.delayed(const Duration(milliseconds: 250));
              if (!_isPressing) {
                _confettiController.stop();
              }
            },
            onTapCancel: () {
              setState(() => _isPressing = false);
              _confettiController.stop();
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15), // Glassmorphism
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Base Image
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          widget.item.imagePath,
                          fit: BoxFit.contain,
                          errorBuilder:
                              (_, __, ___) => const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 64,
                                  color: Colors.white54,
                                ),
                              ),
                        ),
                      ),
                    ),

                    // Video overlay (if playing)
                    if (_isPlayingVideo && _videoController != null)
                      Container(
                        color: Colors.black.withValues(alpha: 0.9),
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: _videoController!.value.aspectRatio,
                            child: VideoPlayer(_videoController!),
                          ),
                        ),
                      ),

                    // Label - Floating through the bottom 10% area
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: MediaQuery.of(context).size.height * 0.1,
                      child: Center(
                        child: PremiumAnimatedText(
                          text: widget.item.name,
                          trigger: _spellingKey,
                          style: Theme.of(
                            context,
                          ).textTheme.headlineMedium?.copyWith(
                            fontSize: 54,
                            color: const Color(0xFFFFCC4D), // Golden Sunbeam
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                offset: const Offset(0, 4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          animationType: AnimationType.bobbing,
                          hasDrift: true,
                          staggerDelay: 140.ms,
                          driftAmount: 20.0,
                        ),
                      ),
                    ),

                    // ⭐ Star rating badge — top-right
                    if (_starRating > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: _StarRatingBadge(
                          key: ValueKey('stars_${_starRating}_$_spellingKey'),
                          stars: _starRating,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Confetti above the card at tap location
        Positioned(
          left: _tapPosition?.dx ?? MediaQuery.of(context).size.width / 2,
          top: _tapPosition?.dy ?? MediaQuery.of(context).size.height / 2,
          width: 1,
          height: 1,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.1,
            numberOfParticles: 40,
            maxBlastForce: 15,
            minBlastForce: 5,
            gravity: 0.05,
            minimumSize: const Size(6, 6),
            maximumSize: const Size(12, 12),
            colors: AppColors.nurseryPalette,
          ),
        ),
      ],
    );
  }
}

// ── Star rating badge: shows filled/empty stars in a dark pill ────────────────
class _StarRatingBadge extends StatelessWidget {
  final int stars; // 1–5
  const _StarRatingBadge({super.key, required this.stars});

  @override
  Widget build(BuildContext context) {
    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.amber.shade300, width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (i) {
              return Icon(
                i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 14,
                color: i < stars ? Colors.amber : Colors.white38,
              );
            }),
          ),
        )
        .animate()
        .scale(
          begin: const Offset(0, 0),
          end: const Offset(1, 1),
          duration: 350.ms,
          curve: Curves.elasticOut,
        )
        .fadeIn(duration: 150.ms);
  }
}
