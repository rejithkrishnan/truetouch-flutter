import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MaterialApp(home: AssetTestScreen()));
}

class AssetTestScreen extends StatefulWidget {
  const AssetTestScreen({Key? key}) : super(key: key);

  @override
  _AssetTestScreenState createState() => _AssetTestScreenState();
}

class _AssetTestScreenState extends State<AssetTestScreen> {
  String status = 'Loading...';

  @override
  void initState() {
    super.initState();
    _testAsset();
  }

  Future<void> _testAsset() async {
    try {
      final json = await rootBundle.loadString('assets/modules/board_book/content.json');
      print('DEBUG: Successfully loaded JSON size \${json.length}');
      setState(() => status = 'Success: \${json.substring(0, 20)}...');
    } catch (e) {
      print('DEBUG: Error loading JSON: \$e');
      setState(() => status = 'Error: \$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(status),
      ),
    );
  }
}
