import '../../../data/models/content_item.dart';

enum SoundMatchDifficulty {
  beginner(cardCount: 2, label: 'Beginner'),
  expert(cardCount: 4, label: 'Expert');

  final int cardCount;
  final String label;
  const SoundMatchDifficulty({required this.cardCount, required this.label});
}

class SoundMatchState {
  final List<ContentItem> choices;
  final ContentItem? target;
  final int? selectedIndex;
  final bool isCorrect;
  final bool isProcessing;
  final bool showCelebration;
  final Set<int> wrongIndices;
  final SoundMatchDifficulty difficulty;

  /// true = draw from all categories (Random mode)
  final bool isRandomMode;

  /// Which categories are checked (only used when isRandomMode is false)
  final Set<String> selectedCategoryIds;

  /// Which category is currently being played (display info)
  final String? activeCategoryName;
  final int mistakes;

  const SoundMatchState({
    this.choices = const [],
    this.target,
    this.selectedIndex,
    this.isCorrect = false,
    this.isProcessing = false,
    this.showCelebration = false,
    this.wrongIndices = const {},
    this.difficulty = SoundMatchDifficulty.expert,
    this.isRandomMode = true,
    this.selectedCategoryIds = const {},
    this.activeCategoryName,
    this.mistakes = 0,
  });

  SoundMatchState copyWith({
    List<ContentItem>? choices,
    ContentItem? target,
    int? selectedIndex,
    bool? isCorrect,
    bool? isProcessing,
    bool? showCelebration,
    Set<int>? wrongIndices,
    SoundMatchDifficulty? difficulty,
    bool? isRandomMode,
    Set<String>? selectedCategoryIds,
    Object? activeCategoryName = _sentinel,
    int? mistakes,
  }) {
    return SoundMatchState(
      choices: choices ?? this.choices,
      target: target ?? this.target,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      isCorrect: isCorrect ?? this.isCorrect,
      isProcessing: isProcessing ?? this.isProcessing,
      showCelebration: showCelebration ?? this.showCelebration,
      wrongIndices: wrongIndices ?? this.wrongIndices,
      difficulty: difficulty ?? this.difficulty,
      isRandomMode: isRandomMode ?? this.isRandomMode,
      selectedCategoryIds: selectedCategoryIds ?? this.selectedCategoryIds,
      activeCategoryName: activeCategoryName == _sentinel
          ? this.activeCategoryName
          : activeCategoryName as String?,
      mistakes: mistakes ?? this.mistakes,
    );
  }
}

const Object _sentinel = Object();
