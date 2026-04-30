import 'package:flutter_riverpod/flutter_riverpod.dart';

final bubblePopScoreProvider = StateProvider.autoDispose<int>((ref) => 0);

final bubblePopModeProvider = StateProvider.autoDispose<BubbleMode>((ref) => BubbleMode.letters);

enum BubbleMode {
  letters,
  numbers,
}
