import 'package:flutter_test/flutter_test.dart';
import 'package:trutouch/data/models/utils.dart';
import 'package:trutouch/data/models/module.dart';
import 'package:trutouch/data/models/content_item.dart';

void main() {
  group('Data Layer Tests', () {
    test('stripResPrefix correctly transforms Godot paths', () {
      expect(stripResPrefix('res://assets/images/cat.webp'), 'assets/images/cat.webp');
      expect(stripResPrefix('assets/audio/dog.mp3'), 'assets/audio/dog.mp3');
    });

    test('Module.fromJson parses correctly', () {
      final json = {
        "id": "board_book",
        "name": "Board Book",
        "icon": "assets/modules/board_book/icon.webp",
        "route": "/board-book",
        "dataPath": "assets/modules/board_book/content.json",
        "enabled": true
      };

      final module = Module.fromJson(json);
      expect(module.id, 'board_book');
      expect(module.name, 'Board Book');
      expect(module.enabled, isTrue);
    });

    test('ContentItem.fromJson strips Godot paths and adjusts .ogv to .mp4', () {
      final json = {
        "name": "Cat",
        "image": "res://assets/modules/board_book/images/cat.webp",
        "voice": "res://assets/modules/board_book/audio/voice/cat.mp3",
        "sound": "res://assets/modules/board_book/audio/sounds/cat.mp3",
        "sound_delay": 0.5,
        "video": "res://assets/modules/board_book/images/cat.ogv"
      };

      final item = ContentItem.fromJson(json);
      expect(item.name, 'Cat');
      expect(item.imagePath, 'assets/modules/board_book/images/cat.webp');
      expect(item.videoPath, 'assets/modules/board_book/images/cat.mp4'); 
    });
  });
}
