import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../models/sound_match_state.dart';
import '../../../data/models/content_item.dart';

final soundMatchProvider = AsyncNotifierProvider<SoundMatchNotifier, SoundMatchState>(() {
  return SoundMatchNotifier();
});

class SoundMatchNotifier extends AsyncNotifier<SoundMatchState> {
  final Random _random = Random();

  @override
  FutureOr<SoundMatchState> build() async {
    return loadLevel();
  }

  Future<SoundMatchState> loadLevel() async {
    state = const AsyncLoading();
    
    // 1. Find the Sound Match module config
    final modules = await ref.read(modulesProvider.future);
    final soundMatchModule = modules.firstWhere((m) => m.id == 'sound_match');
    
    // 2. Load all content items
    final categories = await ref.read(contentRepositoryProvider).loadContent(soundMatchModule.dataPath);
    final allItems = categories.expand((c) => c.items).toList();
    
    if (allItems.length < 4) {
      throw Exception('Not enough items for Sound Match (need 4)');
    }

    // 3. Select 4 unique random items
    final List<ContentItem> choices = [];
    final tempItems = List<ContentItem>.from(allItems)..shuffle(_random);
    choices.addAll(tempItems.take(4));

    // 4. Pick a target
    final target = choices[_random.nextInt(4)];

    final newState = SoundMatchState(
      choices: choices,
      target: target,
      isProcessing: false,
    );

    // 5. Play initial prompt after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      playPrompt();
    });

    return newState;
  }

  void playPrompt() {
    final target = state.value?.target;
    if (target != null && target.soundPath != null) {
      ref.read(audioServiceProvider).playSound(target.soundPath!);
    }
  }

  Future<void> checkSelection(int index) async {
    final currentState = state.value;
    if (currentState == null || currentState.isProcessing || currentState.showCelebration) return;

    final selectedItem = currentState.choices[index];
    final isCorrect = selectedItem.id == currentState.target?.id;

    state = AsyncData(currentState.copyWith(
      selectedIndex: index,
      isCorrect: isCorrect,
      isProcessing: true,
    ));

    if (isCorrect) {
      // 🏆 Success Sequence
      ref.read(hapticServiceProvider).mediumImpact();
      
      // Play Word -> Sound sequence (0ms gap)
      await ref.read(audioServiceProvider).playInteractionSequence(
        selectedItem.voicePath,
        selectedItem.soundPath,
      );

      // Show celebration overlay
      state = AsyncData(state.value!.copyWith(showCelebration: true));
      
      // Wait for celebration
      await Future.delayed(const Duration(seconds: 3));
      
      // Load next level
      await loadLevel();
    } else {
      // ❌ Incorrect Sequence
      ref.read(hapticServiceProvider).heavyImpact();
      
      // Play just the voice of what was tapped (Incorrect hint)
      if (selectedItem.voicePath != null) {
        await ref.read(audioServiceProvider).playSound(selectedItem.voicePath!);
      }
      
      // Reset selection after a delay to allow re-try
      await Future.delayed(const Duration(milliseconds: 1000));
      state = AsyncData(state.value!.copyWith(
        selectedIndex: null,
        isProcessing: false,
      ));
    }
  }
}
