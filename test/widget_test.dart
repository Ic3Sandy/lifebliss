import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifebliss_app/presentation/pages/loading_page.dart';
import 'package:lifebliss_app/presentation/pages/home_page.dart';

void main() {
  group('MyApp', () {
    testWidgets('should display LoadingPage as home', (WidgetTester tester) async {
      // Override the LoadingPage to disable auto-navigation for testing
      await tester.pumpWidget(const MaterialApp(
        home: LoadingPage(navigateAfterDelay: false),
      ));

      // Verify that LoadingPage is shown
      expect(find.byType(LoadingPage), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('LoadingPage', () {
    testWidgets('should display loading indicator and text', (WidgetTester tester) async {
      // Build the LoadingPage widget
      await tester.pumpWidget(
        const MaterialApp(
          home: LoadingPage(navigateAfterDelay: false), // Disable auto-navigation for this test
        ),
      );

      // Verify that the loading indicator and text are displayed
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('should navigate to HomePage after delay', (WidgetTester tester) async {
      // Build the LoadingPage widget with navigation enabled
      await tester.pumpWidget(
        const MaterialApp(
          home: LoadingPage(),
        ),
      );

      // Verify LoadingPage is initially shown
      expect(find.byType(LoadingPage), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);

      // Wait for 1 second - should still be on LoadingPage
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(LoadingPage), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);

      // Wait for the navigation delay (slightly more than 2 seconds total)
      await tester.pump(const Duration(seconds: 1, milliseconds: 100));

      // Trigger the animation
      await tester.pumpAndSettle();

      // Verify that HomePage is now shown
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(LoadingPage), findsNothing);
    });
  });

  group('HomePage', () {
    testWidgets('should display app title', (WidgetTester tester) async {
      // Build the HomePage widget
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Verify that the app title is displayed
      expect(find.text('Lifebliss'), findsOneWidget);
    });

    testWidgets('should use responsive font size based on screen width', (WidgetTester tester) async {
      // Set up a small screen size
      tester.view.physicalSize = const Size(300, 600);
      tester.view.devicePixelRatio = 1.0;

      // Build the HomePage widget with small screen
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Find the text widget
      final textWidget = tester.widget<Text>(find.text('Lifebliss'));
      
      // Verify font size for small screen
      expect((textWidget.style?.fontSize ?? 0) <= 40, isTrue);

      // Reset the screen size to avoid affecting other tests
      addTearDown(() => tester.view.resetPhysicalSize());
    });
  });
}
