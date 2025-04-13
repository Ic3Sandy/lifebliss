import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifebliss_app/presentation/pages/home_page.dart';
import 'package:lifebliss_app/presentation/pages/loading_page.dart';
import '../../utils/test_helpers.dart';

void main() {
  setUp(setupMockWebViewPlatform);

  group('LoadingPage', () {
    testWidgets('displays loading indicator and message', (WidgetTester tester) async {
      // Build the loading page
      await tester.pumpWidget(testableWidget(const LoadingPage()));

      // Verify loading indicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Verify loading text is shown
      expect(find.text('Loading...'), findsOneWidget);

      // Verify gradient background container exists
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('navigates to HomePage after delay when navigateAfterDelay is true', (WidgetTester tester) async {
      await assertTimedNavigation(
        tester: tester,
        originalWidget: const LoadingPage(),
        navigationDuration: LoadingPage.navigationDelay,
        originalWidgetFinder: find.byType(LoadingPage),
        targetWidgetFinder: find.byType(HomePage),
      );
    });

    testWidgets('does not navigate to HomePage when navigateAfterDelay is false', (WidgetTester tester) async {
      // Build the loading page with navigation disabled
      await tester.pumpWidget(testableWidget(const LoadingPage(navigateAfterDelay: false)));

      // Verify loading page is shown
      expect(find.byType(LoadingPage), findsOneWidget);

      // Wait for longer than the normal navigation delay
      await tester.pump(LoadingPage.navigationDelay + const Duration(seconds: 1));

      // Verify loading page is still shown (no navigation occurred)
      expect(find.byType(LoadingPage), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);
    });

    testWidgets('cancels timer when disposed', (WidgetTester tester) async {
      // This test verifies the timer is canceled properly by forcing disposal
      // before the timer completes

      // Build the loading page with a simpler widget tree that allows disposal
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return const LoadingPage();
            },
          ),
        ),
      );

      // Verify loading page is shown
      expect(find.byType(LoadingPage), findsOneWidget);

      // Wait a bit, but less than the navigation delay
      await tester.pump(const Duration(seconds: 1));

      // Replace with a different widget to force disposal
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Text('Disposed')),
        ),
      );

      // Pump to complete animations
      await tester.pumpAndSettle();

      // Wait until after the navigation delay would have completed
      await tester.pump(LoadingPage.navigationDelay);

      // Verify the new widget is shown and no errors occurred
      expect(find.text('Disposed'), findsOneWidget);
    });
  });
}
