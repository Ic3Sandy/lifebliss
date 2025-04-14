import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifebliss_app/domain/services/color_service.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../mocks/mock_color_service.dart';
import '../../utils/test_mocks.dart';

void main() {
  group('ColorService', () {
    late ColorService colorService;

    setUp(() {
      colorService = ColorService();
    });

    test('getRandomColor returns a non-null Color', () {
      final color = colorService.getRandomColor();
      expect(color, isNotNull);
      expect(color, isA<Color>());
    });

    test('getRandomColor returns a color with appropriate HSL lightness', () {
      // Run multiple tests to ensure consistency
      for (int i = 0; i < 10; i++) {
        final color = colorService.getRandomColor();

        // Convert the generated RGB color back to HSL to check its lightness
        final hslColor = HSLColor.fromColor(color);

        // Check if lightness is within the range defined in ColorService
        expect(hslColor.lightness, greaterThanOrEqualTo(0.5), reason: 'Lightness should be >= 0.5');
        expect(hslColor.lightness, lessThanOrEqualTo(0.8), reason: 'Lightness should be <= 0.8');

        // Also check saturation for reasonable vibrancy (using the constant from ColorService if possible, otherwise a known good value)
        // Note: Accessing private constants like _minSaturation isn't directly possible in tests.
        // We'll use the known value 0.5, but allow for slight floating point inaccuracies from HSL -> RGB -> HSL conversion.
        // Use closeTo matcher for floating point comparison
        expect(hslColor.saturation, closeTo(0.75, 0.25),
            reason:
                'Saturation should be roughly between 0.5 and 1.0'); // Target 0.75 with delta 0.25 covers 0.5 to 1.0

        // The old RGB component checks are removed as they are no longer relevant
        // to the HSL generation logic.
      }
    });

    test('getRandomColorHex returns a valid hex color string', () {
      final hexColor = colorService.getRandomColorHex();

      // Verify hex format
      expect(hexColor, startsWith('#'));
      expect(hexColor.length, equals(7));

      // Verify it's uppercase
      expect(hexColor, equals(hexColor.toUpperCase()));

      // Verify it's a valid hex color
      expect(int.tryParse(hexColor.substring(1), radix: 16), isNotNull);
    });

    test('getRandomColorHex never returns black', () {
      // Run multiple tests to ensure consistency
      for (int i = 0; i < 10; i++) {
        final hexColor = colorService.getRandomColorHex();
        expect(hexColor.toLowerCase(), isNot('#000000'));
      }
    });

    test('color brightness calculation indirectly through getRandomColorHex', () {
      // Create a subclass that tests internal brightness functionality
      final darkColorService = _AlwaysDarkColorService();
      final brightColorService = _AlwaysBrightColorService();

      // Dark colors should trigger fallback to vibrant colors
      final darkHex = darkColorService.getRandomColorHex();
      expect(darkHex.toLowerCase(), isNot('#000000')); // Should use fallback

      // Bright colors should pass brightness check
      final brightHex = brightColorService.getRandomColorHex();
      expect(brightHex.toUpperCase(), '#FFFFFF'); // Should keep the white color
    });

    test('colorToHex converts Color object to correct hex string', () {
      // Test cases: Map of Color objects to expected hex strings
      final testCases = {
        const Color.fromRGBO(255, 0, 0, 1.0): '#FF0000',
        const Color.fromRGBO(0, 255, 0, 1.0): '#00FF00',
        const Color.fromRGBO(0, 0, 255, 1.0): '#0000FF',
        const Color.fromRGBO(255, 255, 255, 1.0): '#FFFFFF',
        const Color.fromRGBO(0, 0, 0, 1.0): '#000000',
        const Color.fromRGBO(18, 52, 86, 1.0): '#123456', // Hex 12, 34, 56
        const Color.fromRGBO(123, 12, 231, 1.0): '#7B0CE7'
      };

      testCases.forEach((color, expectedHex) {
        final resultHex = ColorService.colorToHex(color);
        expect(resultHex, equals(expectedHex), reason: 'Failed for Color: $color');
      });
    });

    test('setRandomBackgroundColor calls JavaScript to set background color', () async {
      // Set up mock WebView controller from test_mocks.dart
      setupMockWebViewPlatform();

      // Create a WebViewController to test with
      final webViewController = WebViewController.fromPlatformCreationParams(
        const PlatformWebViewControllerCreationParams(),
      );

      // Execute the method
      await colorService.setRandomBackgroundColor(webViewController);

      // Use the static class property directly to access the last created controller
      final mockController = MockWebViewPlatform.lastCreatedController as MockPlatformWebViewController;

      // Verify JavaScript execution
      expect(mockController.executedJavaScripts.isNotEmpty, isTrue);

      // Verify correct JavaScript was executed
      bool hasBackgroundColorJs = false;
      for (final js in mockController.executedJavaScripts) {
        if (js.contains('backgroundColor') && js.contains('#')) {
          hasBackgroundColorJs = true;
          break;
        }
      }
      expect(hasBackgroundColorJs, isTrue);
    });
  });
}

/// Test subclass that always returns black (too dark)
class _AlwaysDarkColorService extends ColorService {
  @override
  Color getRandomColor() {
    return Colors.black;
  }
}

/// Test subclass that always returns white (bright enough)
class _AlwaysBrightColorService extends ColorService {
  @override
  Color getRandomColor() {
    return Colors.white;
  }
}
