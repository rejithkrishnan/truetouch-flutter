import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/settings_shared_widgets.dart';
import '../../sound_match/providers/sound_match_provider.dart';
import '../../sound_match/models/sound_match_state.dart';
import '../../../core/providers.dart';

class SoundMatchSettingsScreen extends ConsumerWidget {
  const SoundMatchSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(soundMatchProvider);
    final categoriesAsync = ref.watch(allSoundMatchCategoriesProvider);
    final progressService = ref.watch(progressServiceProvider);

    final currentDifficulty =
        stateAsync.value?.difficulty ?? SoundMatchDifficulty.expert;
    final isRandomMode = stateAsync.value?.isRandomMode ?? true;
    final selectedIds = stateAsync.value?.selectedCategoryIds ?? {};

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Sound Match Settings',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        children: [
          // ── Difficulty ────────────────────────────────────────────────
          const SectionHeader(label: 'Difficulty'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: SoundMatchDifficulty.values.map((d) {
                final isActive = currentDifficulty == d;
                return Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        ref.read(soundMatchProvider.notifier).setDifficulty(d),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.teal : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isActive ? Colors.teal : Colors.grey.shade300,
                        ),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: Colors.teal.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                )
                              ]
                            : [],
                      ),
                      child: Column(
                        children: [
                          Text(
                            d.label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: isActive ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${d.cardCount} choices',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: isActive
                                  ? Colors.white70
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // ── Category Mode ─────────────────────────────────────────────
          const SectionHeader(label: 'Modes & Stars'),

          // Random toggle
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: SwitchListTile(
              secondary: CircleAvatar(
                backgroundColor: isRandomMode
                    ? Colors.deepPurple
                    : Colors.deepPurple.withValues(alpha: 0.12),
                child: Icon(
                  Icons.shuffle_rounded,
                  color: isRandomMode ? Colors.white : Colors.deepPurple,
                  size: 20,
                ),
              ),
              title: const Text(
                'Random Mode',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                isRandomMode
                    ? 'Mixing objects from all categories'
                    : 'Custom rotation using selected categories',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              value: isRandomMode,
              activeColor: Colors.deepPurple,
              onChanged: (val) =>
                  ref.read(soundMatchProvider.notifier).setRandomMode(val),
            ),
          ),

          // Subtitle for category scores
          Padding(
            padding: const EdgeInsets.only(left: 18, top: 12, bottom: 4),
            child: Text(
              'CATEGORY BEST SCORES',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: Colors.grey.shade600,
              ),
            ),
          ),

          // Category list
          categoriesAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) =>
                Center(child: Text('Error loading categories: $err')),
            data: (categories) => Column(
              children: categories.map((cat) {
                final isChecked = selectedIds.contains(cat.id);
                final isLastSelected = isChecked && selectedIds.length == 1;
                final stars = progressService.getSoundMatchStars(cat.id);

                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: !isRandomMode && isChecked
                        ? Colors.teal.shade50
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: !isRandomMode && isChecked
                          ? Colors.teal
                          : Colors.grey.shade200,
                      width: !isRandomMode && isChecked ? 2 : 1,
                    ),
                  ),
                  child: CheckboxListTile(
                    enabled: !isRandomMode && !isLastSelected,
                    secondary: CircleAvatar(
                      backgroundColor:
                          stars > 0 ? Colors.amber.shade100 : Colors.grey.shade100,
                      child: Icon(
                        stars == 3 ? Icons.emoji_events_rounded : Icons.category_rounded,
                        color: stars > 0 ? Colors.amber.shade800 : Colors.grey.shade400,
                        size: 18,
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            cat.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: !isRandomMode && isChecked
                                  ? Colors.teal.shade800
                                  : Colors.black87,
                            ),
                          ),
                        ),
                        // Always show stars (solid/outline based on score)
                        Row(
                          children: List.generate(3, (i) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 1),
                              child: Icon(
                                i < stars
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                color: i < stars ? Colors.amber : Colors.grey.shade300,
                                size: 20,
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      isRandomMode
                          ? 'Played in Random Mode'
                          : isLastSelected
                              ? 'At least one category required'
                              : isChecked
                                  ? 'Selected for rotation'
                                  : 'Tap to include in rotation',
                      style: TextStyle(
                        fontSize: 11,
                        color: isLastSelected ? Colors.orange : Colors.grey.shade500,
                      ),
                    ),
                    value: !isRandomMode && isChecked,
                    activeColor: Colors.teal,
                    onChanged: isRandomMode || isLastSelected
                        ? null
                        : (_) => ref
                            .read(soundMatchProvider.notifier)
                            .toggleCategory(cat.id),
                  ),
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
