import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../board_book/providers/board_book_providers.dart';
import '../widgets/settings_shared_widgets.dart';

class BoardBookSettingsScreen extends ConsumerStatefulWidget {
  const BoardBookSettingsScreen({super.key});

  @override
  ConsumerState<BoardBookSettingsScreen> createState() => _BoardBookSettingsScreenState();
}

class _BoardBookSettingsScreenState extends ConsumerState<BoardBookSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsServiceProvider);
    final allCategoriesAsync = ref.watch(allBoardBookCategoriesProvider);
    final disabledCategories = settings.disabledCategories;
    final progress = ref.watch(progressServiceProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Board Book Settings', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        children: [
          // ── Stats Dashboard ──
          allCategoriesAsync.when(
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())),
            error: (err, _) => Center(child: Text('Error loading stats: $err')),
            data: (categories) {
              final allItemIds = categories.expand((c) => c.items).map((i) => i.id).toList();
              final totalCount = allItemIds.length;
              final discoveredCount = progress.discoveredCount('board_book', allItemIds);
              final pts = progress.totalPoints('board_book', allItemIds);
              final pct = totalCount == 0 ? 0.0 : discoveredCount / totalCount;
              final categoryStats = progress.getCategoryStats('board_book', categories);
              final maxPts = categoryStats.isEmpty ? 1 : (categoryStats.first.points == 0 ? 1 : categoryStats.first.points);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.nurseryPalette[0], AppColors.nurseryPalette[2]],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.auto_graph_rounded, color: Colors.white, size: 24),
                            SizedBox(width: 8),
                            Text('Board Book Stats', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            StatChip(icon: Icons.touch_app_rounded, label: 'Discovered', value: '$discoveredCount / $totalCount'),
                            const SizedBox(width: 10),
                            StatChip(icon: Icons.star_rounded, label: 'Points', value: '$pts ⭐', highlight: true),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(value: pct, minHeight: 10, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber)),
                        ),
                      ],
                    ),
                  ),
                  
                  const SectionHeader(label: 'Category Engagement'),
                  ...categoryStats.map((stat) {
                    final idx = categoryStats.indexOf(stat);
                    final barColor = idx < 3 ? [Colors.amber.shade600, Colors.orange.shade400, Colors.blue.shade400][idx] : Colors.grey;
                    return Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(idx < 3 ? ['🥇 ', '🥈 ', '🥉 '][idx] : '   ', style: const TextStyle(fontSize: 16)),
                              Expanded(child: Text(stat.categoryName, style: const TextStyle(fontWeight: FontWeight.bold))),
                              Text('${stat.points} pts', style: TextStyle(fontWeight: FontWeight.bold, color: barColor)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(value: stat.points / maxPts, minHeight: 6, backgroundColor: Colors.grey.shade100, valueColor: AlwaysStoppedAnimation<Color>(barColor)),
                        ],
                      ),
                    );
                  }),
                ],
              );
            },
          ),

          const SectionHeader(label: 'Configuration'),
          SettingsTile(
            icon: Icons.library_books_rounded,
            iconColor: AppColors.nurseryPalette[1],
            title: 'Cards Per Page',
            subtitle: 'Layout density for exploration',
            trailing: DropdownButton<int>(
              value: settings.cardsPerPage,
              underline: const SizedBox.shrink(),
              borderRadius: BorderRadius.circular(12),
              items: [1, 2, 3, 4].map((v) => DropdownMenuItem(value: v, child: Text('$v Card${v > 1 ? 's' : ''}'))).toList(),
              onChanged: (val) async {
                if (val != null) {
                  await settings.setCardsPerPage(val);
                  if (mounted) setState(() {});
                }
              },
            ),
          ),

          const SectionHeader(label: 'Content Management'),
          allCategoriesAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (categories) => Column(
              children: categories.map((cat) {
                final isEnabled = !disabledCategories.contains(cat.id);
                final canDisable = isEnabled ? (categories.length - disabledCategories.length) > 1 : true;
                return CategoryTile(
                  categoryName: cat.name,
                  itemCount: cat.items.length,
                  isEnabled: isEnabled,
                  canDisable: canDisable,
                  onChanged: (val) async {
                    final newDisabled = List<String>.from(disabledCategories);
                    if (val) newDisabled.remove(cat.id);
                    else newDisabled.add(cat.id);
                    await settings.setDisabledCategories(newDisabled);
                    ref.invalidate(boardBookCategoriesProvider);
                    if (mounted) setState(() {});
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
