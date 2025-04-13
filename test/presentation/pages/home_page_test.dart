import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifebliss_app/presentation/pages/home_page.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../mocks/mock_color_service.dart';
import '../../utils/test_helpers.dart';

void main() {
  setUp(setupMockWebViewPlatform);

  group('HomePage', () {
    group('UI tests', () {
      testWidgets('should display a WebViewWidget', (WidgetTester tester) async {
        // Arrange & Act - Build the HomePage widget
        await tester.pumpWidget(testableWidget(const HomePage()));

        // Assert - Verify WebView is displayed
        expect(find.byType(WebViewWidget), findsOneWidget);
        expect(
          find.byKey(const ValueKey('MockPlatformWebViewWidget')),
          findsOneWidget,
        );
      });

      testWidgets('should have AppBar with blue background', (WidgetTester tester) async {
        // Arrange & Act - Build the HomePage widget
        await tester.pumpWidget(testableWidget(const HomePage()));

        // Assert - Verify AppBar with correct color
        expect(find.byType(AppBar), findsOneWidget);
        final AppBar appBar = tester.widget<AppBar>(find.byType(AppBar));
        expect(appBar.backgroundColor, Colors.blue);
      });
    });

    group('Logic tests', () {
      test('ColorService should be called when requested', () {
        // Arrange - Create mock color service
        final mockColorService = MockColorService();

        // Act - Call the test method
        HomePage.testColorService(mockColorService);

        // Assert - Verify service was called
        expect(mockColorService.getRandomColorHexCalled, isTrue);
      });
    });
  });
}
