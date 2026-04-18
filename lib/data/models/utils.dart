/// Helper to convert a Godot path (res://) to a Flutter asset path (assets/)
String stripResPrefix(String path) {
  if (path.startsWith('res://')) {
    return path.replaceFirst('res://', '');
  }
  return path;
}
