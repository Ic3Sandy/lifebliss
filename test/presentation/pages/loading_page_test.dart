import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifebliss_app/presentation/pages/loading_page.dart';
import 'package:lifebliss_app/presentation/pages/home_page.dart';

void main() {
  group('LoadingPage', () {
    testWidgets('should display correct UI elements', (WidgetTester tester) async {
      // Build the LoadingPage widget with navigation disabled
      await tester.pumpWidget(
        const MaterialApp(
          home: LoadingPage(navigateAfterDelay: false),
        ),
      );

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

    testWidgets('should wait exactly 2 seconds before navigating', (WidgetTester tester) async {
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
      
      // Verify still on LoadingPage after 1 second
      expect(find.byType(LoadingPage), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);
      
      // Wait for 0.9 seconds (total 1.9 seconds) - should still be on LoadingPage
      await tester.pump(const Duration(milliseconds: 900));
      
      // Verify still on LoadingPage after 1.9 seconds
      expect(find.byType(LoadingPage), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);
      
      // Wait for 0.2 seconds more (total 2.1 seconds) - should now be on HomePage
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
      
      // Verify that HomePage is now shown after 2.1 seconds
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(LoadingPage), findsNothing);
    });

    testWidgets('should navigate to HomePage after exactly 2 seconds', (WidgetTester tester) async {
      // Build the LoadingPage widget with navigation enabled
      await tester.pumpWidget(
        const MaterialApp(
          home: LoadingPage(),
        ),
      );

      // Verify LoadingPage is initially shown
      expect(find.byType(LoadingPage), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);

      // Wait for 1.9 seconds - should still be on LoadingPage
      await tester.pump(const Duration(milliseconds: 1900));
      expect(find.byType(LoadingPage), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);

      // Wait until just after 2 seconds (the new expected delay)
      await tester.pump(const Duration(milliseconds: 200));

      // Trigger the animation
      await tester.pumpAndSettle();

      // Verify that HomePage is now shown
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(LoadingPage), findsNothing);
    });

    testWidgets('should not navigate when navigateAfterDelay is false', (WidgetTester tester) async {
      // Build the LoadingPage widget with navigation disabled
      await tester.pumpWidget(
        const MaterialApp(
          home: LoadingPage(navigateAfterDelay: false),
        ),
      );

      // Verify LoadingPage is initially shown
      expect(find.byType(LoadingPage), findsOneWidget);

      // Wait longer than the normal navigation delay
      await tester.pump(const Duration(seconds: 2));

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
      // Using 1 second (half of the 2-second timer)
      await tester.pump(const Duration(seconds: 1));
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Text('Another Page')),
        ),
      );
      
      // Verify we're on the new page
      expect(find.text('Another Page'), findsOneWidget);
      
      // Wait for more than the timer duration
      await tester.pump(const Duration(seconds: 1, milliseconds: 100));
      
      // Verify we're still on the new page (no crashes)
      expect(find.text('Another Page'), findsOneWidget);
    });
  });
}
