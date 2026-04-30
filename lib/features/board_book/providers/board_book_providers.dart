import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../data/models/category.dart';
import '../../../data/models/content_item.dart';

// Provides the flat, filtered, and shuffled category list for the Board Book.
// autoDispose ensures the shuffle is re-run fresh every time the screen is opened.
final boardBookCategoriesProvider = FutureProvider.autoDispose<List<Category>>((ref) async {
  final modules = await ref.watch(modulesProvider.future);
  final boardBookModule = modules.firstWhere(
    (m) => m.id == 'board_book',
    orElse: () => throw Exception('Board Book module not found'),
  );

  final contentRepo = ref.watch(contentRepositoryProvider);
  final allCategories = await contentRepo.loadContent(boardBookModule.dataPath);

  final settingsService = ref.watch(settingsServiceProvider);
  final disabledList = settingsService.disabledCategories;

  // Filter, Deep Copy, and Shuffle
  // We create new Category instances with shuffled item lists to ensure 
  // fresh state every time the provider is re-run (on every visit).
  final randomizedCategories = allCategories
      .where((c) => !disabledList.contains(c.id))
      .map((cat) => Category(
            id: cat.id,
            name: cat.name,
            items: List<ContentItem>.from(cat.items)..shuffle(),
          ))
      .toList()
    ..shuffle();

  return randomizedCategories;
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
