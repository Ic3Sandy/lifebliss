import 'dart:math';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Service responsible for generating random colors
class ColorService {
  final Random _random = Random();

  /// Returns a random Material color
  Color getRandomColor() {
    // Get random values for RGB
    final int r = _random.nextInt(256);
    final int g = _random.nextInt(256);
    final int b = _random.nextInt(256);
    
    return Color.fromRGBO(r, g, b, 1.0);
  }

  /// Returns a random color as a hex string (e.g., #FF5733)
  String getRandomColorHex() {
    Color color = getRandomColor();
    
    // Convert to hex format
    String hex = '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
    
    return hex;
  }
  
  /// Sets the background color of the WebView to a random color
  Future<void> setRandomBackgroundColor(WebViewController controller) async {
    final String hexColor = getRandomColorHex();
    
    // Execute JavaScript to change the background color
    await controller.runJavaScript(
      'document.body.style.backgroundColor = "$hexColor";'
    );
  }
} 