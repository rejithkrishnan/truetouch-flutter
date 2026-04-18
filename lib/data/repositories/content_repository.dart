import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/category.dart';

class ContentRepository {
  /// Loads all categories for a given module's dataPath mapping config 
  Future<List<Category>> loadContent(String dataPath) async {
    try {
      final jsonString = await rootBundle.loadString(dataPath);
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      
      final categoryList = jsonData['categories'] as List<dynamic>? ?? [];
      
      return categoryList
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('ERROR LOADING CONTENT: \$e');
      throw Exception('Failed to load content at \$dataPath: \$e');
    }
  }
}
