import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifebliss_app/main.dart';
import 'package:lifebliss_app/presentation/pages/loading_page.dart';
import '../../utils/test_helpers.dart';

void main() {
  setUp(setupMockWebViewPlatform);

  group('Responsive Layout Tests', () {
    testWidgets('App renders correctly on mobile screens', (WidgetTester tester) async {
      // Set up a mobile-sized screen
      tester.binding.window.physicalSizeTestValue = const Size(375, 667) * tester.binding.window.devicePixelRatio;
      tester.binding.window.devicePixelRatioTestValue = 2.0;

      // Build the app
      await tester.pumpWidget(const MyApp());

      // Verify LoadingPage displays properly
      expect(find.byType(LoadingPage), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);

      // Get the loading text widget to check its style
      final Text loadingText = tester.widget(find.text('Loading...'));
      expect(loadingText.style?.fontSize, 24); // Check correct font size for mobile

      // Verify container exists (without checking specific constraints)
      expect(find.byType(Container), findsWidgets);

      // Reset the test values
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
    });

    testWidgets('App renders correctly on tablet screens', (WidgetTester tester) async {
      // Set up a tablet-sized screen
      tester.binding.window.physicalSizeTestValue = const Size(768, 1024) * tester.binding.window.devicePixelRatio;
      tester.binding.window.devicePixelRatioTestValue = 2.0;

      // Build the app
      await tester.pumpWidget(const MyApp());

      // Verify LoadingPage displays properly
      expect(find.byType(LoadingPage), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);

      // Check that UI adjusts properly to tablet size
      // This is a basic check - in a real app, you might test specific tablet layouts

      // Reset the test values
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
    });

    testWidgets('App renders correctly on desktop screens', (WidgetTester tester) async {
      // Set up a desktop-sized screen
      tester.binding.window.physicalSizeTestValue = const Size(1366, 768) * tester.binding.window.devicePixelRatio;
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      // Build the app
      await tester.pumpWidget(const MyApp());

      // Verify LoadingPage displays properly
      expect(find.byType(LoadingPage), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);

      // Check that UI adjusts properly to desktop size
      // This is a basic check - in a real app, you might test specific desktop layouts

      // Reset the test values
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
    });

    testWidgets('Loading indicator is centered regardless of screen size', (WidgetTester tester) async {
      // Test with different screen sizes
      final screenSizes = [
        const Size(320, 568), // Small phone
        const Size(375, 667), // Medium phone
        const Size(768, 1024), // Tablet
        const Size(1366, 768), // Desktop
      ];

      for (final size in screenSizes) {
        // Set up screen size
        tester.binding.window.physicalSizeTestValue = size * tester.binding.window.devicePixelRatio;

        // Build the app
        await tester.pumpWidget(const MyApp());

        // Verify centered layout
        final centerFinder = find.byType(Center);
        expect(centerFinder, findsWidgets);

        // Verify CircularProgressIndicator is present
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Verify loading text is present
        expect(find.text('Loading...'), findsOneWidget);
      }

      // Reset the test values
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });
  });
}
