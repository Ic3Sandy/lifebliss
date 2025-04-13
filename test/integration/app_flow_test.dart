import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifebliss_app/main.dart';
import 'package:lifebliss_app/presentation/pages/home_page.dart';
import 'package:lifebliss_app/presentation/pages/loading_page.dart';

import '../utils/test_helpers.dart';

/// Setup for integration tests
void setupIntegrationTests() {
  setupMockWebViewPlatform();

  // Add mock for asset loading
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
    'flutter/assets',
    (ByteData? message) async {
      // Return mock HTML content
      const String mockHtml = '<!DOCTYPE html><html><body>'
          ' <h1 id="app-title">Lifebliss</h1></body></html>';
      return ByteData.view(Uint8List.fromList(mockHtml.codeUnits).buffer);
    },
  );
}

void main() {
  setUp(setupIntegrationTests);

  group('Full App Flow Integration Tests', () {
    testWidgets(
      'App should start with loading screen and navigate to home page',
      (WidgetTester tester) async {
        // Build the main app
        await tester.pumpWidget(const MyApp());

        // Verify LoadingPage is shown initially
        expect(find.byType(LoadingPage), findsOneWidget);
        expect(find.text('Loading...'), findsOneWidget);

        // Wait for loading screen delay
        await tester.pump(
          LoadingPage.navigationDelay - const Duration(milliseconds: 100),
        );

        // Should still be on loading screen
        expect(find.byType(LoadingPage), findsOneWidget);

        // Wait until navigation time
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pumpAndSettle();

        // Should now be on HomePage
        expect(find.byType(HomePage), findsOneWidget);
      },
    );

    testWidgets(
      'Error handling - app should gracefully handle asset loading errors',
      (WidgetTester tester) async {
        // Override asset loading to return null (error)
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
          'flutter/assets',
          (ByteData? message) async {
            return null; // Simulate asset loading error
          },
        );

        // Build app and navigate to HomePage
        await tester.pumpWidget(const MyApp());

        // Wait for loading screen
        await tester.pump(LoadingPage.navigationDelay);
        await tester.pumpAndSettle();

        // Verify HomePage is shown with WebView
        expect(find.byType(HomePage), findsOneWidget);

        // The error is handled in HomePage, which should still be functional
        // even with asset loading error
      },
    );

    testWidgets(
      'Integration test with orientation changes',
      (WidgetTester tester) async {
        // Initialize app
        await tester.pumpWidget(const MyApp());

        // Wait for navigation to HomePage
        await tester.pump(LoadingPage.navigationDelay);
        await tester.pumpAndSettle();

        // Verify we're on HomePage
        expect(find.byType(HomePage), findsOneWidget);

        // Simulate landscape orientation
        await tester.binding.setSurfaceSize(
          Size(
            DeviceSizes.mobileMedium.height, // Switch height and width
            DeviceSizes.mobileMedium.width,
          ),
        );
        await tester.pumpAndSettle();

        // Verify app is still functional
        expect(find.byType(AppBar), findsOneWidget);

        // Restore portrait orientation
        await tester.binding.setSurfaceSize(DeviceSizes.mobileMedium);
        await tester.pumpAndSettle();
      },
    );
  });
}
