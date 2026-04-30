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
    AsyncNotifierProvider.autoDispose<SoundMatchNotifier, SoundMatchState>(() {
  return SoundMatchNotifier();
});

class SoundMatchNotifier extends AutoDisposeAsyncNotifier<SoundMatchState> {
  final Random _random = Random();
  bool _introSpoken = false;
  bool _disposed = false; // ← gates ALL audio after leaving screen

  SoundMatchDifficulty _difficulty = SoundMatchDifficulty.expert;
  bool _isRandomMode = true;
  Set<String> _selectedCategoryIds = {};
  List<String> _rotationList = [];
  int _rotationIndex = 0;
  bool _suppressNextPrompt = false;

  Timer? _idleTimer;
  String? _playedCategoryId;

  @override
  FutureOr<SoundMatchState> build() async {
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
      _idleTimer?.cancel();
      _idleTimer = null;
      // Immediately stop any audio that's currently playing
      ref.read(voiceEngineProvider).stop();
      ref.read(audioServiceProvider).cancelSequence();
    });
    return loadLevel();
  }

  void _resetIdleTimer() {
    _idleTimer?.cancel();
    if (_disposed) return;
    _idleTimer = Timer(const Duration(seconds: 12), () {
      if (_disposed) return;
      if (state.value != null &&
          !state.value!.isProcessing &&
          !state.value!.showCelebration) {
        playPrompt();
      }
    });
  }

  Future<SoundMatchState> loadLevel() async {
    if (_disposed) return const SoundMatchState();
    state = const AsyncLoading();

    final cardCount = _difficulty.cardCount;

    final modules = await ref.read(modulesProvider.future);
    final soundMatchModule = modules.firstWhere((m) => m.id == 'sound_match');
    final categories = await ref
        .read(contentRepositoryProvider)
        .loadContent(soundMatchModule.dataPath);

    List<ContentItem> pool;
    String? activeCategoryName;
    _playedCategoryId = null;

    if (_isRandomMode || _selectedCategoryIds.isEmpty) {
      pool = categories
          .expand((c) => c.items)
          .where((item) => item.soundPath != null)
          .toList();
    } else {
      _rotationList = categories
          .map((c) => c.id)
          .where((id) => _selectedCategoryIds.contains(id))
          .toList();

      if (_rotationList.isEmpty) {
        pool = categories.expand((c) => c.items).where((i) => i.soundPath != null).toList();
      } else {
        _rotationIndex = _rotationIndex % _rotationList.length;
        final activeCatId = _rotationList[_rotationIndex];
        _rotationIndex = (_rotationIndex + 1) % _rotationList.length;

        final activeCat = categories.firstWhere((c) => c.id == activeCatId);
        activeCategoryName = activeCat.name;
        _playedCategoryId = activeCatId;
        pool = activeCat.items.where((item) => item.soundPath != null).toList();
      }
    }

    if (pool.length < cardCount) {
      throw Exception('Not enough items available.');
    }

    final tempItems = List<ContentItem>.from(pool)..shuffle(_random);
    final choices = tempItems.take(cardCount).toList();
    final target = choices[_random.nextInt(cardCount)];

    if (_playedCategoryId == null) {
      for (var cat in categories) {
        if (cat.items.any((i) => i.id == target.id)) {
          _playedCategoryId = cat.id;
          activeCategoryName = cat.name;
          break;
        }
      }
    }

    final newState = SoundMatchState(
      choices: choices,
      target: target,
      isProcessing: false,
      difficulty: _difficulty,
      isRandomMode: _isRandomMode,
      selectedCategoryIds: Set.from(_selectedCategoryIds),
      activeCategoryName: activeCategoryName,
      mistakes: 0,
    );

    if (_disposed) return newState;
    state = AsyncData(newState);
    _introSpoken = false;

    if (!_suppressNextPrompt) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!_disposed) playPrompt(); // ← guarded
      });
    }
    _suppressNextPrompt = false;

    _resetIdleTimer();
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

  Future<void> toggleCategory(String categoryId) async {
    final updated = Set<String>.from(_selectedCategoryIds);
    if (updated.contains(categoryId)) {
      if (updated.length <= 1) return;
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
    if (_disposed) return; // ← guarded
    final target = state.value?.target;
    if (target == null) return;

    if (!_introSpoken) {
      _introSpoken = true;
      if (_disposed) return;
      await ref.read(voiceEngineProvider).speak('Identify this sound');
      if (_disposed) return;
      await Future.delayed(const Duration(milliseconds: 400));
    }

    if (_disposed) return;
    if (target.soundPath != null) {
      ref.read(audioServiceProvider).playSound(target.soundPath!);
    }
    _resetIdleTimer();
  }

  Future<void> checkSelection(int index) async {
    if (_disposed) return;
    _resetIdleTimer();
    final currentState = state.value;
    if (currentState == null || currentState.isProcessing || currentState.showCelebration) return;

    final selectedItem = currentState.choices[index];
    final isCorrect = selectedItem.id == currentState.target?.id;

    if (isCorrect) {
      state = AsyncData(currentState.copyWith(selectedIndex: index, isCorrect: true, isProcessing: true));
      ref.read(hapticServiceProvider).mediumImpact();

      if (_playedCategoryId != null) {
        await ref.read(progressServiceProvider).recordSoundMatchResult(
          _playedCategoryId!,
          currentState.mistakes
        );
      }

      if (_disposed) return;
      await ref.read(audioServiceProvider).playTtsCardSequence(
        itemName: selectedItem.name,
        soundPath: selectedItem.soundPath,
      );

      if (_disposed) return;
      state = AsyncData(state.value!.copyWith(showCelebration: true));
      ref.read(voiceEngineProvider).speak('Great job!');

      await Future.delayed(const Duration(seconds: 3));
      if (_disposed) return;
      await loadLevel();
    } else {
      state = AsyncData(currentState.copyWith(
        selectedIndex: index,
        isCorrect: false,
        isProcessing: true,
        mistakes: currentState.mistakes + 1,
      ));

      ref.read(hapticServiceProvider).heavyImpact();
      final updatedWrong = Set<int>.from(state.value!.wrongIndices)..add(index);

      if (_disposed) return;
      await ref.read(voiceEngineProvider).speak('${selectedItem.name} is wrong answer');
      if (_disposed) return;
      await Future.delayed(const Duration(milliseconds: 1000));
      if (_disposed) return;
      state = AsyncData(state.value!.copyWith(selectedIndex: null, isProcessing: false, wrongIndices: updatedWrong));
    }
  }
}
