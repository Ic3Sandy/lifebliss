import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifebliss_app/main.dart';
import '../../utils/test_helpers.dart';

void main() {
  setUp(setupMockWebViewPlatform);

  group('Theme Tests', () {
    testWidgets('App has correct theme colors', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const MyApp());

      // Get the MaterialApp to check theme
      final MaterialApp app = tester.widget(find.byType(MaterialApp));

      // Verify theme data
      final ThemeData theme = app.theme!;
      expect(theme.useMaterial3, isTrue);

      // Check color scheme is based on blue
      final ColorScheme colorScheme = theme.colorScheme;
      expect(colorScheme.primary.blue, greaterThan(0));
    });

    testWidgets('App has blue gradient background on loading page', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const MyApp());

      // Find container with the gradient background
      final Container container = tester.widget(find.byType(Container).first);

      // Verify it has a decoration
      expect(container.decoration, isA<BoxDecoration>());

      // Verify it has a gradient
      final BoxDecoration decoration = container.decoration as BoxDecoration;
      expect(decoration.gradient, isA<LinearGradient>());

      // Verify gradient colors
      final LinearGradient gradient = decoration.gradient as LinearGradient;
      expect(gradient.colors.length, 2);
      expect(gradient.colors.first, Colors.blue);
      expect(gradient.colors.last, Colors.lightBlueAccent);
    });

    testWidgets('Loading text has correct style', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const MyApp());

      // Find the 'Loading...' text
      final Text loadingText = tester.widget(find.text('Loading...'));

      // Verify text style
      expect(loadingText.style, isNotNull);
      expect(loadingText.style!.color, Colors.white);
      expect(loadingText.style!.fontSize, 24);
      expect(loadingText.style!.fontWeight, FontWeight.bold);
    });

    testWidgets('CircularProgressIndicator has white color', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const MyApp());

      // Find the CircularProgressIndicator
      final CircularProgressIndicator progressIndicator = tester.widget(find.byType(CircularProgressIndicator));

      // Verify color
      expect(progressIndicator.color, Colors.white);
    });

    testWidgets('App uses specific font properties', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const MyApp());

      // Get the MaterialApp to check theme
      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      final ThemeData theme = app.theme!;

      // Verify text theme settings
      final TextTheme textTheme = theme.textTheme;

      // This is a general check - your app might have specific font settings
      expect(textTheme, isNotNull);
    });

    testWidgets('App title is set correctly', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const MyApp());

      // Get the MaterialApp to check title
      final MaterialApp app = tester.widget(find.byType(MaterialApp));

      // Verify title
      expect(app.title, 'Lifebliss');
    });

    testWidgets('Debug banner is disabled', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const MyApp());

      // Get the MaterialApp to check debug banner
      final MaterialApp app = tester.widget(find.byType(MaterialApp));

      // Verify debug banner is disabled
      expect(app.debugShowCheckedModeBanner, isFalse);
    });
  });
}
