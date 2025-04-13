import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifebliss_app/presentation/pages/home_page.dart';
import 'package:lifebliss_app/presentation/pages/loading_page.dart';
import '../../utils/test_helpers.dart';

void main() {
  setUp(setupMockWebViewPlatform);

  group('LoadingPage', () {
    group('UI tests', () {
      testWidgets('should display correct UI elements', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(testableWidget(const LoadingPage(navigateAfterDelay: false)));

        // Assert - Basic UI elements
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Loading...'), findsOneWidget);

        // Assert - Styling and layout
        final container = tester.widget<Container>(find.byType(Container).first);
        final decoration = container.decoration as BoxDecoration;
        final gradient = decoration.gradient as LinearGradient;

        expect(gradient.colors.length, 2);
        expect(gradient.colors[0], Colors.blue);
        expect(gradient.colors[1], Colors.lightBlueAccent);
      });
    });

    group('Navigation tests', () {
      testWidgets('should navigate to HomePage after delay', (WidgetTester tester) async {
        // Use test helper for timed navigation testing
        await assertTimedNavigation(
          tester: tester,
          originalWidget: const LoadingPage(),
          navigationDuration: LoadingPage.navigationDelay,
          originalWidgetFinder: find.byType(LoadingPage),
          targetWidgetFinder: find.byType(HomePage),
        );
      });

      testWidgets('should not navigate when navigateAfterDelay is false', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(testableWidget(const LoadingPage(navigateAfterDelay: false)));

        // Act - Wait longer than the normal navigation delay
        await tester.pump(LoadingPage.navigationDelay + const Duration(milliseconds: 100));
        await tester.pump(); // Process any pending frames

        // Assert - Still on LoadingPage
        expect(find.byType(LoadingPage), findsOneWidget);
        expect(find.byType(HomePage), findsNothing);
      });
    });

    group('Edge case tests', () {
      testWidgets('should handle widget disposal during timer', (WidgetTester tester) async {
        // Arrange - Show LoadingPage
        await tester.pumpWidget(
          MaterialApp(
            home: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return const LoadingPage();
              },
            ),
          ),
        );

        // Assert - LoadingPage is shown
        expect(find.byType(LoadingPage), findsOneWidget);

        // Act - Replace with different widget during timer
        await tester.pump(const Duration(seconds: 1)); // Half of the timer

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: Text('Another Page')),
          ),
        );

        // Assert - New page is shown
        expect(find.text('Another Page'), findsOneWidget);

        // Act - Wait for the rest of the timer
        await tester.pump(LoadingPage.navigationDelay);
        await tester.pump();

        // Assert - Still on new page (no crashes)
        expect(find.text('Another Page'), findsOneWidget);
      });
    });
  });
}
