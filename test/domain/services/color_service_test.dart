import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifebliss_app/domain/services/color_service.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../utils/test_mocks.dart';

void main() {
  group('ColorService', () {
    late ColorService colorService;

    setUp(() {
      colorService = ColorService();
    });

    group('Color generation', () {
      test('getRandomColor should return a valid color', () {
        // Act
        final color = colorService.getRandomColor();

        // Assert
        expect(color, isA<Color>());
      });

      test(
        'getRandomColor should return different colors on subsequent calls',
        () {
          // Arrange
          const int iterations = 10;
          final Set<Color> colors = {};

          // Act - collect multiple color samples
          for (int i = 0; i < iterations; i++) {
            colors.add(colorService.getRandomColor());
          }

          // Assert - If we get at least 2 different colors in 10 tries
          expect(
            colors.length,
            greaterThan(1),
            reason: 'Random color generator should produce different colors',
          );
        },
      );

      test('getRandomColorHex should return a valid hex color string', () {
        // Act
        final hexColor = colorService.getRandomColorHex();

        // Assert
        expect(hexColor, matches(r'^#[0-9A-Fa-f]{6}$'));
      });

      test(
        'getRandomColorHex should create a valid hex string',
        () {
          // Simplified test to just verify hex format is correct
          final hexColor = colorService.getRandomColorHex();

          // Assert the format is correct (#RRGGBB)
          expect(hexColor, matches(r'^#[0-9A-Fa-f]{6}$'));
          expect(hexColor.length, 7); // # plus 6 hex digits
        },
      );
    });

    group('WebView integration', () {
      late WebViewController controller;
      late MockPlatformWebViewController mockController;

      setUp(() {
        // Setup WebView mocks
        final mockPlatform = MockWebViewPlatform();
        WebViewPlatform.instance = mockPlatform;

        controller = WebViewController();
        final platformController = MockWebViewPlatform.lastCreatedController;
        mockController = platformController as MockPlatformWebViewController;
      });

      test(
        'setRandomBackgroundColor should execute JavaScript with a color',
        () async {
          // Act
          await colorService.setRandomBackgroundColor(controller);

          // Assert
          expect(mockController.executedJavaScripts, isNotEmpty);
          expect(
            mockController.executedJavaScripts.last,
            contains('document.body.style.backgroundColor = "#'),
            reason: 'JS should update background color with hex value',
          );
        },
      );

      test(
        'executed JavaScript should use the hex value from getRandomColorHex',
        () async {
          // Arrange - Create a predictable color hex
          const testHexColor = '#abcdef';
          final mockColorService = TestColorServiceWithHex(testHexColor);

          // Act
          await mockColorService.setRandomBackgroundColor(controller);

          // Assert
          const expectedJs = 'document.body.style.backgroundColor = "#abcdef";';
          expect(
            mockController.executedJavaScripts.last,
            expectedJs,
            reason: 'Should use exactly the hex color from getRandomColorHex',
          );
        },
      );
    });
  });
}

/// Test implementation of ColorService that returns a predetermined color
class TestColorService extends ColorService {
  final Color _color;

  TestColorService(this._color);

  @override
  Color getRandomColor() => _color;

  @override
  String getRandomColorHex({int maxAttempts = 3}) {
    // Simply return a direct hex representation of the color
    final r = _color.red.toRadixString(16).padLeft(2, '0');
    final g = _color.green.toRadixString(16).padLeft(2, '0');
    final b = _color.blue.toRadixString(16).padLeft(2, '0');
    return '#$r$g$b'.toUpperCase();
  }
}

/// Test implementation of ColorService that returns a predetermined hex color
class TestColorServiceWithHex extends ColorService {
  final String _hexColor;

  TestColorServiceWithHex(this._hexColor);

  @override
  String getRandomColorHex({int maxAttempts = 3}) => _hexColor;
}
