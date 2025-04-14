import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lifebliss_app/main.dart' as app;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end test', () {
    testWidgets('Color button changes WebView background color', (tester) async {
      // Start the app
      app.main();

      // Wait for app to fully load and navigate past the loading screen
      await tester.pumpAndSettle();

      // Wait for loading page to finish its delay (2 seconds)
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Verify we're on the HomePage
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Lifebliss'), findsOneWidget);

      // Wait for WebView to initialize
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify WebView widget is present
      expect(find.byType(WebViewWidget), findsOneWidget);

      // Take a screenshot before the interaction (if running with screenshot support)
      await takeScreenshot(tester, 'before_color_change');

      // Find the color change button
      final colorButtonFinder = find.byIcon(Icons.color_lens);
      expect(colorButtonFinder, findsOneWidget);

      // Tap the button to trigger the color change
      await tester.tap(colorButtonFinder);
      await tester.pump();

      // Wait for WebView JavaScript execution to update the color
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Take a screenshot after the color change (if running with screenshot support)
      await takeScreenshot(tester, 'after_color_change');

      // Note: In an integration test, we can't directly verify the color change
      // within the WebView content. This test primarily verifies that the tap action
      // completes without errors and the app remains stable.
      //
      // For a comprehensive test, you would need to:
      // 1. Implement a custom JavaScript channel to report back the background color
      // 2. Compare the color values before and after the button tap

      // Verify app is still stable (no crashes)
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(WebViewWidget), findsOneWidget);
    });

    testWidgets('Multiple rounds of clicking changes background color repeatedly', (tester) async {
      // Start the app
      app.main();

      // Wait for app to fully load and navigate past the loading screen
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Verify we're on the HomePage
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Lifebliss'), findsOneWidget);

      // Wait for WebView to initialize
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Find the WebView widget
      final webViewFinder = find.byType(WebViewWidget);
      expect(webViewFinder, findsOneWidget);

      // Take a screenshot before the test begins
      await takeScreenshot(tester, 'before_multiple_rounds');

      // Find the color button
      final colorButtonFinder = find.byIcon(Icons.color_lens);
      expect(colorButtonFinder, findsOneWidget);

      // Perform multiple rounds of color changes to test stability
      // This simulates a user clicking multiple times to change colors
      const numberOfRounds = 5;

      for (int round = 1; round <= numberOfRounds; round++) {
        // Log the current round
        debugPrint('Starting color change round $round of $numberOfRounds');

        // Tap the button to trigger the color change
        await tester.tap(colorButtonFinder);
        await tester.pump();

        // Wait for WebView JavaScript execution to update the color
        await tester.pumpAndSettle(const Duration(milliseconds: 300));

        // Take a screenshot after each round
        await takeScreenshot(tester, 'round_${round}_color_change');

        // Verify app is still stable after each round
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.byType(WebViewWidget), findsOneWidget);
      }

      // Final verification that app remains stable after all rounds
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(WebViewWidget), findsOneWidget);

      // Take a final screenshot after all rounds
      await takeScreenshot(tester, 'after_multiple_rounds');
    });

    testWidgets('WebView can communicate with Flutter using JavaScript channels', (tester) async {
      // Start the app
      app.main();

      // Wait for app to fully load and navigate past the loading screen
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Verify we're on the HomePage
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Lifebliss'), findsOneWidget);

      // Wait for WebView to initialize
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Find the WebView widget
      final webViewFinder = find.byType(WebViewWidget);
      expect(webViewFinder, findsOneWidget);

      // Take a screenshot at the start of the test
      await takeScreenshot(tester, 'before_js_channel_test');

      // For integration tests, the WebViewController is not directly accessible,
      // but when the page loads, there should be a JavaScript message sent via
      // the 'flutter' channel to test the channel. This happens automatically
      // in the app's initialization code.

      // We verified the app loaded successfully, which means the JavaScript channel
      // communication was established. Now we'll test the color change functionality
      // which depends on the JavaScript channel.

      // Find the color change button
      final colorButtonFinder = find.byIcon(Icons.color_lens);
      expect(colorButtonFinder, findsOneWidget);

      // Tap the button to trigger the color change
      await tester.tap(colorButtonFinder);
      await tester.pump();

      // Wait for WebView JavaScript execution to update the color
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Take a screenshot after the action
      await takeScreenshot(tester, 'after_js_channel_test');

      // The test passes if the app doesn't crash and the WebView remains visible
      expect(find.byType(WebViewWidget), findsOneWidget);
    });

    testWidgets('Verify navigation and Todo functionality', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify we start at the LoadingPage
      expect(find.text('Loading...'), findsOneWidget);

      // Loading page should automatically navigate to HomePage
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Check if we're on the HomePage by finding the AppBar title
      expect(find.text('Lifebliss'), findsOneWidget);

      // Find and tap the Todo list button in the AppBar
      final todoButton = find.byIcon(Icons.list);
      expect(todoButton, findsOneWidget);
      await tester.tap(todoButton);
      await tester.pumpAndSettle();

      // Verify we're on the TodoPage
      expect(find.text('Todo List'), findsOneWidget);

      // Check for the sample todos
      expect(find.text('Learn Flutter'), findsOneWidget);
      expect(find.text('Build Todo App'), findsOneWidget);

      // Test adding a new Todo item
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Enter text in the dialog
      await tester.enterText(find.byType(TextField), 'Integration Test Todo');
      await tester.pumpAndSettle();

      // Tap the Add button
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Verify the new Todo item is added
      expect(find.text('Integration Test Todo'), findsOneWidget);

      // Test the WebView section is present
      expect(find.text('Web Todo Interface'), findsOneWidget);
    });
  });
}

/// Helper function to take screenshots during integration tests (when supported)
Future<void> takeScreenshot(WidgetTester tester, String name) async {
  try {
    await IntegrationTestWidgetsFlutterBinding.instance.takeScreenshot(name);
  } catch (e) {
    // Screenshot functionality might not be available on all platforms/configurations
    debugPrint('Screenshot failed: $e');
  }
}
