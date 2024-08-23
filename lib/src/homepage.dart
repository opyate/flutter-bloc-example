import 'package:flutter/material.dart';
import 'legacy_app.dart'; // existing legacy app
import 'sample_bloc_feature/counter_page.dart';

class HomePage extends StatefulWidget {
  final MyApp legacyApp;

  const HomePage({super.key, required this.legacyApp});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isBlocAppActive = false; // Initially, the legacy app is active

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Selector'),
      ),
      body: Center(
        child: _isBlocAppActive ? const CounterPage() : widget.legacyApp,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("Switching app");
          setState(() {
            _isBlocAppActive = !_isBlocAppActive; // Toggle the active app
          });
        },
        child: const Icon(Icons.swap_horiz),
      ),
    );
  }
}
