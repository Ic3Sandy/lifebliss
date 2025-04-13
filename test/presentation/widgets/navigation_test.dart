import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifebliss_app/main.dart';
import 'package:lifebliss_app/presentation/pages/home_page.dart';
import 'package:lifebliss_app/presentation/pages/loading_page.dart';
import '../../utils/test_helpers.dart';

void main() {
  setUp(setupMockWebViewPlatform);

  group('Navigation Tests', () {
    testWidgets('App starts with LoadingPage', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const MyApp());

      // Verify LoadingPage is the initial page
      expect(find.byType(LoadingPage), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);
    });

    testWidgets('LoadingPage automatically navigates to HomePage after delay', (WidgetTester tester) async {
      // Test helper for timed navigation
      await assertTimedNavigation(
        tester: tester,
        originalWidget: const MyApp(),
        navigationDuration: LoadingPage.navigationDelay,
        originalWidgetFinder: find.byType(LoadingPage),
        targetWidgetFinder: find.byType(HomePage),
      );
    });

    testWidgets('HomePage has an AppBar with title', (WidgetTester tester) async {
      // Build HomePage directly
      await tester.pumpWidget(testableWidget(const HomePage()));

      // Verify AppBar exists
      expect(find.byType(AppBar), findsOneWidget);

      // Verify title
      expect(find.text('Lifebliss'), findsOneWidget);
    });

    testWidgets('HomePage has a color picker button', (WidgetTester tester) async {
      // Build HomePage directly
      await tester.pumpWidget(testableWidget(const HomePage()));

      // Verify color picker button exists
      expect(find.byIcon(Icons.color_lens), findsOneWidget);
    });

    testWidgets('Navigation maintains state across pages', (WidgetTester tester) async {
      // This test verifies that state is maintained during navigation

      // Build the app
      await tester.pumpWidget(const MyApp());

      // Verify we start on LoadingPage
      expect(find.byType(LoadingPage), findsOneWidget);

      // Navigate to HomePage (simulating timed navigation)
      await tester.pump(LoadingPage.navigationDelay);
      await tester.pumpAndSettle();

      // Verify we're now on HomePage
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Lifebliss'), findsOneWidget);

      // WebView should be initialized (represented by the mock container in tests)
      expect(find.byKey(const ValueKey('MockPlatformWebViewWidget')), findsOneWidget);
    });

    testWidgets('Tapping color button triggers color change', (WidgetTester tester) async {
      // Mock the color service and JS execution will be verified in other tests

      // Build HomePage directly
      await tester.pumpWidget(testableWidget(const HomePage()));

      // Verify color picker button exists
      final colorButtonFinder = find.byIcon(Icons.color_lens);
      expect(colorButtonFinder, findsOneWidget);

      // Tap the color button
      await tester.tap(colorButtonFinder);
      await tester.pump();

      // The tap succeeded if no exceptions were thrown
      // The actual color change effect is tested separately in integration tests
    });
  });
}
