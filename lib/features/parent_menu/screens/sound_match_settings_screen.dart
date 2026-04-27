import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/settings_shared_widgets.dart';
import '../../sound_match/providers/sound_match_provider.dart';
import '../../sound_match/models/sound_match_state.dart';

class SoundMatchSettingsScreen extends ConsumerWidget {
  const SoundMatchSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(soundMatchProvider);
    final categoriesAsync = ref.watch(allSoundMatchCategoriesProvider);

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
          const SectionHeader(label: 'Category'),

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
                    : 'Using selected categories below',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              value: isRandomMode,
              activeColor: Colors.deepPurple,
              onChanged: (val) =>
                  ref.read(soundMatchProvider.notifier).setRandomMode(val),
            ),
          ),

          // Category checkboxes (dimmed when random is on)
          AnimatedOpacity(
            opacity: isRandomMode ? 0.4 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: isRandomMode,
              child: categoriesAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, _) =>
                    Center(child: Text('Error loading categories: $err')),
                data: (categories) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isRandomMode && selectedIds.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: Text(
                          'Select at least one category below',
                          style: TextStyle(
                              fontSize: 12, color: Colors.orange.shade700),
                        ),
                      ),
                    ...categories.map((cat) {
                      final soundCount = cat.items
                          .where((i) => i.soundPath != null)
                          .length;
                      final isChecked = selectedIds.contains(cat.id);
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: isChecked ? Colors.teal.shade50 : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isChecked
                                ? Colors.teal
                                : Colors.grey.shade200,
                            width: isChecked ? 2 : 1,
                          ),
                        ),
                        child: CheckboxListTile(
                          secondary: CircleAvatar(
                            backgroundColor: isChecked
                                ? Colors.teal
                                : Colors.teal.withValues(alpha: 0.12),
                            child: Icon(Icons.category_rounded,
                                color: isChecked ? Colors.white : Colors.teal,
                                size: 18),
                          ),
                          title: Text(
                            cat.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: isChecked
                                  ? Colors.teal.shade800
                                  : Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            '$soundCount items with sound',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade500),
                          ),
                          value: isChecked,
                          activeColor: Colors.teal,
                          controlAffinity: ListTileControlAffinity.trailing,
                          onChanged: (_) => ref
                              .read(soundMatchProvider.notifier)
                              .toggleCategory(cat.id),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
