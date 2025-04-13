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
  final testBinding = TestDefaultBinaryMessengerBinding.instance;
  final messenger = testBinding.defaultBinaryMessenger;
  messenger.setMockMessageHandler(
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
        // Setup mocks
        setupMockWebViewPlatform();

        // Start the app
        await tester.pumpWidget(const MyApp());

        // Verify we start with the loading page
        expect(find.byType(LoadingPage), findsOneWidget);
        expect(find.text('Loading...'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Wait for navigation to occur
        await tester.pump(LoadingPage.navigationDelay + const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        // Verify we navigated to the home page
        expect(find.byType(HomePage), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('Lifebliss'), findsOneWidget);

        // Verify color change button exists
        expect(find.byIcon(Icons.color_lens), findsOneWidget);

        // Tap the color button
        await tester.tap(find.byIcon(Icons.color_lens));
        await tester.pump();

        // Wait for animations to complete
        await tester.pumpAndSettle();

        // We've reached the end of the flow without errors
      },
    );

    testWidgets(
      'Error handling - app should gracefully handle asset loading errors',
      (WidgetTester tester) async {
        // Override asset loading to return null (error)
        final testBinding = TestDefaultBinaryMessengerBinding.instance;
        final messenger = testBinding.defaultBinaryMessenger;
        messenger.setMockMessageHandler(
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
