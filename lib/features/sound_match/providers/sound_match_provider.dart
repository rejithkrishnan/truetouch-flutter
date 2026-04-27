import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../data/models/category.dart';
import '../models/sound_match_state.dart';
import '../../../data/models/content_item.dart';

/// All Sound Match categories with at least one sound item — for settings UI
final allSoundMatchCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final modules = await ref.watch(modulesProvider.future);
  final module = modules.firstWhere((m) => m.id == 'sound_match');
  final contentRepo = ref.watch(contentRepositoryProvider);
  final all = await contentRepo.loadContent(module.dataPath);
  return all.where((c) => c.items.any((i) => i.soundPath != null)).toList();
});

final soundMatchProvider =
    AsyncNotifierProvider<SoundMatchNotifier, SoundMatchState>(() {
      return SoundMatchNotifier();
    });

class SoundMatchNotifier extends AsyncNotifier<SoundMatchState> {
  final Random _random = Random();
  bool _introSpoken = false;

  SoundMatchDifficulty _difficulty = SoundMatchDifficulty.expert;

  /// true = draw from all categories combined
  bool _isRandomMode = true;

  /// The selected category IDs (used when isRandomMode is false)
  Set<String> _selectedCategoryIds = {};

  /// Ordered list of selected category IDs for rotation
  List<String> _rotationList = [];

  /// Index into _rotationList — advances on each new level
  int _rotationIndex = 0;

  /// When true, the next loadLevel() will skip auto-playing the prompt
  bool _suppressNextPrompt = false;

  @override
  FutureOr<SoundMatchState> build() async {
    return loadLevel();
  }

  Future<SoundMatchState> loadLevel() async {
    state = const AsyncLoading();

    final cardCount = _difficulty.cardCount;

    // 1. Find module config
    final modules = await ref.read(modulesProvider.future);
    final soundMatchModule = modules.firstWhere((m) => m.id == 'sound_match');

    // 2. Load all content categories
    final categories = await ref
        .read(contentRepositoryProvider)
        .loadContent(soundMatchModule.dataPath);

    // 3. Build item pool based on mode
    List<ContentItem> pool;
    String? activeCategoryName;

    if (_isRandomMode || _selectedCategoryIds.isEmpty) {
      // Random mode — draw from everything
      pool = categories
          .expand((c) => c.items)
          .where((item) => item.soundPath != null)
          .toList();
    } else {
      // Category rotation mode
      // Rebuild rotation list to respect current selection order
      _rotationList = categories
          .map((c) => c.id)
          .where((id) => _selectedCategoryIds.contains(id))
          .toList();

      if (_rotationList.isEmpty) {
        // Fallback to all
        pool = categories
            .expand((c) => c.items)
            .where((item) => item.soundPath != null)
            .toList();
      } else {
        _rotationIndex = _rotationIndex % _rotationList.length;
        final activeCatId = _rotationList[_rotationIndex];
        _rotationIndex = (_rotationIndex + 1) % _rotationList.length;

        final activeCat = categories.firstWhere((c) => c.id == activeCatId);
        activeCategoryName = activeCat.name;
        pool = activeCat.items
            .where((item) => item.soundPath != null)
            .toList();
      }
    }

    if (pool.length < cardCount) {
      throw Exception(
          'Not enough items (need $cardCount, found ${pool.length}). Try selecting more categories.');
    }

    // 4. Pick random choices + target
    final tempItems = List<ContentItem>.from(pool)..shuffle(_random);
    final choices = tempItems.take(cardCount).toList();
    final target = choices[_random.nextInt(cardCount)];

    final newState = SoundMatchState(
      choices: choices,
      target: target,
      isProcessing: false,
      difficulty: _difficulty,
      isRandomMode: _isRandomMode,
      selectedCategoryIds: Set.from(_selectedCategoryIds),
      activeCategoryName: activeCategoryName,
    );

    state = AsyncData(newState);
    _introSpoken = false;

    // Only auto-play prompt when in the game, not when triggered from settings
    final suppress = _suppressNextPrompt;
    _suppressNextPrompt = false;
    if (!suppress) {
      Future.delayed(const Duration(milliseconds: 500), () {
        playPrompt();
      });
    }

    return newState;
  }

  Future<void> setDifficulty(SoundMatchDifficulty difficulty) async {
    if (_difficulty == difficulty) return;
    _difficulty = difficulty;
    _suppressNextPrompt = true;
    await loadLevel();
  }

  Future<void> setRandomMode(bool enabled) async {
    if (_isRandomMode == enabled) return;
    _isRandomMode = enabled;
    _rotationIndex = 0;
    _suppressNextPrompt = true;
    await loadLevel();
  }

  /// Toggle a category — blocks removing the last selected one
  Future<void> toggleCategory(String categoryId) async {
    final updated = Set<String>.from(_selectedCategoryIds);
    if (updated.contains(categoryId)) {
      if (updated.length <= 1) return; // must keep at least one
      updated.remove(categoryId);
    } else {
      updated.add(categoryId);
    }
    _selectedCategoryIds = updated;
    _rotationIndex = 0;
    _suppressNextPrompt = true;
    await loadLevel();
  }

  Future<void> playPrompt() async {
    final target = state.value?.target;
    if (target == null) return;

    if (!_introSpoken) {
      _introSpoken = true;
      await ref.read(voiceEngineProvider).speak('Identify this sound');
      await Future.delayed(const Duration(milliseconds: 400));
    }

    if (target.soundPath != null) {
      ref.read(audioServiceProvider).playSound(target.soundPath!);
    }
  }

  Future<void> checkSelection(int index) async {
    final currentState = state.value;
    if (currentState == null ||
        currentState.isProcessing ||
        currentState.showCelebration) return;

    final selectedItem = currentState.choices[index];
    final isCorrect = selectedItem.id == currentState.target?.id;

    state = AsyncData(
      currentState.copyWith(
        selectedIndex: index,
        isCorrect: isCorrect,
        isProcessing: true,
      ),
    );

    if (isCorrect) {
      ref.read(hapticServiceProvider).mediumImpact();

      await ref.read(audioServiceProvider).playTtsCardSequence(
            itemName: selectedItem.name,
            soundPath: selectedItem.soundPath,
          );

      state = AsyncData(state.value!.copyWith(showCelebration: true));
      ref.read(voiceEngineProvider).speak('Great job!');

      await Future.delayed(const Duration(seconds: 3));
      await loadLevel();
    } else {
      ref.read(hapticServiceProvider).heavyImpact();

      final updatedWrong = Set<int>.from(state.value!.wrongIndices)..add(index);

      await ref
          .read(voiceEngineProvider)
          .speak('${selectedItem.name} is wrong answer');

      await Future.delayed(const Duration(milliseconds: 1000));
      state = AsyncData(
        state.value!.copyWith(
          selectedIndex: null,
          isProcessing: false,
          wrongIndices: updatedWrong,
        ),
      );
    }
  }
}
