import 'package:flutter/material.dart';
import 'presentation/pages/loading_page.dart';

void main() {
  runApp(const MyApp());
}

/// The root application widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lifebliss',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoadingPage(),
    );
  }
}
