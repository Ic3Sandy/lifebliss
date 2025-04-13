import 'package:flutter/material.dart';
import 'package:lifebliss_app/domain/services/color_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Mock implementation of ColorService for testing
class MockColorService extends ColorService {
  // Tracking properties
  bool getRandomColorCalled = false;
  bool getRandomColorHexCalled = false;
  bool setRandomBackgroundColorCalled = false;

  int getRandomColorCallCount = 0;
  int getRandomColorHexCallCount = 0;
  int setRandomBackgroundColorCallCount = 0;

  // Mock return values
  Color mockReturnColor = const Color(0xFFFF0000); // Red by default
  String mockReturnHex = '#FF0000'; // Red by default

  // List to track all colors returned for sequence testing
  final List<Color> returnedColors = [];
  final List<String> returnedHexColors = [];

  // Optional callback to execute when setRandomBackgroundColor is called
  Function(WebViewController)? onSetBackgroundColor;

  @override
  Color getRandomColor() {
    getRandomColorCalled = true;
    getRandomColorCallCount++;
    returnedColors.add(mockReturnColor);
    return mockReturnColor;
  }

  @override
  String getRandomColorHex({int maxAttempts = 3}) {
    getRandomColorHexCalled = true;
    getRandomColorHexCallCount++;
    returnedHexColors.add(mockReturnHex);
    return mockReturnHex;
  }

  @override
  Future<void> setRandomBackgroundColor(WebViewController controller) async {
    setRandomBackgroundColorCalled = true;
    setRandomBackgroundColorCallCount++;

    if (onSetBackgroundColor != null) {
      await onSetBackgroundColor!(controller);
    } else {
      await super.setRandomBackgroundColor(controller);
    }
  }

  /// Reset all tracking properties
  void reset() {
    getRandomColorCalled = false;
    getRandomColorHexCalled = false;
    setRandomBackgroundColorCalled = false;

    getRandomColorCallCount = 0;
    getRandomColorHexCallCount = 0;
    setRandomBackgroundColorCallCount = 0;

    returnedColors.clear();
    returnedHexColors.clear();
  }

  /// Set mock return values
  void setMockReturns({Color? color, String? hex}) {
    if (color != null) {
      mockReturnColor = color;
    }
    if (hex != null) {
      mockReturnHex = hex;
    }
  }
}
