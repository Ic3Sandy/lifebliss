import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter/webview_flutter.dart';
// Export setupMockWebViewPlatform from test_mocks.dart
export 'test_mocks.dart' show setupMockWebViewPlatform;

/// Wraps a widget in a MaterialApp for testing
Widget testableWidget(Widget child) {
  return MaterialApp(
    home: child,
  );
}

/// Wraps a widget in a MaterialApp with specific dimensions for responsive testing
Widget responsiveTestableWidget(Widget child, {required double width, required double height}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(size: Size(width, height)),
      child: child,
    ),
  );
}

/// Common device sizes for responsive testing
class DeviceSizes {
  static const Size mobileSmall = Size(320, 568); // iPhone SE
  static const Size mobileMedium = Size(375, 667); // iPhone 8
  static const Size mobileLarge = Size(414, 896); // iPhone 11 Pro Max
  static const Size tablet = Size(768, 1024); // iPad
  static const Size desktop = Size(1366, 768); // Common laptop
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
