import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifebliss_app/domain/services/color_service.dart';
import 'package:lifebliss_app/presentation/pages/home_page.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../utils/test_helpers.dart';
import '../../utils/test_mocks.dart';

void main() {
  setUp(() {
    setupMockWebViewPlatform();
  });

  group('HomePage', () {
    testWidgets('should display a WebViewWidget', (WidgetTester tester) async {
      // Build the HomePage widget
      await tester.pumpWidget(testableWidget(const HomePage()));

      // Verify that a WebViewWidget is displayed
      expect(find.byType(WebViewWidget), findsOneWidget);
      expect(find.byKey(const ValueKey('MockPlatformWebViewWidget')), findsOneWidget);
    });
    
    testWidgets('should have AppBar with blue background', (WidgetTester tester) async {
      // Build the HomePage widget
      await tester.pumpWidget(testableWidget(const HomePage()));
      
      // Verify AppBar exists
      expect(find.byType(AppBar), findsOneWidget);
      
      // Verify AppBar background color is blue
      final AppBar appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, Colors.blue);
    });
    
    test('ColorService should be called when requested', () {
      // Create a mock color service that returns a predictable color
      final mockColorService = MockColorService();
      
      // Call the test method
      HomePage.testColorService(mockColorService);
      
      // Verify color service was called
      expect(mockColorService.getRandomColorHexCalled, isTrue);
    });
  });
}

// Mock class for ColorService
class MockColorService extends ColorService {
  bool getRandomColorHexCalled = false;
  
  @override
  String getRandomColorHex() {
    getRandomColorHexCalled = true;
    return '#FF0000'; // Always return red for testing
  }
}
