import 'utils.dart';

class Module {
  final String id;
  final String name;
  final String icon;
  final String route;
  final String dataPath;
  final bool enabled;

  const Module({
    required this.id,
    required this.name,
    required this.icon,
    required this.route,
    required this.dataPath,
    required this.enabled,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: stripResPrefix(json['icon'] as String),
      route: json['route'] as String,
      dataPath: stripResPrefix(json['dataPath'] as String),
      enabled: json['enabled'] as bool? ?? true,
    );
  }
}
