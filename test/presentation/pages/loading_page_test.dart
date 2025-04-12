import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifebliss_app/presentation/pages/loading_page.dart';
import 'package:lifebliss_app/presentation/pages/home_page.dart';
import '../../utils/test_helpers.dart';
import '../../utils/test_mocks.dart';

void main() {
  setUp(() {
    setupMockWebViewPlatform();
  });

  group('LoadingPage', () {
    testWidgets('should display correct UI elements', (WidgetTester tester) async {
      // Build the LoadingPage widget with navigation disabled
      await tester.pumpWidget(testableWidget(const LoadingPage(navigateAfterDelay: false)));

      // Verify UI elements
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
      
      // Verify styling
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      final gradient = decoration.gradient as LinearGradient;
      
      expect(gradient.colors.length, 2);
      expect(gradient.colors[0], Colors.blue);
      expect(gradient.colors[1], Colors.lightBlueAccent);
    });

    testWidgets('should navigate to HomePage after delay', (WidgetTester tester) async {
      await assertTimedNavigation(
        tester: tester,
        originalWidget: const LoadingPage(),
        navigationDuration: LoadingPage.navigationDelay,
        originalWidgetFinder: find.byType(LoadingPage),
        targetWidgetFinder: find.byType(HomePage),
      );
    });

    testWidgets('should not navigate when navigateAfterDelay is false', (WidgetTester tester) async {
      // Build the LoadingPage widget with navigation disabled
      await tester.pumpWidget(testableWidget(const LoadingPage(navigateAfterDelay: false)));

      // Wait longer than the normal navigation delay
      await tester.pump(LoadingPage.navigationDelay + const Duration(milliseconds: 100));
      
      // No need to call pumpAndSettle since no animation should occur
      // Just manually pump once more to ensure any pending frames are processed
      await tester.pump();

      // Verify that we're still on the LoadingPage
      expect(find.byType(LoadingPage), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);
    });
    
    testWidgets('should handle widget disposal during timer', (WidgetTester tester) async {
      // Use a stateful wrapper to control the widget tree
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return const LoadingPage();
            },
          ),
        ),
      );
      
      // Verify LoadingPage is shown
      expect(find.byType(LoadingPage), findsOneWidget);
      
      // Replace the LoadingPage with a different widget before the timer completes
      await tester.pump(const Duration(seconds: 1)); // Half of the 2-second timer
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Text('Another Page')),
        ),
      );
      
      // Verify we're on the new page
      expect(find.text('Another Page'), findsOneWidget);
      
      // Wait for more than the timer duration
      await tester.pump(LoadingPage.navigationDelay);
      await tester.pump(); // Just pump once more without settling
      
      // Verify we're still on the new page (no crashes)
      expect(find.text('Another Page'), findsOneWidget);
    });
  });
}
