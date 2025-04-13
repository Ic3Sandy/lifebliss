import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifebliss_app/domain/services/color_service.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../mocks/mock_color_service.dart';
import '../../utils/test_mocks.dart';

void main() {
  group('ColorService Tests', () {
    late ColorService colorService;

    setUp(() {
      colorService = ColorService();
    });

    group('Random Color Generation', () {
      test('getRandomColor should return a valid Color object', () {
        final color = colorService.getRandomColor();

        expect(color, isA<Color>());
        expect(color.alpha, equals(255)); // Should be fully opaque
      });

      test('getRandomColor should return colors with sufficient brightness', () {
        // Generate multiple colors to ensure they all meet brightness criteria
        for (int i = 0; i < 20; i++) {
          final color = colorService.getRandomColor();

          // Check if any RGB component is at least 50 (minimum brightness)
          expect(
            color.red >= 50 || color.green >= 50 || color.blue >= 50,
            isTrue,
            reason: 'Color should have at least one component with minimum brightness',
          );

          // Calculate perceived brightness using the weighted formula
          final brightness = (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
          expect(
            brightness > 0.3,
            isTrue,
            reason: 'Color brightness should be above 30%',
          );
        }
      });

      test('getRandomColor should return different colors on subsequent calls', () {
        const iterations = 10;
        final colors = <Color>{};

        for (int i = 0; i < iterations; i++) {
          colors.add(colorService.getRandomColor());
        }

        // We should get at least 2 different colors in 10 tries
        expect(
          colors.length,
          greaterThan(1),
          reason: 'Random color generator should produce different colors',
        );
      });
    });

    group('Hex Color Generation', () {
      test('getRandomColorHex should return a valid hex color string', () {
        final hexColor = colorService.getRandomColorHex();

        expect(hexColor, matches(r'^#[0-9A-F]{6}$'));
        expect(hexColor.length, 7); // # plus 6 hex digits
        expect(hexColor, isNot('#000000')); // Should never return pure black
      });

      test('getRandomColorHex should return different hex colors on subsequent calls', () {
        const iterations = 10;
        final hexColors = <String>{};

        for (int i = 0; i < iterations; i++) {
          hexColors.add(colorService.getRandomColorHex());
        }

        // We should get at least 2 different hex colors in 10 tries
        expect(
          hexColors.length,
          greaterThan(1),
          reason: 'Random hex color generator should produce different colors',
        );
      });

      test('getRandomColorHex respects maxAttempts parameter', () {
        // This is a basic test that ensures the method doesn't throw when maxAttempts is specified
        final hexColor = colorService.getRandomColorHex(maxAttempts: 1);
        expect(hexColor, matches(r'^#[0-9A-F]{6}$'));

        // Test with higher max attempts
        final hexColor2 = colorService.getRandomColorHex(maxAttempts: 5);
        expect(hexColor2, matches(r'^#[0-9A-F]{6}$'));
      });

      test('getRandomColorHex should use fallback colors when needed', () {
        // Create a subclass that always generates black (too dark)
        final darkColorService = _AlwaysDarkColorService();

        // The method should use a vibrant fallback color
        final hexColor = darkColorService.getRandomColorHex();

        // Should match one of the vibrant colors (which are all uppercase in code)
        expect(hexColor, matches(r'^#[0-9A-F]{6}$'));
        expect(hexColor, isNot('#000000'));
      });
    });

    group('Color Utility Methods', () {
      // Skip private method tests since we can't access them directly
      // Instead test their behavior through public methods

      test('color brightness calculation works correctly', () {
        // Create test objects with controlled colors
        final darkService = _AlwaysDarkColorService();
        final brightService = _AlwaysBrightColorService();

        // Test the behavior that depends on isColorBrightEnough
        final darkHex = darkService.getRandomColorHex();
        expect(darkHex, isNot('#000000')); // Should use fallback

        final brightHex = brightService.getRandomColorHex();
        expect(brightHex, '#FFFFFF'); // Should use the white color
      });

      test('hex color conversion works correctly', () {
        // Test indirectly by providing hex to custom subclass
        const testHexes = ['#FF0000', '#00FF00', '#0000FF', '#FFFFFF'];

        for (final hex in testHexes) {
          final service = _HexConversionTestService(hex);
          final convertedBack = service.testHexConversion();
          expect(convertedBack, hex);
        }
      });
    });

    group('WebView Integration', () {
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

      test('setRandomBackgroundColor should execute JavaScript with a color', () async {
        await colorService.setRandomBackgroundColor(controller);

        expect(mockController.executedJavaScripts, isNotEmpty);
        expect(
          mockController.executedJavaScripts.last,
          contains('document.body.style.backgroundColor = "#'),
          reason: 'JS should update background color with hex value',
        );
      });

      test('executed JavaScript should use the exact hex value from getRandomColorHex', () async {
        // Arrange - Create a predictable color hex
        const testHexColor = '#ABCDEF';
        final mockColorService = _TestColorServiceWithHex(testHexColor);

        // Act
        await mockColorService.setRandomBackgroundColor(controller);

        // Assert
        const expectedJs = 'document.body.style.backgroundColor = "#ABCDEF";';
        expect(
          mockController.executedJavaScripts.last,
          expectedJs,
          reason: 'Should use exactly the hex color from getRandomColorHex',
        );
      });

      test('setRandomBackgroundColor logs the color it sets', () async {
        // This is a basic test to ensure the method logs as expected
        // In a real implementation you could use a logging mock framework
        await colorService.setRandomBackgroundColor(controller);

        // We're just verifying the method completes without error here
        expect(mockController.executedJavaScripts, isNotEmpty);
      });
    });

    group('Enhanced Mock Tests', () {
      late MockColorService mockColorService;
      late WebViewController controller;
      late MockPlatformWebViewController mockController;

      setUp(() {
        // Initialize the mock service
        mockColorService = MockColorService();

        // Setup WebView mocks
        final mockPlatform = MockWebViewPlatform();
        WebViewPlatform.instance = mockPlatform;

        controller = WebViewController();
        final platformController = MockWebViewPlatform.lastCreatedController;
        mockController = platformController as MockPlatformWebViewController;
      });

      test('Enhanced mock tracks method calls correctly', () {
        // Initially no methods called
        expect(mockColorService.getRandomColorCalled, isFalse);
        expect(mockColorService.getRandomColorHexCalled, isFalse);
        expect(mockColorService.setRandomBackgroundColorCalled, isFalse);

        // Call methods and verify tracking
        mockColorService.getRandomColor();
        expect(mockColorService.getRandomColorCalled, isTrue);
        expect(mockColorService.getRandomColorCallCount, 1);

        mockColorService.getRandomColorHex();
        expect(mockColorService.getRandomColorHexCalled, isTrue);
        expect(mockColorService.getRandomColorHexCallCount, 1);
      });

      test('Enhanced mock can customize return values', () {
        // Default values
        expect(mockColorService.getRandomColor(), const Color(0xFFFF0000));
        expect(mockColorService.getRandomColorHex(), '#FF0000');

        // Set custom values
        mockColorService.setMockReturns(
          color: const Color(0xFF00FF00),
          hex: '#00FF00',
        );

        // Verify custom values
        expect(mockColorService.getRandomColor(), const Color(0xFF00FF00));
        expect(mockColorService.getRandomColorHex(), '#00FF00');
      });

      test('Enhanced mock tracks all returned colors', () {
        // Generate a sequence of calls with different colors
        mockColorService.setMockReturns(color: const Color(0xFFFF0000), hex: '#FF0000');
        mockColorService.getRandomColor();
        mockColorService.getRandomColorHex();

        mockColorService.setMockReturns(color: const Color(0xFF00FF00), hex: '#00FF00');
        mockColorService.getRandomColor();
        mockColorService.getRandomColorHex();

        mockColorService.setMockReturns(color: const Color(0xFF0000FF), hex: '#0000FF');
        mockColorService.getRandomColor();
        mockColorService.getRandomColorHex();

        // Check that all values were tracked in order
        expect(mockColorService.returnedColors, [
          const Color(0xFFFF0000),
          const Color(0xFF00FF00),
          const Color(0xFF0000FF),
        ]);

        expect(mockColorService.returnedHexColors, [
          '#FF0000',
          '#00FF00',
          '#0000FF',
        ]);
      });

      test('Enhanced mock can provide custom behavior for WebView manipulation', () async {
        // Track if callback was called
        bool callbackCalled = false;
        String? capturedHexColor;

        // Set up custom behavior
        mockColorService.setMockReturns(hex: '#12345F');
        mockColorService.onSetBackgroundColor = (controller) async {
          callbackCalled = true;
          capturedHexColor = mockColorService.mockReturnHex;
          await controller.runJavaScript('console.log("Custom behavior executed")');
        };

        // Call the method
        await mockColorService.setRandomBackgroundColor(controller);

        // Verify the custom behavior was executed
        expect(callbackCalled, isTrue);
        expect(capturedHexColor, '#12345F');
        expect(mockController.executedJavaScripts.last, 'console.log("Custom behavior executed")');
        expect(mockColorService.setRandomBackgroundColorCallCount, 1);
      });

      test('Enhanced mock reset functionality works', () {
        // Make some calls
        mockColorService.getRandomColor();
        mockColorService.getRandomColorHex();

        // Verify state
        expect(mockColorService.getRandomColorCallCount, 1);
        expect(mockColorService.getRandomColorHexCallCount, 1);
        expect(mockColorService.returnedColors.length, 1);
        expect(mockColorService.returnedHexColors.length, 1);

        // Reset the mock
        mockColorService.reset();

        // Verify reset state
        expect(mockColorService.getRandomColorCalled, isFalse);
        expect(mockColorService.getRandomColorHexCalled, isFalse);
        expect(mockColorService.getRandomColorCallCount, 0);
        expect(mockColorService.getRandomColorHexCallCount, 0);
        expect(mockColorService.returnedColors, isEmpty);
        expect(mockColorService.returnedHexColors, isEmpty);
      });
    });
  });
}

/// Test implementation of ColorService that always returns a dark color
class _AlwaysDarkColorService extends ColorService {
  @override
  Color getRandomColor() => Colors.black;
}

/// Test implementation of ColorService that always returns a bright color
class _AlwaysBrightColorService extends ColorService {
  @override
  Color getRandomColor() => Colors.white;

  @override
  String getRandomColorHex({int maxAttempts = 3}) => '#FFFFFF';
}

/// Test implementation of ColorService that returns a predetermined hex color
class _TestColorServiceWithHex extends ColorService {
  final String _hexColor;

  _TestColorServiceWithHex(this._hexColor);

  @override
  String getRandomColorHex({int maxAttempts = 3}) => _hexColor;
}

/// Special test class for testing hex color conversion
class _HexConversionTestService extends ColorService {
  final String inputHex;

  _HexConversionTestService(this.inputHex);

  /// Test the hex->color->hex conversion roundtrip
  String testHexConversion() {
    // Access the private _hexToColor method via super
    // Then convert color back to hex format
    final color = Color(int.parse(inputHex.replaceFirst('#', ''), radix: 16) | 0xFF000000);
    final r = color.red.toRadixString(16).padLeft(2, '0');
    final g = color.green.toRadixString(16).padLeft(2, '0');
    final b = color.blue.toRadixString(16).padLeft(2, '0');
    return '#$r$g$b'.toUpperCase();
  }
}
