import 'content_item.dart';

class Category {
  final String id;
  final String name;
  final List<ContentItem> items;

  const Category({
    required this.id,
    required this.name,
    required this.items,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List<dynamic>? ?? [];
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      items: itemsList.map((e) => ContentItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
