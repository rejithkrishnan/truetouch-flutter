import 'utils.dart';

class ContentItem {
  final String id;
  final String name;
  final String imagePath;
  final String? soundPath;
  final String? videoPath;
  final bool isVideo;

  ContentItem({
    required this.id,
    required this.name,
    required this.imagePath,
    this.soundPath,
    this.videoPath,
    this.isVideo = false,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      id: json['id'] as String,
      name: json['name'] as String,
      imagePath: stripResPrefix(json['image'] as String),
      soundPath:
          json['sound'] != null ? stripResPrefix(json['sound'] as String) : null,
      videoPath:
          json['video'] != null ? stripResPrefix(json['video'] as String) : null,
      isVideo: json['is_video'] as bool? ?? false,
    );
  }
}
