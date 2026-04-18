import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import 'parental_gate.dart';

class ScreenTimeOverlay extends ConsumerWidget {
  const ScreenTimeOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final limitReached = ref.watch(screenTimeLimitReachedProvider);
    if (!limitReached) return const SizedBox.shrink();

    return ParentalGate(
      onUnlocked: () async {
        await ref.read(screenTimeServiceProvider).resetUsage();
      },
      child: Material(
        color: Colors.black.withOpacity(0.92),
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.nightlight_round_rounded,
                color: Colors.amber,
                size: 100,
              ),
              const SizedBox(height: 32),
              const Text(
                'Time for a break! 🌙',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'The daily screen time limit has been reached. Let\'s play again tomorrow!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    height: 1.4,
                  ),
                ),
              ),
              const Spacer(),
              const Opacity(
                opacity: 0.3,
                child: Text(
                  'Parent: Long press bottom right to unlock',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
