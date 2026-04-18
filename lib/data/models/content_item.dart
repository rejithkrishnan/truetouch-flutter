import 'utils.dart';

class ContentItem {
  final String name;
  final String imagePath;
  final String? voicePath;
  final String? soundPath;
  final double soundDelay;
  final String? videoPath;

  /// Stable identifier derived from name — used as the progress key.
  String get id => name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');

  const ContentItem({
    required this.name,
    required this.imagePath,
    this.voicePath,
    this.soundPath,
    this.soundDelay = 0.5,
    this.videoPath,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      name: json['label'] as String,
      imagePath: stripResPrefix(json['image'] as String),
      voicePath: json['voice'] != null ? stripResPrefix(json['voice'] as String) : null,
      soundPath: json['sound'] != null ? stripResPrefix(json['sound'] as String) : null,
      soundDelay: (json['sound_delay'] as num?)?.toDouble() ?? 0.5,
      // We will map .ogv to .mp4 during asset migration, so let's adjust the extension here just in case!
      videoPath: json['video'] != null ? stripResPrefix(json['video'] as String).replaceAll('.ogv', '.mp4') : null,
    );
  }
}
