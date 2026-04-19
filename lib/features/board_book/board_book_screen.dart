import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers.dart';
import '../../../core/services/audio_service.dart';
import '../../../shared/widgets/animated_background.dart';
import '../../../data/models/category.dart';
import '../../../data/models/content_item.dart';
import 'providers/board_book_providers.dart';
import 'widgets/content_card.dart';
import '../../../shared/widgets/premium_animated_text.dart';
import '../../../shared/widgets/category_celebration_overlay.dart';
import '../../../core/services/progress_service.dart';

class _PageData {
  final Category category;
  final List<ContentItem> items;
  _PageData(this.category, this.items);
}

class BoardBookScreen extends ConsumerStatefulWidget {
  const BoardBookScreen({super.key});

  @override
  ConsumerState<BoardBookScreen> createState() => _BoardBookScreenState();
}

class _BoardBookScreenState extends ConsumerState<BoardBookScreen> {
  final PageController _pageController = PageController(initialPage: 10000);
  late final AudioService _audio;

  List<_PageData> _buildPages(List<Category> categories, int cardsPerPage) {
    if (categories.isEmpty) return [];
    
    final List<_PageData> pages = [];
    for (var cat in categories) {
      if (cat.items.isEmpty) continue;
      
      for (int i = 0; i < cat.items.length; i += cardsPerPage) {
        final end = (i + cardsPerPage < cat.items.length) ? i + cardsPerPage : cat.items.length;
        pages.add(_PageData(cat, cat.items.sublist(i, end)));
      }
    }
    return pages;
  }

  @override
  void initState() {
    super.initState();
    // Cache audio service ref BEFORE dispose() — ref is dead by then!
    _audio = ref.read(audioServiceProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _audio.switchTrack(BgmTrack.boardBook);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _audio.cancelSequence();
    _audio.switchTrack(BgmTrack.home);
    super.dispose();
  }

  void _showCelebration(String categoryName, Color trophyColor) {
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => CategoryCelebrationOverlay(
        mainText: 'Great Job!',
        subText: 'You finished $categoryName!',
        trophyColor: trophyColor,
        onDismiss: () {
          overlayEntry.remove();
        },
      ),
    );
    Overlay.of(context).insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(boardBookCategoriesProvider);
    final cardsPerPage = ref.watch(boardBookCardsPerPageProvider);
    final progress = ref.watch(progressServiceProvider);

    // Watch for progress updates to trigger celebrations
    ref.listen(progressUpdateProvider, (previous, next) {
      if (next == 0) return; // Initial state

      categoriesAsync.whenData((categories) {
        if (categories.isEmpty) return;

        final moduleId = 'board_book';

        // Check ALL categories for completion, not just the visible one.
        // This is much safer in case of scroll offsets or index mismatches.
        for (final category in categories) {
          final itemIds = category.items.map((i) => i.id).toList();

          if (progress.isCategoryComplete(moduleId, itemIds) && 
              !progress.isCategoryCelebrated(moduleId, category.id)) {
            
            progress.markCategoryCelebrated(moduleId, category.id);
            // Use a color from the palette based on category index
            final categoryIndex = categories.indexOf(category);
            final color = AppColors.nurseryPalette[categoryIndex % AppColors.nurseryPalette.length];
            _showCelebration(category.name, color);
            
            // Only celebrate one category at a time if multiple finish simultaneously
            break; 
          }
        }
      });
    });

    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(
            imagePath: 'assets/images/background_boardbook.png',
            scaleFactor: 1.1,
          ),
          
          SafeArea(
            child: categoriesAsync.when(
              data: (categories) {
                final pages = _buildPages(categories, cardsPerPage);
                
                if (pages.isEmpty) {
                  return const Center(
                    child: Text('No categories enabled.', style: TextStyle(fontSize: 24)),
                  );
                }

                return Column(
                  children: [
                    // Top Bar (Category Title & Home Button)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.home_rounded, size: 40, color: AppColors.titleText),
                            onPressed: () => context.pop(),
                          ),
                          // We use AnimatedBuilder to update category title dynamically as user scrolls
                          AnimatedBuilder(
                            animation: _pageController,
                            builder: (context, _) {
                              int pageIndex = 0;
                              if (_pageController.hasClients && _pageController.position.haveDimensions) {
                                pageIndex = _pageController.page?.round() ?? 10000;
                              } else {
                                pageIndex = 10000;
                              }
                              
                              final safeIndex = pageIndex % pages.length;
                              final currentCategory = pages[safeIndex].category;
                              
                              return PremiumAnimatedText(
                                text: currentCategory.name,
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 40),
                                animationType: AnimationType.bobbing,
                              );
                            },
                          ),
                          const SizedBox(width: 40), // Balance the row
                        ],
                      ),
                    ),

                    // Infinite Pager
                    Expanded(
                      child: PageView.builder(
                         controller: _pageController,
                         // No itemCount = true infinite scroll
                         itemBuilder: (context, index) {
                           final safeIndex = index % pages.length;
                           final pageData = pages[safeIndex];

                           return Padding(
                             padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.center,
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: pageData.items.asMap().entries.map((entry) {
                                  // Assign color sequentially from palette
                                  final colorIndex = (safeIndex + entry.key) % AppColors.nurseryPalette.length;
                                  final color = AppColors.nurseryPalette[colorIndex];
                                  
                                  return Flexible(
                                    fit: FlexFit.loose,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                                      child: AspectRatio(
                                        aspectRatio: 1.0, // Ensures the card stays completely square with perfectly tight bounds
                                        child: ContentCard(
                                          item: entry.value,
                                          backgroundColor: color,
                                        ),
                                      ),
                                    ),
                                  );
                               }).toList(),
                             ),
                           );
                         },
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
