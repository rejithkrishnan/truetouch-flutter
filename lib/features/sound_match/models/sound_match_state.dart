import '../../../data/models/content_item.dart';

class SoundMatchState {
  final List<ContentItem> choices;
  final ContentItem? target;
  final int? selectedIndex;
  final bool isCorrect;
  final bool isProcessing;
  final bool showCelebration;

  const SoundMatchState({
    this.choices = const [],
    this.target,
    this.selectedIndex,
    this.isCorrect = false,
    this.isProcessing = false,
    this.showCelebration = false,
  });

  SoundMatchState copyWith({
    List<ContentItem>? choices,
    ContentItem? target,
    int? selectedIndex,
    bool? isCorrect,
    bool? isProcessing,
    bool? showCelebration,
  }) {
    return SoundMatchState(
      choices: choices ?? this.choices,
      target: target ?? this.target,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      isCorrect: isCorrect ?? this.isCorrect,
      isProcessing: isProcessing ?? this.isProcessing,
      showCelebration: showCelebration ?? this.showCelebration,
    );
  }
}
