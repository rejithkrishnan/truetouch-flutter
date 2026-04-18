import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../board_book/providers/board_book_providers.dart';

class ParentMenuDialog extends ConsumerWidget {
  const ParentMenuDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _ParentMenuPage();
  }
}

class _ParentMenuPage extends ConsumerStatefulWidget {
  const _ParentMenuPage();

  @override
  ConsumerState<_ParentMenuPage> createState() => _ParentMenuPageState();
}

class _ParentMenuPageState extends ConsumerState<_ParentMenuPage> {
  late TextEditingController _nameController;
  late double _musicVol;
  late double _voiceVol;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsServiceProvider);
    _nameController = TextEditingController(
      text: settings.childName,
    );
    _musicVol = settings.musicVolume;
    _voiceVol = settings.voiceVolume;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

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
        shadowColor: Colors.black12,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Parent Settings',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
      body: ListView(
        children: [
          // ── Stats Dashboard ──────────────────────────────────
          allCategoriesAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (categories) {
              final allItemIds = categories
                  .expand((c) => c.items)
                  .map((i) => i.id)
                  .toList();
              final totalCount = allItemIds.length;
              final discoveredCount =
                  progress.discoveredCount('board_book', allItemIds);
              final pts = progress.totalPoints('board_book', allItemIds);
              final pct =
                  totalCount == 0 ? 0.0 : discoveredCount / totalCount;
              final categoryStats =
                  progress.getCategoryStats('board_book', categories);
              final maxPts = categoryStats.isEmpty
                  ? 1
                  : (categoryStats.first.points == 0
                      ? 1
                      : categoryStats.first.points);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero overview card ──
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.nurseryPalette[0],
                          AppColors.nurseryPalette[2],
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color:
                              AppColors.nurseryPalette[0].withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title row
                        Row(
                          children: [
                            const Icon(Icons.auto_graph_rounded,
                                color: Colors.white, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              'Board Book Stats',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Stat chips row
                        Row(
                          children: [
                            _StatChip(
                              icon: Icons.touch_app_rounded,
                              label: 'Discovered',
                              value: '$discoveredCount / $totalCount',
                            ),
                            const SizedBox(width: 10),
                            _StatChip(
                              icon: Icons.star_rounded,
                              label: 'Points',
                              value: '$pts ⭐',
                              highlight: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 10,
                            backgroundColor: Colors.white24,
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(
                                    Colors.amber),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          discoveredCount == totalCount && totalCount > 0
                              ? '🎉 All cards discovered!'
                              : '${totalCount - discoveredCount} cards left to explore',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),

                  // ── Category breakdown ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Text(
                      'Category Engagement',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.black54,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                    ),
                  ),
                  ...categoryStats.map((stat) {
                    final barRatio = stat.points / maxPts;
                    final rankColors = [
                      Colors.amber.shade600,
                      Colors.orange.shade400,
                      Colors.blue.shade400,
                    ];
                    final idx = categoryStats.indexOf(stat);
                    final barColor =
                        idx < rankColors.length ? rankColors[idx] : Colors.grey;

                    return Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (idx == 0)
                                const Text('🥇 ',
                                    style: TextStyle(fontSize: 16))
                              else if (idx == 1)
                                const Text('🥈 ',
                                    style: TextStyle(fontSize: 16))
                              else if (idx == 2)
                                const Text('🥉 ',
                                    style: TextStyle(fontSize: 16))
                              else
                                const SizedBox(width: 24),
                              Expanded(
                                child: Text(
                                  stat.categoryName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Text(
                                '${stat.points} pts',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: barColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: barRatio,
                              minHeight: 7,
                              backgroundColor: Colors.grey.shade100,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(barColor),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                '${stat.discoveredItems}/${stat.totalItems} cards',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey.shade500),
                              ),
                              const Spacer(),
                              Text(
                                '${stat.totalTaps} taps',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              );
            },
          ),

          // ── Section: Audio ──────────────────────────────────
          const _SectionHeader(label: 'Audio'),

          _SettingsTile(
            icon: Icons.volume_up_rounded,
            iconColor: AppColors.nurseryPalette[2],
            title: 'Sound Effects & Voice',
            subtitle: 'Play voice clips and animal sounds on tap',
            trailing: Switch(
              value: settings.isSoundEnabled,
              activeColor: AppColors.nurseryPalette[2],
              onChanged: (val) async {
                await settings.setSoundEnabled(val);
                setState(() {});
              },
            ),
          ),

          _SettingsTile(
            icon: Icons.music_note_rounded,
            iconColor: AppColors.nurseryPalette[4],
            title: 'Background Music',
            subtitle: 'Soft piano music while exploring',
            trailing: Switch(
              value: settings.isMusicEnabled,
              activeColor: AppColors.nurseryPalette[4],
              onChanged: (val) async {
                await settings.setMusicEnabled(val);
                ref.read(audioServiceProvider).updateBgmState(val);
                setState(() {});
              },
            ),
          ),

          _SettingsTile(
            icon: Icons.vibration_rounded,
            iconColor: AppColors.nurseryPalette[3],
            title: 'Vibration',
            subtitle: 'Haptic feedback on card taps',
            trailing: Switch(
              value: settings.isVibrationEnabled,
              activeColor: AppColors.nurseryPalette[3],
              onChanged: (val) async {
                await settings.setVibrationEnabled(val);
                setState(() {});
              },
            ),
          ),

          const _SubSectionHeader(label: 'Volume Levels'),
          
          _VolumeSliderTile(
            icon: Icons.music_note_rounded,
            label: 'Background Music',
            value: _musicVol,
            onChanged: (val) {
              setState(() => _musicVol = val);
              ref.read(audioServiceProvider).updateBgmVolume(val);
            },
            onChangeEnd: (val) async {
              await settings.setMusicVolume(val);
              setState(() {});
            },
          ),

          _VolumeSliderTile(
            icon: Icons.record_voice_over_rounded,
            label: 'Voice & Sounds',
            value: _voiceVol,
            onChanged: (val) {
              setState(() => _voiceVol = val);
            },
            onChangeEnd: (val) async {
              await settings.setVoiceVolume(val);
              setState(() {});
            },
          ),

          // ── Section: Board Book ─────────────────────────────
          const _SectionHeader(label: '📖  Board Book'),

          _SettingsTile(
            icon: Icons.library_books_rounded,
            iconColor: AppColors.nurseryPalette[1],
            title: 'Cards Per Page',
            subtitle: 'How many cards are shown at once',
            trailing: DropdownButton<int>(
              value: settings.cardsPerPage,
              underline: const SizedBox.shrink(),
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Colors.black87),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
              items: [1, 2, 3, 4].map((v) {
                return DropdownMenuItem<int>(
                  value: v,
                  child: Text('$v card${v > 1 ? 's' : ''}'),
                );
              }).toList(),
              onChanged: (val) async {
                if (val != null) {
                  await settings.setCardsPerPage(val);
                  setState(() {});
                }
              },
            ),
          ),

          _SettingsTile(
            icon: Icons.category_rounded,
            iconColor: AppColors.nurseryPalette[0],
            title: 'Active Categories',
            subtitle: 'Choose which categories appear in the book',
            trailing: allCategoriesAsync.when(
              loading: () => const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (_, __) => const Icon(Icons.error_outline, color: Colors.red),
              data: (categories) {
                final enabledCount = categories
                    .where((c) => !disabledCategories.contains(c.id))
                    .length;
                return GestureDetector(
                  onTap: () => _showCategoryDrawer(
                    context, ref, categories, disabledCategories,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$enabledCount / ${categories.length}',
                        style: TextStyle(
                          color: AppColors.nurseryPalette[0],
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right_rounded,
                          color: Colors.black38, size: 20),
                    ],
                  ),
                );
              },
            ),
          ),

          // ── Section: Screen Time ────────────────────────────
          const _SectionHeader(label: '⏱️  Screen Time'),

          _SettingsTile(
            icon: Icons.timer_rounded,
            iconColor: Colors.deepOrange,
            title: 'Daily Limit',
            subtitle: 'App locks after total daily usage',
            trailing: DropdownButton<int>(
              value: settings.screenTimeLimitMinutes,
              underline: const SizedBox.shrink(),
              style: Theme.of(context).textTheme.bodyLarge,
              items: [
                const DropdownMenuItem(value: 0, child: Text('Off')),
                const DropdownMenuItem(value: 15, child: Text('15 min')),
                const DropdownMenuItem(value: 30, child: Text('30 min')),
                const DropdownMenuItem(value: 60, child: Text('60 min')),
              ],
              onChanged: (val) async {
                if (val != null) {
                  await settings.setScreenTimeLimitMinutes(val);
                  setState(() {});
                }
              },
            ),
          ),

          _SettingsTile(
            icon: Icons.hourglass_bottom_rounded,
            iconColor: Colors.blueGrey,
            title: 'Used Today',
            subtitle: 'Total cumulative time',
            trailing: Text(
              '${settings.minutesUsedToday} min',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),

          // ── Section: Personalisation ────────────────────────
          const _SectionHeader(label: '👤  Personalisation'),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Child\'s Name',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter name...',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) async {
                    await settings.setChildName(val);
                  },
                ),
              ],
            ),
          ),

          // ── Section: Sound Match ────────────────────────────
          const _SectionHeader(label: '🔊  Sound Match'),

          const _SettingsTile(
            icon: Icons.tune_rounded,
            iconColor: Colors.teal,
            title: 'Coming Soon',
            subtitle: 'Sound Match settings will appear here',
          ),

          const _SectionHeader(label: 'About'),

          const _SettingsTile(
            icon: Icons.child_care_rounded,
            iconColor: Colors.pinkAccent,
            title: 'TrueTouch',
            subtitle: 'Safe Learning Playroom for toddlers',
          ),
          const _SettingsTile(
            icon: Icons.info_outline_rounded,
            iconColor: Colors.blueGrey,
            title: 'Version',
            subtitle: '1.0.0',
          ),

          // ── Section: Data Management ─────────────────────
          const _SectionHeader(label: 'Data Management'),

          _SettingsTile(
            icon: Icons.delete_forever_rounded,
            iconColor: Colors.redAccent,
            title: 'Reset All Progress',
            subtitle: 'Clear all stars, points, and celebrations',
            trailing: TextButton(
              onPressed: () => _showResetConfirmation(context, ref),
              child: const Text('RESET', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ),

          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Future<void> _showResetConfirmation(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Progress?'),
        content: const Text(
          'This will permanently delete all your child\'s stars, exploration points, and category completion trophies.\n\nThis cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('YES, RESET EVERYTHING'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(progressServiceProvider).resetAll();
      ref.invalidate(boardBookCategoriesProvider); // Refresh UI
      if (mounted) setState(() {});
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All progress has been reset.')),
        );
      }
    }
  }

  void _showCategoryDrawer(
    BuildContext context,
    WidgetRef ref,
    List categories,
    List<String> disabledCategories,
  ) {
    final settings = ref.read(settingsServiceProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CategoryDrawer(
        categories: categories,
        initialDisabled: List<String>.from(disabledCategories),
        onSave: (newDisabled) async {
          await settings.setDisabledCategories(newDisabled);
          ref.invalidate(boardBookCategoriesProvider);
          ref.invalidate(allBoardBookCategoriesProvider);
          setState(() {});
        },
      ),
    );
  }
}

