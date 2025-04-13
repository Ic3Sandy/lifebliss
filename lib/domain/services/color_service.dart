import 'dart:developer' as developer;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Service responsible for generating random colors
class ColorService {
  // Use a time-based seed for the random number generator
  final Random _random = Random(DateTime.now().millisecondsSinceEpoch);

  // Define a list of vibrant colors to use as fallback
  final List<String> _vibrantColors = [
    '#FF5733',
    '#33FF57',
    '#3357FF',
    '#F033FF',
    '#FF33F0',
    '#FFAA33',
    '#33FFAA',
    '#AA33FF',
    '#33AAFF',
    '#FF33AA'
  ];

  /// Returns a random Material color
  Color getRandomColor() {
    // Get random values for RGB - ensure they're not too dark
    // Minimum threshold to avoid very dark/black colors - increased from 30 to 50
    const int minBrightness = 50;
    const int maxValue = 255;

    // Generate random values with minimum brightness
    int r = _random.nextInt(maxValue - minBrightness) + minBrightness;
    int g = _random.nextInt(maxValue - minBrightness) + minBrightness;
    int b = _random.nextInt(maxValue - minBrightness) + minBrightness;

    // Ensure at least one component has a high value for more vibrant colors
    final int maxComponent = [r, g, b].reduce((a, b) => a > b ? a : b);
    if (maxComponent < 150) {
      // Boost the brightest component even more
      final int index = [r, g, b].indexOf(maxComponent);
      if (index == 0) {
        r = _random.nextInt(105) + 150; // 150-255
      }
      if (index == 1) {
        g = _random.nextInt(105) + 150;
      }
      if (index == 2) {
        b = _random.nextInt(105) + 150;
      }
    }

    developer.log('Generated RGB values: r=$r, g=$g, b=$b');

    return Color.fromRGBO(r, g, b, 1.0);
  }

  /// Returns a random color as a hex string (e.g., #FF5733)
  String getRandomColorHex({int maxAttempts = 3}) {
    // Keep track of attempts to prevent infinite loops
    int attempts = 0;
    String hex = '';

    while (attempts < maxAttempts) {
      final Color color = getRandomColor();

      // Convert to hex format using r, g, b values
      final r = color.r.toInt().toRadixString(16).padLeft(2, '0');
      final g = color.g.toInt().toRadixString(16).padLeft(2, '0');
      final b = color.b.toInt().toRadixString(16).padLeft(2, '0');
      hex = '#$r$g$b';

      hex = hex.toUpperCase();

      // Check if the color is too dark
      if (hex.toLowerCase() != '#000000' && _isColorBrightEnough(color)) {
        break;
      }

      attempts++;
    }

    // If we couldn't generate a good color after max attempts, use a vibrant fallback
    if (hex.toLowerCase() == '#000000' || !_isColorBrightEnough(_hexToColor(hex))) {
      hex = _vibrantColors[_random.nextInt(_vibrantColors.length)];
    }

    developer.log('Generated hex color: $hex');
    return hex;
  }

  /// Checks if a color is bright enough (not too dark)
  bool _isColorBrightEnough(Color color) {
    // Calculate perceived brightness using the formula
    // (0.299*R + 0.587*G + 0.114*B)
    final r = 0.299 * color.r;
    final g = 0.587 * color.g;
    final b = 0.114 * color.b;
    final double brightness = (r + g + b) / 255;

    // Consider bright enough if above 0.3 (30% brightness)
    return brightness > 0.3;
  }

  /// Sets the background color of the WebView to a random color
  Future<void> setRandomBackgroundColor(WebViewController controller) async {
    final String hexColor = getRandomColorHex();

    // Execute JavaScript to change the background color
    await controller.runJavaScript(
      'document.body.style.backgroundColor = "$hexColor";',
    );

    developer.log('Set WebView background color to: $hexColor');
  }

  /// Convert a hex color string to a Color object
  Color _hexToColor(String hexString) {
    final hexColor = hexString.replaceFirst('#', '');
    return Color(int.parse(hexColor, radix: 16) | 0xFF000000);
  }
}
