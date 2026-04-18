import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../data/models/category.dart';

// Provides the flat, filtered, and shuffled category list for the Board Book
final boardBookCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final modules = await ref.watch(modulesProvider.future);
  final boardBookModule = modules.firstWhere(
    (m) => m.id == 'board_book',
    orElse: () => throw Exception('Board Book module not found'),
  );

  final contentRepo = ref.watch(contentRepositoryProvider);
  final allCategories = await contentRepo.loadContent(boardBookModule.dataPath);

  final settingsService = ref.watch(settingsServiceProvider);
  final disabledList = settingsService.disabledCategories;

  // Filter and shuffle
  final activeCategories = allCategories
      .where((c) => !disabledList.contains(c.id))
      .toList()
    ..shuffle();

  // Shuffle items inside each category
  for (var category in activeCategories) {
    category.items.shuffle();
  }

  return activeCategories;
});

// Provides the user's preferred "cards per page" setting for the UI layout
final boardBookCardsPerPageProvider = Provider<int>((ref) {
  final settingsService = ref.watch(settingsServiceProvider);
  return settingsService.cardsPerPage;
});

// Provides ALL categories (unfiltered) for use in the settings UI
final allBoardBookCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final modules = await ref.watch(modulesProvider.future);
  final boardBookModule = modules.firstWhere(
    (m) => m.id == 'board_book',
    orElse: () => throw Exception('Board Book module not found'),
  );
  final contentRepo = ref.watch(contentRepositoryProvider);
  return contentRepo.loadContent(boardBookModule.dataPath);
});
