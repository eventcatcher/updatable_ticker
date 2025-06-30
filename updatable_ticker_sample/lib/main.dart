import 'package:flutter/material.dart';
import 'package:updatable_ticker_sample/updatable_ticker_example_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter UpdatableTicker Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: UpdatableTickerExamplePage(),
      ),
    );
  }
}
