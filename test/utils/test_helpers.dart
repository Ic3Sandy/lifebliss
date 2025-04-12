import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'test_mocks.dart';

/// Sets up the mock WebView platform for testing
void setupMockWebViewPlatform() {
  WebViewPlatform.instance = MockWebViewPlatform();
}

/// Wraps a widget in a MaterialApp for testing
Widget testableWidget(Widget child) {
  return MaterialApp(
    home: child,
  );
}

/// Asserts that a timer-based navigation happens within the expected timeframe
/// 
/// This helper handles both the assertion before the expected navigation time
/// (that the original widget is still present) and after (that the navigation occurred)
Future<void> assertTimedNavigation<T, U>({
  required WidgetTester tester,
  required Widget originalWidget,
  required Duration navigationDuration,
  required Finder originalWidgetFinder,
  required Finder targetWidgetFinder,
}) async {
  // Pump the widget
  await tester.pumpWidget(testableWidget(originalWidget));
  
  // Verify initial state
  expect(originalWidgetFinder, findsOneWidget);
  expect(targetWidgetFinder, findsNothing);
  
  // Wait for slightly less than the navigation duration
  await tester.pump(navigationDuration - const Duration(milliseconds: 100));
  
  // Verify still in initial state
  expect(originalWidgetFinder, findsOneWidget);
  expect(targetWidgetFinder, findsNothing);
  
  // Wait until just after the navigation duration
  await tester.pump(const Duration(milliseconds: 200));
  
  // Complete any animations
  await tester.pumpAndSettle();
  
  // Verify navigation occurred
  expect(targetWidgetFinder, findsOneWidget);
  expect(originalWidgetFinder, findsNothing);
} 