class _CategoryDrawer extends StatefulWidget {
  final List categories;
  final List<String> initialDisabled;
  final Future<void> Function(List<String>) onSave;

  const _CategoryDrawer({
    required this.categories,
    required this.initialDisabled,
    required this.onSave,
  });

  @override
  State<_CategoryDrawer> createState() => _CategoryDrawerState();
}

class _CategoryDrawerState extends State<_CategoryDrawer> {
  late List<String> _disabled;

  @override
  void initState() {
    super.initState();
    _disabled = List<String>.from(widget.initialDisabled);
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.categories;
    final enabledCount = categories.where((c) => !_disabled.contains(c.id)).length;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Row(
              children: [
                const Icon(Icons.category_rounded, color: Colors.black54),
                const SizedBox(width: 10),
                Text(
                  'Board Book Categories',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                ),
                const Spacer(),
                Text(
                  '$enabledCount of ${categories.length} active',
                  style: const TextStyle(fontSize: 12, color: Colors.black45),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Category checkboxes
          ...categories.map((cat) {
            final isEnabled = !_disabled.contains(cat.id);
            final canDisable = isEnabled ? enabledCount > 1 : true;
            return CheckboxListTile(
              value: isEnabled,
              activeColor: AppColors.nurseryPalette[0],
              title: Text(
                cat.name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isEnabled ? Colors.black87 : Colors.black38,
                ),
              ),
              subtitle: Text(
                '${cat.items.length} items',
                style: const TextStyle(fontSize: 12, color: Colors.black38),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: canDisable
                  ? (val) {
                      setState(() {
                        if (val == true) {
                          _disabled.remove(cat.id);
                        } else {
                          if (!_disabled.contains(cat.id)) {
                            _disabled.add(cat.id);
                          }
                        }
                      });
                    }
                  : null,
            );
          }),

          const Divider(height: 1),

          // Save button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.nurseryPalette[0],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    await widget.onSave(_disabled);
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable components ───────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.black45,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

class _SubSectionHeader extends StatelessWidget {
  final String label;
  const _SubSectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black54,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: Colors.black45),
        ),
        trailing: trailing,
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String categoryName;
  final int itemCount;
  final bool isEnabled;
  final bool canDisable;
  final ValueChanged<bool> onChanged;

  const _CategoryTile({
    required this.categoryName,
    required this.itemCount,
    required this.isEnabled,
    required this.canDisable,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        color: isEnabled ? Colors.white : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEnabled
              ? AppColors.nurseryPalette[0].withValues(alpha: 0.3)
              : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        title: Text(
          categoryName,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isEnabled ? Colors.black87 : Colors.black38,
          ),
        ),
        subtitle: Text(
          '$itemCount items',
          style: const TextStyle(fontSize: 12, color: Colors.black38),
        ),
        trailing: Tooltip(
          message: !canDisable ? 'At least one category must be active' : '',
          child: Switch(
            value: isEnabled,
            activeColor: AppColors.nurseryPalette[0],
            onChanged: canDisable ? onChanged : null,
          ),
        ),
      ),
    );
  }
}

class _VolumeSliderTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeEnd;

  const _VolumeSliderTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    this.onChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black45, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                  ),
                  child: Slider(
                    value: value,
                    min: 0,
                    max: 1,
                    activeColor: AppColors.nurseryPalette[0],
                    inactiveColor: Colors.grey.shade100,
                    onChanged: onChanged,
                    onChangeEnd: onChangeEnd,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${(value * 100).toInt()}%',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black38),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

// ── Stat chip inside the hero card ───────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: highlight
              ? Colors.amber.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
          border: highlight
              ? Border.all(color: Colors.amber.shade300, width: 1)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: Colors.white70),
                const SizedBox(width: 4),
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
