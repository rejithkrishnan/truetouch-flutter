import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/module.dart';
import '../data/repositories/module_repository.dart';
import '../data/repositories/content_repository.dart';
import 'services/settings_service.dart';
import 'services/audio_service.dart';
import 'services/haptic_service.dart';
import 'services/progress_service.dart';
import 'services/screen_time_service.dart';
export 'routing/app_router.dart' show appRouterProvider;

// ---------- Repositories ----------

final moduleRepositoryProvider = Provider((ref) => ModuleRepository());
final contentRepositoryProvider = Provider((ref) => ContentRepository());

// ---------- Shared Preferences (must be overridden in main) ----------

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in ProviderScope');
});

// ---------- Services ----------

final settingsServiceProvider = Provider((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsService(prefs);
});

final audioServiceProvider = Provider<AudioService>((ref) {
  final settings = ref.watch(settingsServiceProvider);
  final service = AudioService(settings);
  ref.onDispose(() => service.dispose());
  return service;
});

final hapticServiceProvider = Provider((ref) {
  final settings = ref.watch(settingsServiceProvider);
  return HapticService(settings);
});

final progressServiceProvider = Provider<ProgressService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ProgressService(prefs);
});

final screenTimeServiceProvider = ChangeNotifierProvider<ScreenTimeService>((ref) {
  final settings = ref.watch(settingsServiceProvider);
  return ScreenTimeService(settings);
});

final screenTimeLimitReachedProvider = Provider<bool>((ref) {
  final service = ref.watch(screenTimeServiceProvider);
  return service.isLimitReached;
});

// ---------- Global State ----------

final modulesProvider = FutureProvider<List<Module>>((ref) async {
  final repo = ref.watch(moduleRepositoryProvider);
  return repo.loadModules();
});
