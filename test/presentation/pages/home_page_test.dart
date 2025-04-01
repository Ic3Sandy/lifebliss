import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifebliss_app/presentation/pages/home_page.dart';

void main() {
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

    testWidgets('should use responsive font size based on screen width - small screen', (WidgetTester tester) async {
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

    testWidgets('should use responsive font size based on screen width - large screen', (WidgetTester tester) async {
      // Set up a large screen size
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      // Build the HomePage widget with large screen
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Find the text widget
      final textWidget = tester.widget<Text>(find.text('Lifebliss'));
      
      // Verify font size for large screen
      expect((textWidget.style?.fontSize ?? 0) > 40, isTrue);

      // Reset the screen size to avoid affecting other tests
      addTearDown(() => tester.view.resetPhysicalSize());
    });

    testWidgets('should have gradient background', (WidgetTester tester) async {
      // Build the HomePage widget
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Find the container with the gradient using the key
      final container = tester.widget<Container>(find.byKey(const Key('background_container')));
      final decoration = container.decoration as BoxDecoration;
      final gradient = decoration.gradient as LinearGradient;
      
      // Verify gradient properties
      expect(gradient.colors.length, 2);
      // The initial colors should be white and blue
      expect(gradient.colors[0], Colors.white);
      expect(gradient.colors[1], Colors.blue);
      expect(gradient.begin, Alignment.topCenter);
      expect(gradient.end, Alignment.bottomCenter);
    });

    testWidgets('should have text with shadow effect', (WidgetTester tester) async {
      // Build the HomePage widget
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Find the text widget
      final textWidget = tester.widget<Text>(find.text('Lifebliss'));
      
      // Verify text style properties
      expect(textWidget.style?.shadows?.isNotEmpty, isTrue);
      expect(textWidget.style?.letterSpacing, 2.0);
      expect(textWidget.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('should change background color when title is tapped', (WidgetTester tester) async {
      // Build the HomePage widget
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Get the initial background colors
      final initialContainer = tester.widget<Container>(find.byKey(const Key('background_container')));
      final initialDecoration = initialContainer.decoration as BoxDecoration;
      final initialGradient = initialDecoration.gradient as LinearGradient;
      final initialColors = initialGradient.colors;

      // Find and tap the title text
      await tester.tap(find.text('Lifebliss'));
      await tester.pump();

      // Get the new background colors
      final updatedContainer = tester.widget<Container>(find.byKey(const Key('background_container')));
      final updatedDecoration = updatedContainer.decoration as BoxDecoration;
      final updatedGradient = updatedDecoration.gradient as LinearGradient;
      final updatedColors = updatedGradient.colors;

      // Verify that the background colors have changed
      expect(updatedColors, isNot(equals(initialColors)));
    });
  });
}
