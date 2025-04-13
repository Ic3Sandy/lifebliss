import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifebliss_app/domain/services/color_service.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import '../../utils/test_mocks.dart';

void main() {
  group('ColorService', () {
    late ColorService colorService;
    
    setUp(() {
      colorService = ColorService();
    });
    
    test('getRandomColor should return a valid color', () {
      // Act
      final color = colorService.getRandomColor();
      
      // Assert
      expect(color, isA<Color>());
    });
    
    test('getRandomColor should return different colors on subsequent calls', () {
      // Arrange
      const int iterations = 10;
      final Set<Color> colors = {};
      
      // Act
      for (int i = 0; i < iterations; i++) {
        colors.add(colorService.getRandomColor());
      }
      
      // Assert - If we get at least 2 different colors in 10 tries, it's random enough
      expect(colors.length, greaterThan(1));
    });
    
    test('getRandomColorHex should return a valid hex color string', () {
      // Act
      final hexColor = colorService.getRandomColorHex();
      
      // Assert
      expect(hexColor, matches(r'^#[0-9A-Fa-f]{6}$'));
    });
    
    test('setRandomBackgroundColor should execute JavaScript with a color', () async {
      // Arrange
      final mockPlatform = MockWebViewPlatform();
      WebViewPlatform.instance = mockPlatform;
      
      final controller = WebViewController();
      final mockController = MockWebViewPlatform.lastCreatedController as MockPlatformWebViewController;
      
      // Act
      await colorService.setRandomBackgroundColor(controller);
      
      // Assert
      expect(mockController.executedJavaScripts, isNotEmpty);
      expect(
        mockController.executedJavaScripts.last,
        contains('document.body.style.backgroundColor = "#')
      );
    });
  });
} 