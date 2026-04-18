import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/module.dart';

class ModuleRepository {
  final String _modulesPath = 'assets/data/modules.json';

  Future<List<Module>> loadModules() async {
    try {
      final jsonString = await rootBundle.loadString(_modulesPath);
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      
      final modulesList = jsonData['modules'] as List<dynamic>? ?? [];
      
      return modulesList
          .map((e) => Module.fromJson(e as Map<String, dynamic>))
          .where((m) => m.enabled)
          .toList();
    } catch (e) {
      // Return empty list on failure — in production we'd log this or handle it gracefully
      return [];
    }
  }
}
