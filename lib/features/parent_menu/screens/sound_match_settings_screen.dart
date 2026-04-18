import 'package:flutter/material.dart';
import '../widgets/settings_shared_widgets.dart';

class SoundMatchSettingsScreen extends StatelessWidget {
  const SoundMatchSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Sound Match Settings', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const Column(
        children: [
          SectionHeader(label: 'Game Mode'),
          SettingsTile(
            icon: Icons.tune_rounded,
            iconColor: Colors.teal,
            title: 'Difficulty Scaling',
            subtitle: 'Coming soon: Adjust number of choices',
          ),
          SettingsTile(
            icon: Icons.help_outline_rounded,
            iconColor: Colors.blue,
            title: 'Learning Mode',
            subtitle: 'Coming soon: Guided matching',
          ),
        ],
      ),
    );
  }
}
