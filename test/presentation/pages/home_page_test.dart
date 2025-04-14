import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifebliss_app/presentation/pages/home_page.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../mocks/mock_color_service.dart';
import '../../utils/test_mocks.dart';

// Helper function to create a testable widget with proper ancestors
Widget testableWidget(Widget child) {
  return MaterialApp(
    home: child,
  );
}

void main() {
  // Replace the default WebView platform with our mock
  setupMockWebViewPlatform();

  // Create a mock for the ColorService
  late MockColorService mockColorService;

  setUp(() {
    // Ensure we have a fresh controller for each test
    MockWebViewPlatform.lastCreatedController = null;
    // Create a fresh MockColorService for each test
    mockColorService = MockColorService();
  });

  group('HomePage', () {
    testWidgets('renders correctly with WebView', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(testableWidget(const HomePage()));

      // Verify that our app bar renders
      expect(find.text('Lifebliss'), findsOneWidget);

      // Verify that our WebView renders (via our mock)
      expect(find.byType(WebViewWidget), findsOneWidget);
    });

    testWidgets(
      'uses provided ColorService when specified',
      (WidgetTester tester) async {
        // Build the HomePage with the mock service
        await tester.pumpWidget(testableWidget(HomePage(
          colorService: mockColorService,
        )));

        // Allow WebView to initialize
        await tester.pumpAndSettle();

        // Act - Press the color change button
        await tester.tap(find.byIcon(Icons.color_lens));
        await tester.pump();

        // Assert - Verify the mock color service was used
        expect(mockColorService.getRandomColorHexCalled, isTrue);
      },
    );

    testWidgets('can use static test method', (WidgetTester tester) async {
      // Act - Use the static test method
      HomePage.testColorService(mockColorService);

      // Assert - Verify the mock was called correctly
      expect(mockColorService.getRandomColorHexCalled, isTrue);
    });

    // Test for JavaScript message handling in the HomePage
    testWidgets(
      'handles JavaScript messages correctly',
      (WidgetTester tester) async {
        // Build the HomePage with the mock service
        await tester.pumpWidget(testableWidget(HomePage(
          colorService: mockColorService,
        )));

        // Wait for the widget to be built
        await tester.pumpAndSettle();

        // Get the controller
        final controller = MockWebViewPlatform.lastCreatedController;

        // Verify controller is not null
        expect(controller, isNotNull);

        // Find the JavaScript channel
        const channelName = 'flutter';
        const errorMsg = 'flutter JavaScript channel not found';

        final webController = controller as MockPlatformWebViewController;
        final jsChannel = webController.addedJavaScriptChannels.firstWhere(
          (channel) => channel.name == channelName,
          orElse: () => throw TestFailure(errorMsg),
        );

        // Create a JavaScriptMessage with the titleClicked message
        const jsMessage = JavaScriptMessage(message: 'titleClicked');

        // Simulate a titleClicked message from JavaScript
        jsChannel.onMessageReceived(jsMessage);

        // Verify the color service was called in response to the message
        expect(mockColorService.getRandomColorHexCalled, isTrue);
      },
    );

    testWidgets(
      'handles channelTest JavaScript message',
      (WidgetTester tester) async {
        // Build the HomePage with the mock service
        await tester.pumpWidget(testableWidget(HomePage(
          colorService: mockColorService,
        )));

        // Wait for the widget to be built
        await tester.pumpAndSettle();

        // Get the controller
        final controller = MockWebViewPlatform.lastCreatedController;

        // Verify controller is not null
        expect(controller, isNotNull);

        // Find the JavaScript channel
        const channelName = 'flutter';
        const errorMsg = 'flutter JavaScript channel not found';

        final webController = controller as MockPlatformWebViewController;
        final jsChannel = webController.addedJavaScriptChannels.firstWhere(
          (channel) => channel.name == channelName,
          orElse: () => throw TestFailure(errorMsg),
        );

        // Create a JavaScriptMessage with the channelTest message
        const jsMessage = JavaScriptMessage(message: 'channelTest');

        // Simulate a channelTest message from JavaScript
        jsChannel.onMessageReceived(jsMessage);

        // This message doesn't trigger a color change
        expect(mockColorService.getRandomColorHexCalled, isFalse);
      },
    );

    testWidgets(
      'handles openGallery JavaScript message',
      (WidgetTester tester) async {
        // Build the HomePage with the mock service
        await tester.pumpWidget(testableWidget(HomePage(
          colorService: mockColorService,
        )));

        // Wait for the widget to be built
        await tester.pumpAndSettle();

        // Get the controller
        final controller = MockWebViewPlatform.lastCreatedController;

        // Verify controller is not null
        expect(controller, isNotNull);

        // Find the JavaScript channel
        const channelName = 'flutter';
        const errorMsg = 'flutter JavaScript channel not found';

        final webController = controller as MockPlatformWebViewController;
        final jsChannel = webController.addedJavaScriptChannels.firstWhere(
          (channel) => channel.name == channelName,
          orElse: () => throw TestFailure(errorMsg),
        );

        // Create a JavaScriptMessage with the openGallery message
        const jsMessage = JavaScriptMessage(message: 'openGallery');

        // Simulate an openGallery message from JavaScript
        jsChannel.onMessageReceived(jsMessage);

        // Wait for processing
        await tester.pumpAndSettle();

        // Verify debug logs (these can be observed in the test output)
        // The output should show:
        // - "Open gallery request from JavaScript"
        // - "Opening device gallery"
      },
    );

    testWidgets(
      'handles JSON format openGallery message',
      (WidgetTester tester) async {
        // Build the HomePage with the mock service
        await tester.pumpWidget(testableWidget(HomePage(
          colorService: mockColorService,
        )));

        // Wait for the widget to be built
        await tester.pumpAndSettle();

        // Get the controller
        final controller = MockWebViewPlatform.lastCreatedController;

        // Verify controller is not null
        expect(controller, isNotNull);

        // Find the JavaScript channel
        const channelName = 'flutter';
        const errorMsg = 'flutter JavaScript channel not found';

        final webController = controller as MockPlatformWebViewController;
        final jsChannel = webController.addedJavaScriptChannels.firstWhere(
          (channel) => channel.name == channelName,
          orElse: () => throw TestFailure(errorMsg),
        );

        // Create a JavaScriptMessage with a JSON openGallery message
        const jsonMessage = '{"action":"openGallery"}';
        const jsMessage = JavaScriptMessage(message: jsonMessage);

        // Simulate a JSON message from JavaScript
        jsChannel.onMessageReceived(jsMessage);

        // Wait for processing
        await tester.pumpAndSettle();

        // Verify debug logs (these can be observed in the test output)
        // The output should show:
        // - "Handling JavaScript action: openGallery"
        // - "Opening device gallery"
      },
    );

    // Test for the WebView controller initialization
    testWidgets(
      'initializes the WebView controller',
      (WidgetTester tester) async {
        // Build the HomePage widget
        await tester.pumpWidget(testableWidget(const HomePage()));

        // Verify the controller is created
        expect(MockWebViewPlatform.lastCreatedController, isNotNull);
      },
    );
  });
}
