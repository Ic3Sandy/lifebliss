import 'package:flutter/material.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const List<List<Color>> kColorPairs = [
    [Colors.white, Colors.blue],
    [Colors.pink, Colors.purple],
    [Colors.amber, Colors.orange],
    [Colors.lightGreen, Colors.teal],
    [Colors.lightBlue, Colors.indigo],
    [Colors.red, Colors.deepOrange],
  ];

  int _currentColorPairIndex = 0;

  final Random _random = Random();

  void _changeBackgroundColor() {
    if (kColorPairs.length <= 1) return;
    
    setState(() {
      // Generate a new random index different from the current one
      int newIndex;
      do {
        newIndex = _random.nextInt(kColorPairs.length);
      } while (newIndex == _currentColorPairIndex);
      
      _currentColorPairIndex = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _HomePageBody(
        colorPairs: kColorPairs,
        currentColorPairIndex: _currentColorPairIndex,
        changeBackgroundColor: _changeBackgroundColor,
      ),
    );
  }
}

class _HomePageBody extends StatelessWidget {
  final List<List<Color>> colorPairs;
  final int currentColorPairIndex;
  final VoidCallback changeBackgroundColor;

  const _HomePageBody({
    required this.colorPairs,
    required this.currentColorPairIndex,
    required this.changeBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Container(
      key: const Key('background_container'),
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colorPairs[currentColorPairIndex],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: changeBackgroundColor,
            child: Text(
              'Lifebliss',
              style: _getTitleTextStyle(screenSize.width, context),
            ),
          ),
        ],
      ),
    );
  }
  
  TextStyle _getTitleTextStyle(double screenWidth, BuildContext context) {
    return TextStyle(
      color: Colors.blue.shade900,
      fontSize: screenWidth < 600 ? 40 : 72,
      fontWeight: FontWeight.bold,
      letterSpacing: 2.0,
      shadows: [
        Shadow(
          blurRadius: 10.0,
          color: Colors.blue.withOpacity(0.5),
          offset: const Offset(5.0, 5.0),
        ),
      ],
    );
  }
}
