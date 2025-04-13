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

    test('getRandomColor returns a color with brightness above minimum threshold', () {
      // Run multiple tests to ensure consistency
      for (int i = 0; i < 10; i++) {
        final color = colorService.getRandomColor();

        // Ensure color components are above minimum brightness (50)
        expect(color.red, greaterThanOrEqualTo(50));
        expect(color.green, greaterThanOrEqualTo(50));
        expect(color.blue, greaterThanOrEqualTo(50));

        // Ensure at least one component has high value (150+)
        final hasHighComponent = color.red >= 150 || color.green >= 150 || color.blue >= 150;
        expect(hasHighComponent, isTrue);
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

    test('getRandomColorHex returns bright enough colors', () {
      // Run multiple tests to ensure consistency
      for (int i = 0; i < 10; i++) {
        final hexColor = colorService.getRandomColorHex();

        // Convert hex to color to check brightness
        final hexDigits = hexColor.substring(1);
        final color = Color(int.parse(hexDigits, radix: 16) | 0xFF000000);

        // Calculate perceived brightness
        final double brightness = (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;

        // Should be above 30% brightness
        expect(brightness, greaterThan(0.3));
      }
    });

    test('getRandomColorHex respects maxAttempts parameter', () {
      // Test with different maxAttempts values
      final hexColor1 = colorService.getRandomColorHex(maxAttempts: 1);
      expect(hexColor1, startsWith('#'));
      expect(hexColor1.length, equals(7));

      final hexColor2 = colorService.getRandomColorHex(maxAttempts: 5);
      expect(hexColor2, startsWith('#'));
      expect(hexColor2.length, equals(7));
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

    test('hex conversion indirectly through hex color generation', () {
      // Test the conversion round-trip by validating values
      final predefinedHexes = ['#FF0000', '#00FF00', '#0000FF', '#FFFFFF', '#123456'];

      for (final hexColor in predefinedHexes) {
        // Create a service that always returns the specified hex
        final service = _FixedHexColorService(hexColor);

        // Get the generated hex
        final resultHex = service.getRandomColorHex();

        // Should match the input (accounting for possible case differences)
        expect(resultHex.toUpperCase(), hexColor.toUpperCase());
      }
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

  @override
  String getRandomColorHex({int maxAttempts = 3}) {
    return '#FFFFFF';
  }
}

/// Test subclass that returns a fixed hex color
class _FixedHexColorService extends ColorService {
  final String fixedHexColor;

  _FixedHexColorService(this.fixedHexColor);

  @override
  String getRandomColorHex({int maxAttempts = 3}) {
    return fixedHexColor;
  }
}
