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
        'getRandomColorHex should create string from getRandomColor result',
        () {
          // Arrange - Create a predictable color
          const controlColor = Color(0xFF123456);
          final mockColorService = TestColorService(controlColor);

          // Act
          final hexColor = mockColorService.getRandomColorHex();

          // Assert
          expect(hexColor, '#123456');
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
        mockController = MockWebViewPlatform.lastCreatedController as MockPlatformWebViewController;
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
            reason: 'JavaScript should update background color with a hex value',
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
}

/// Test implementation of ColorService that returns a predetermined hex color
class TestColorServiceWithHex extends ColorService {
  final String _hexColor;

  TestColorServiceWithHex(this._hexColor);

  @override
  String getRandomColorHex() => _hexColor;
}
