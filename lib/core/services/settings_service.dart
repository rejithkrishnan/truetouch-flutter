import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  static const _keySound = 'app_sound_enabled';
  static const _keyMusic = 'app_music_enabled';
  static const _keyVibration = 'app_vibration_enabled';
  static const _keyCardsPerPage = 'board_book_cards_per_page';
  static const _keyDisabledCategories = 'board_book_disabled_categories';

  static const _keyVoiceVolume = 'app_voice_volume';
  static const _keyMusicVolume = 'app_music_volume';
  static const _keyChildName = 'app_child_name';
  static const _keyScreenTimeLimit = 'app_screen_time_limit';
  static const _keyMinutesUsedToday = 'app_minutes_used_today';
  static const _keyLastUsageDate = 'app_last_usage_date';
  
  // -- Bubble Pop Settings --
  static const _keyBubblePopShowLetters = 'bubble_pop_show_letters';
  static const _keyBubblePopShowNumbers = 'bubble_pop_show_numbers';
  static const _keyBubblePopMaxBubbles = 'bubble_pop_max_bubbles';
  static const _keyBubblePopSpeed = 'bubble_pop_speed';

  bool get isSoundEnabled => _prefs.getBool(_keySound) ?? true;
  Future<bool> setSoundEnabled(bool value) => _prefs.setBool(_keySound, value);

  bool get isMusicEnabled => _prefs.getBool(_keyMusic) ?? true;
  Future<bool> setMusicEnabled(bool value) => _prefs.setBool(_keyMusic, value);

  bool get isVibrationEnabled => _prefs.getBool(_keyVibration) ?? true;
  Future<bool> setVibrationEnabled(bool value) => _prefs.setBool(_keyVibration, value);

  int get cardsPerPage => _prefs.getInt(_keyCardsPerPage) ?? 1;
  Future<bool> setCardsPerPage(int value) => _prefs.setInt(_keyCardsPerPage, value);

  List<String> get disabledCategories => _prefs.getStringList(_keyDisabledCategories) ?? [];
  Future<bool> setDisabledCategories(List<String> categories) => 
      _prefs.setStringList(_keyDisabledCategories, categories);

  // -- Phase 2 Features --

  double get voiceVolume => _prefs.getDouble(_keyVoiceVolume) ?? 0.8;
  Future<bool> setVoiceVolume(double value) => _prefs.setDouble(_keyVoiceVolume, value);

  double get musicVolume => _prefs.getDouble(_keyMusicVolume) ?? 0.3;
  Future<bool> setMusicVolume(double value) => _prefs.setDouble(_keyMusicVolume, value);

  String get childName => _prefs.getString(_keyChildName) ?? '';
  Future<bool> setChildName(String value) => _prefs.setString(_keyChildName, value);

  int get screenTimeLimitMinutes => _prefs.getInt(_keyScreenTimeLimit) ?? 0;
  Future<bool> setScreenTimeLimitMinutes(int value) => _prefs.setInt(_keyScreenTimeLimit, value);

  int get minutesUsedToday => _prefs.getInt(_keyMinutesUsedToday) ?? 0;
  Future<bool> setMinutesUsedToday(int value) => _prefs.setInt(_keyMinutesUsedToday, value);

  String get lastUsageDate => _prefs.getString(_keyLastUsageDate) ?? '';
  Future<bool> setLastUsageDate(String value) => _prefs.setString(_keyLastUsageDate, value);

  // -- Bubble Pop Features --

  bool get bubblePopShowLetters => _prefs.getBool(_keyBubblePopShowLetters) ?? true;
  Future<bool> setBubblePopShowLetters(bool value) => _prefs.setBool(_keyBubblePopShowLetters, value);

  bool get bubblePopShowNumbers => _prefs.getBool(_keyBubblePopShowNumbers) ?? true;
  Future<bool> setBubblePopShowNumbers(bool value) => _prefs.setBool(_keyBubblePopShowNumbers, value);

  int get bubblePopMaxBubbles => _prefs.getInt(_keyBubblePopMaxBubbles) ?? 5;
  Future<bool> setBubblePopMaxBubbles(int value) => _prefs.setInt(_keyBubblePopMaxBubbles, value);

  double get bubblePopSpeed => _prefs.getDouble(_keyBubblePopSpeed) ?? 1.0;
  Future<bool> setBubblePopSpeed(double value) => _prefs.setDouble(_keyBubblePopSpeed, value);
}
