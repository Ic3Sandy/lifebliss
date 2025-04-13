import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifebliss_app/main.dart';
import 'package:lifebliss_app/presentation/pages/loading_page.dart';
import 'utils/test_helpers.dart';

void main() {
  setUp(setupMockWebViewPlatform);

  group('MyApp', () {
    testWidgets('should display LoadingPage as home', (WidgetTester tester) async {
      // Build the main app
      await tester.pumpWidget(const MyApp());

      // Verify that LoadingPage is shown
      expect(find.byType(LoadingPage), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should have correct theme settings', (WidgetTester tester) async {
      // Build the main app
      await tester.pumpWidget(const MyApp());

      // Get MaterialApp widget to check theme
      final MaterialApp app = tester.widget<MaterialApp>(find.byType(MaterialApp));

      // Verify theme properties
      expect(app.title, 'Lifebliss');
      expect(app.debugShowCheckedModeBanner, false);

      // Verify theme data uses Material 3
      final ThemeData theme = app.theme!;
      expect(theme.useMaterial3, true);

      // Verify color scheme is using a blue-based color scheme
      final ColorScheme colorScheme = theme.colorScheme;
      expect(colorScheme.primary, isA<Color>());
      expect(colorScheme.primary.b > 0, true); // Check blue component
    });
  });
}
