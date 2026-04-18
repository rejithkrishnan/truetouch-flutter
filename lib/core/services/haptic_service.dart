import 'package:flutter/services.dart';
import 'settings_service.dart';

class HapticService {
  final SettingsService _settings;

  HapticService(this._settings);

  Future<void> lightImpact() async {
    if (_settings.isVibrationEnabled) {
      await HapticFeedback.lightImpact();
    }
  }

  Future<void> mediumImpact() async {
    if (_settings.isVibrationEnabled) {
      await HapticFeedback.mediumImpact();
    }
  }

  Future<void> heavyImpact() async {
    if (_settings.isVibrationEnabled) {
      await HapticFeedback.heavyImpact();
    }
  }
}
