import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/settings_shared_widgets.dart';

class BubblePopSettingsScreen extends ConsumerStatefulWidget {
  const BubblePopSettingsScreen({super.key});

  @override
  ConsumerState<BubblePopSettingsScreen> createState() =>
      _BubblePopSettingsScreenState();
}

class _BubblePopSettingsScreenState extends ConsumerState<BubblePopSettingsScreen> {
  late double _speed;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsServiceProvider);
    _speed = settings.bubblePopSpeed;
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
          'Bubble Pop Settings',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        leading: const BackButton(color: Colors.black87),
      ),
      body: ListView(
        children: [
          const SectionHeader(label: 'Content Options'),
          
          SettingsTile(
            icon: Icons.abc_rounded,
            iconColor: AppColors.nurseryPalette[1],
            title: 'Show Letters',
            subtitle: 'A-Z characters in bubbles',
            trailing: Switch(
              value: settings.bubblePopShowLetters,
              activeColor: AppColors.nurseryPalette[1],
              onChanged: (val) async {
                // Prevent turning off if numbers are also off
                if (!val && !settings.bubblePopShowNumbers) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('At least one content type must be enabled.')),
                  );
                  return;
                }
                await settings.setBubblePopShowLetters(val);
                setState(() {});
              },
            ),
          ),
          
          SettingsTile(
            icon: Icons.numbers_rounded,
            iconColor: AppColors.nurseryPalette[2],
            title: 'Show Numbers',
            subtitle: '1-10 digits in bubbles',
            trailing: Switch(
              value: settings.bubblePopShowNumbers,
              activeColor: AppColors.nurseryPalette[2],
              onChanged: (val) async {
                // Prevent turning off if letters are also off
                if (!val && !settings.bubblePopShowLetters) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('At least one content type must be enabled.')),
                  );
                  return;
                }
                await settings.setBubblePopShowNumbers(val);
                setState(() {});
              },
            ),
          ),

          const SectionHeader(label: 'Difficulty & Gameplay'),

          SettingsTile(
            icon: Icons.bubble_chart_rounded,
            iconColor: AppColors.nurseryPalette[3],
            title: 'Max Bubbles on Screen',
            subtitle: 'Adjust how many bubbles float at once',
            trailing: DropdownButton<int>(
              value: settings.bubblePopMaxBubbles,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(value: 3, child: Text('3 Bubbles (Easy)')),
                DropdownMenuItem(value: 5, child: Text('5 Bubbles (Normal)')),
                DropdownMenuItem(value: 8, child: Text('8 Bubbles (Hard)')),
              ],
              onChanged: (val) async {
                if (val != null) {
                  await settings.setBubblePopMaxBubbles(val);
                  setState(() {});
                }
              },
            ),
          ),

          const SubSectionHeader(label: 'Bubble Float Speed'),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Slower',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Faster',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _speed,
                  min: 0.5,
                  max: 1.5,
                  divisions: 2,
                  activeColor: AppColors.nurseryPalette[4],
                  label: _speed == 0.5 
                      ? 'Slow' 
                      : (_speed == 1.0 ? 'Normal' : 'Fast'),
                  onChanged: (val) => setState(() => _speed = val),
                  onChangeEnd: (val) => settings.setBubblePopSpeed(val),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}
