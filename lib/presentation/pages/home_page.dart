import 'package:flutter/material.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<List<Color>> _colorPairs = [
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
    setState(() {
      int newIndex;
      do {
        newIndex = _random.nextInt(_colorPairs.length);
      } while (newIndex == _currentColorPairIndex && _colorPairs.length > 1);
      
      _currentColorPairIndex = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      body: _HomePageBody(
        colorPairs: _colorPairs,
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
              style: TextStyle(
                color: Colors.blue.shade900,
                fontSize: screenSize.width < 600 ? 40 : 72,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.blue.withOpacity(0.5),
                    offset: const Offset(5.0, 5.0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
