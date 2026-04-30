import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/category.dart';

/// Point values
const int kDiscoveryPoints = 10; // First tap bonus
const int kRepeatPoints = 2;     // Each subsequent tap

/// Tracks tap counts, points, and engagement per item/category.
/// Key format:  progress_<moduleId>_<itemId>
class ProgressService {
  final SharedPreferences _prefs;

  static const String _prefix = 'progress_';

  ProgressService(this._prefs);

  String _key(String moduleId, String itemId) =>
      '$_prefix${moduleId}_$itemId';

  // ── Per-Item ──────────────────────────────────────────────────────────────

  int getTapCount(String moduleId, String itemId) =>
      _prefs.getInt(_key(moduleId, itemId)) ?? 0;

  bool isDiscovered(String moduleId, String itemId) =>
      getTapCount(moduleId, itemId) > 0;

  /// Points for a single item.
  int getItemPoints(String moduleId, String itemId) {
    final taps = getTapCount(moduleId, itemId);
    if (taps == 0) return 0;
    return kDiscoveryPoints + (taps - 1) * kRepeatPoints;
  }

  /// Star rating 1–5 based on tap count.
  /// Made more immediate for toddlers.
  int getStarRating(String moduleId, String itemId) {
    final taps = getTapCount(moduleId, itemId);
    if (taps == 0) return 0;
    if (taps == 1) return 1;
    if (taps == 2) return 2;
    if (taps == 3) return 3;
    if (taps == 4) return 4;
    return 5;
  }

  Future<void> recordTap(String moduleId, String itemId) async {
    final key = _key(moduleId, itemId);
    await _prefs.setInt(key, (_prefs.getInt(key) ?? 0) + 1);
  }

  // ── Celebration Tracking ──────────────────────────────────────────────────

  static const String _celebrationPrefix = 'celebrated_';

  String _celebrationKey(String moduleId, String categoryId) =>
      '$_celebrationPrefix${moduleId}_$categoryId';

  bool isCategoryCelebrated(String moduleId, String categoryId) =>
      _prefs.getBool(_celebrationKey(moduleId, categoryId)) ?? false;

  Future<void> markCategoryCelebrated(String moduleId, String categoryId) async {
    await _prefs.setBool(_celebrationKey(moduleId, categoryId), true);
  }

  String _itemCelebrationKey(String moduleId, String itemId) =>
      '${_celebrationPrefix}item_${moduleId}_$itemId';

  bool isItemCelebrated(String moduleId, String itemId) =>
      _prefs.getBool(_itemCelebrationKey(moduleId, itemId)) ?? false;

  Future<void> markItemCelebrated(String moduleId, String itemId) async {
    await _prefs.setBool(_itemCelebrationKey(moduleId, itemId), true);
  }

  bool isCategoryComplete(String moduleId, List<String> itemIds) {
    if (itemIds.isEmpty) return false;
    return itemIds.every((id) => isDiscovered(moduleId, id));
  }

  // ── Total / Module ────────────────────────────────────────────────────────

  int discoveredCount(String moduleId, List<String> allItemIds) =>
      allItemIds.where((id) => isDiscovered(moduleId, id)).length;

  int totalPoints(String moduleId, List<String> allItemIds) => allItemIds
      .map((id) => getItemPoints(moduleId, id))
      .fold(0, (a, b) => a + b);

  // ── Category Stats ────────────────────────────────────────────────────────

  /// Returns per-category stats sorted by total points descending.
  List<CategoryStat> getCategoryStats(
      String moduleId, List<Category> categories) {
    final stats = categories.map((cat) {
      final itemIds = cat.items.map((i) => i.id).toList();
      final totalTaps = itemIds
          .map((id) => getTapCount(moduleId, id))
          .fold(0, (a, b) => a + b);
      final discovered = discoveredCount(moduleId, itemIds);
      final points = totalPoints(moduleId, itemIds);
      return CategoryStat(
        categoryName: cat.name,
        totalItems: cat.items.length,
        discoveredItems: discovered,
        totalTaps: totalTaps,
        points: points,
      );
    }).toList();

    stats.sort((a, b) => b.points.compareTo(a.points));
    return stats;
  }

  Future<void> resetAll() async {
    final keys = _prefs.getKeys().where((k) => 
      k.startsWith(_prefix) || 
      k.startsWith(_celebrationPrefix) ||
      k.startsWith('sm_stars_')
    ).toList();
    for (final k in keys) {
      await _prefs.remove(k);
    }
  }

  // ── Sound Match Scoring ──────────────────────────────────────────────────

  String _smStarsKey(String categoryId) => 'sm_stars_$categoryId';

  /// Best score: 0 mistakes = 3, 1 = 2, 2+ = 1 star.
  Future<void> recordSoundMatchResult(String categoryId, int mistakes) async {
    final key = _smStarsKey(categoryId);
    final currentStars = getSoundMatchStars(categoryId);
    int newStars = 1;
    if (mistakes == 0) newStars = 3;
    else if (mistakes == 1) newStars = 2;

    if (newStars > currentStars) {
      await _prefs.setInt(key, newStars);
    }
  }

  int getSoundMatchStars(String categoryId) =>
      _prefs.getInt(_smStarsKey(categoryId)) ?? 0;
}

/// Stats summary for one category.
class CategoryStat {
  final String categoryName;
  final int totalItems;
  final int discoveredItems;
  final int totalTaps;
  final int points;

  const CategoryStat({
    required this.categoryName,
    required this.totalItems,
    required this.discoveredItems,
    required this.totalTaps,
    required this.points,
  });

  double get discoveryRatio =>
      totalItems == 0 ? 0 : discoveredItems / totalItems;
}
