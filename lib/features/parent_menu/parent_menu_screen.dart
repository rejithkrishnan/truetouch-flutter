import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import 'screens/board_book_settings_screen.dart';
import 'screens/bubble_pop_settings_screen.dart';
import 'screens/sound_match_settings_screen.dart';
import 'widgets/settings_shared_widgets.dart';

class ParentMenuDialog extends ConsumerWidget {
  const ParentMenuDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _ParentMenuHub();
  }
}

class _ParentMenuHub extends ConsumerStatefulWidget {
  const _ParentMenuHub();

  @override
  ConsumerState<_ParentMenuHub> createState() => _ParentMenuHubState();
}

class _ParentMenuHubState extends ConsumerState<_ParentMenuHub> {
  late TextEditingController _nameController;
  late double _musicVol;
  late double _voiceVol;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsServiceProvider);
    _nameController = TextEditingController(text: settings.childName);
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

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Parent Settings',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        children: [
          // ── Section: Child Profile ──
          const SectionHeader(label: 'Child Profile'),
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
                  'Nickname',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter name...',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) => settings.setChildName(val),
                ),
              ],
            ),
          ),

          // ── Section: Apps & Games ──
          const SectionHeader(label: 'Apps & Games'),
          SettingsTile(
            icon: Icons.library_books_rounded,
            iconColor: AppColors.nurseryPalette[1],
            title: 'Board Book Settings',
            subtitle: 'Configure cards, categories, and view stats',
            onTap:
                () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const BoardBookSettingsScreen(),
                  ),
                ),
          ),
          SettingsTile(
            icon: Icons.music_note_rounded,
            iconColor: Colors.teal,
            title: 'Sound Match Settings',
            subtitle: 'Customize difficulty and game options',
            onTap:
                () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SoundMatchSettingsScreen(),
                  ),
                ),
          ),

          SettingsTile(
            icon: Icons.bubble_chart_rounded,
            iconColor: Colors.blueAccent,
            title: 'Pop the Bubbles Settings',
            subtitle: 'Customize letters, numbers, and speed',
            onTap:
                () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const BubblePopSettingsScreen(),
                  ),
                ),
          ),

          // ── Section: Global Audio ──
          const SectionHeader(label: 'Global Audio'),
          SettingsTile(
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
          SettingsTile(
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

          const SubSectionHeader(label: 'Volume Master Control'),
          VolumeSliderTile(
            icon: Icons.music_note_rounded,
            label: 'Background Music',
            value: _musicVol,
            onChanged: (val) {
              setState(() => _musicVol = val);
              ref.read(audioServiceProvider).updateBgmVolume(val);
            },
            onChangeEnd: (val) => settings.setMusicVolume(val),
          ),
          VolumeSliderTile(
            icon: Icons.record_voice_over_rounded,
            label: 'Voice & Sounds',
            value: _voiceVol,
            onChanged: (val) => setState(() => _voiceVol = val),
            onChangeEnd: (val) => settings.setVoiceVolume(val),
          ),

          // ── Section: Safety & Limits ──
          const SectionHeader(label: 'Safety & Limits'),
          SettingsTile(
            icon: Icons.timer_rounded,
            iconColor: Colors.deepOrange,
            title: 'Daily Screen Time',
            subtitle: 'Used: ${settings.minutesUsedToday} min today',
            trailing: DropdownButton<int>(
              value: settings.screenTimeLimitMinutes,
              underline: const SizedBox.shrink(),
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

          // ── Section: Data Management ──
          const SectionHeader(label: 'Data Management'),
          SettingsTile(
            icon: Icons.delete_forever_rounded,
            iconColor: Colors.redAccent,
            title: 'Reset All Progress',
            subtitle: 'Clear stars, points, and celebrations',
            trailing: TextButton(
              onPressed: () => _showResetConfirmation(context, ref),
              child: const Text(
                'RESET',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // ── Section: About ──
          const SectionHeader(label: 'About'),
          const SettingsTile(
            icon: Icons.info_outline_rounded,
            iconColor: Colors.grey,
            title: 'TrueTouch',
            subtitle: 'Version 1.0.0 (Beta)',
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Future<void> _showResetConfirmation(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reset All Progress?'),
            content: const Text(
              'This will permanently delete all exploration data. This cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('CANCEL'),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('RESET EVERYTHING'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await ref.read(progressServiceProvider).resetAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All progress has been reset.')),
        );
      }
    }
  }
}
