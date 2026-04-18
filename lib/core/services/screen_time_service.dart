import 'dart:async';
import 'package:flutter/foundation.dart';
import 'settings_service.dart';

class ScreenTimeService extends ChangeNotifier {
  final SettingsService _settings;
  Timer? _timer;

  ScreenTimeService(this._settings) {
    _init();
  }

  void _init() {
    _checkDailyReset();
    // Also start a periodic timer to update usage
    _startTimer();
  }

  void _checkDailyReset() {
    final today = _getTodayKey();
    if (_settings.lastUsageDate != today) {
      _settings.setMinutesUsedToday(0);
      _settings.setLastUsageDate(today);
      notifyListeners();
    }
  }

  String _getTodayKey() {
    final now = DateTime.now();
    return "${now.year}-${now.month}-${now.day}";
  }

  void _startTimer() {
    _timer?.cancel();
    // Update every minute the app is active
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkDailyReset();
      final limit = _settings.screenTimeLimitMinutes;
      if (limit > 0) {
        final current = _settings.minutesUsedToday;
        _settings.setMinutesUsedToday(current + 1);
        notifyListeners();
      }
    });
  }

  bool get isLimitReached {
    final limit = _settings.screenTimeLimitMinutes;
    if (limit <= 0) return false;
    return _settings.minutesUsedToday >= limit;
  }

  /// Called by the overlay to reset or extend time if needed by the parent
  Future<void> resetUsage() async {
    await _settings.setMinutesUsedToday(0);
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
