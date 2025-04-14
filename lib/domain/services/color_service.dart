import 'dart:developer' as developer;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Service responsible for generating random colors
class ColorService {
  // --- Constants ---
  static const double _minSaturation = 0.5; // Ensure colors are reasonably saturated
  static const double _maxSaturation = 1.0;
  static const double _minLightness = 0.5; // Ensure colors are bright enough
  static const double _maxLightness = 0.8; // Avoid overly pale colors
  static const double _alpha = 1.0; // Fully opaque
  static const int _hexRadix = 16;
  static const int _hexPadding = 2;
  // --- End Constants ---

  // Use a time-based seed for the random number generator
  final Random _random = Random(DateTime.now().millisecondsSinceEpoch);

  // Define a list of vibrant colors to use as fallback (kept as safety net)
  // Consider if this is still needed after HSL refactoring
  final List<String> _vibrantColors = [
    '#FF5733', // Vibrant Orange
    '#33FF57', // Vibrant Green
    '#3357FF', // Vibrant Blue
    '#FF33A8', // Vibrant Pink
    '#FFD700', // Gold
    '#33FFAA', // Medium Aquamarine
    '#AA33FF', // Vibrant Purple
    '#33AAFF', // Sky Blue
    '#FF8C00', // Dark Orange
    '#00CED1' // Dark Turquoise
  ];

  /// Returns a random Material color generated using HSL for better control
  /// over saturation and lightness.
  Color getRandomColor() {
    // Generate HSL components within desired ranges
    final double hue = _random.nextDouble() * 360; // Full hue range
    final double saturation = _random.nextDouble() * (_maxSaturation - _minSaturation) + _minSaturation;
    final double lightness = _random.nextDouble() * (_maxLightness - _minLightness) + _minLightness;

    // Create HSL color
    final HSLColor hslColor = HSLColor.fromAHSL(_alpha, hue, saturation, lightness);

    // Convert to RGB
    final Color rgbColor = hslColor.toColor();

    developer.log(
        'Generated HSL: H=${hue.toStringAsFixed(1)}, S=${saturation.toStringAsFixed(2)}, L=${lightness.toStringAsFixed(2)} -> RGB: ${rgbColor.toString()}');

    return rgbColor;
  }

  /// Converts a Color object to its hex string representation (e.g., #FF0000).
  /// Ensures components are clamped to 0-255 range.
  static String colorToHex(Color color) {
    final r = color.red.clamp(0, 255).toInt().toRadixString(_hexRadix).padLeft(_hexPadding, '0');
    final g = color.green.clamp(0, 255).toInt().toRadixString(_hexRadix).padLeft(_hexPadding, '0');
    final b = color.blue.clamp(0, 255).toInt().toRadixString(_hexRadix).padLeft(_hexPadding, '0');
    return '#$r$g$b'.toUpperCase();
  }

  /// Returns a random color as a hex string (e.g., #FF5733)
  /// Simplified after switching getRandomColor to use HSL.
  String getRandomColorHex() {
    final Color color = getRandomColor();
    String hex;

    try {
      // Convert to hex format using the static helper
      hex = ColorService.colorToHex(color);

      // Basic check: If somehow resulted in black (highly unlikely with HSL constraints), use fallback.
      if (hex == '#000000') {
        developer.log('Generated black color unexpectedly, using fallback.');
        hex = _vibrantColors[_random.nextInt(_vibrantColors.length)];
      }
    } catch (e) {
      // Log error during hex conversion and use fallback
      developer.log('Error converting color to hex: $e. Using fallback.');
      hex = _vibrantColors[_random.nextInt(_vibrantColors.length)];
    }

    developer.log('Generated hex color: $hex');
    return hex;
  }

  /// Sets the background color of the WebView to a random color
  Future<void> setRandomBackgroundColor(WebViewController controller) async {
    final String hexColor = getRandomColorHex();

    // Execute JavaScript to change the background color
    try {
      await controller.runJavaScript(
        'document.body.style.backgroundColor = "$hexColor";',
      );
      developer.log('Set WebView background color to: $hexColor');
    } catch (e) {
      developer.log('Error setting WebView background color: $e');
      // Handle or log the error appropriately
    }
  }
}
