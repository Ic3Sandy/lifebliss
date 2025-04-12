import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifebliss_app/presentation/pages/loading_page.dart';
import 'package:lifebliss_app/presentation/pages/home_page.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_platform_interface/src/types/types.dart' hide WebViewPlatform;

// --- Paste the MockWebViewPlatform, MockPlatformWebViewWidget, MockPlatformWebViewController classes here ---
class MockWebViewPlatform extends WebViewPlatform {
  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) {
    return MockPlatformWebViewWidget(params);
  }

  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) {
    return MockPlatformWebViewController(params);
  }

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
      PlatformNavigationDelegateCreationParams params) {
    return MockPlatformNavigationDelegate(params);
  }
}

class MockPlatformWebViewWidget extends PlatformWebViewWidget {
  MockPlatformWebViewWidget(super.params)
      : super.implementation();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      key: ValueKey('MockPlatformWebViewWidget'),
      width: 100,
      height: 100,
    );
  }
}

class MockPlatformWebViewController extends PlatformWebViewController {
  MockPlatformWebViewController(super.params)
      : super.implementation();
  @override Future<void> loadRequest(LoadRequestParams params) async { }
  @override Future<void> setPlatformNavigationDelegate(PlatformNavigationDelegate handler) async { }
  @override Future<void> setJavaScriptMode(JavaScriptMode mode) async { }
  @override Future<void> setBackgroundColor(Color color) async { }
  @override Future<void> loadHtmlString(String html, {String? baseUrl}) async { }
  @override Future<void> loadFile(String absoluteFilePath) async { }
  @override Future<String?> currentUrl() async => null;
  @override Future<bool> canGoBack() async => false;
  @override Future<bool> canGoForward() async => false;
  @override Future<void> goBack() async { }
  @override Future<void> goForward() async { }
  @override Future<void> reload() async { }
  @override Future<void> clearCache() async { }
  @override Future<void> clearLocalStorage() async { }
  @override Future<void> runJavaScript(String javaScript) async { }
  @override Future<Object> runJavaScriptReturningResult(String javaScript) async => Object();
  @override Future<void> addJavaScriptChannel(JavaScriptChannelParams javaScriptChannelParams) async { }
  @override Future<void> removeJavaScriptChannel(String javaScriptChannelName) async { }
  @override Future<String?> getTitle() async => null;
  @override Future<void> scrollTo(int x, int y) async { }
  @override Future<void> scrollBy(int x, int y) async { }
  @override Future<Offset> getScrollPosition() async => Offset.zero;
  @override Future<void> enableZoom(bool enabled) async { }
  @override Future<void> setMediaPlaybackRequiresUserGesture(bool require) async { }
  @override Future<void> setUserAgent(String? userAgent) async { }
}

class MockPlatformNavigationDelegate extends PlatformNavigationDelegate {
  MockPlatformNavigationDelegate(super.params)
      : super.implementation();

  @override
  Future<void> setOnPageStarted(PageEventCallback onPageStarted) async {}

  @override
  Future<void> setOnPageFinished(PageEventCallback onPageFinished) async {}

  @override
  Future<void> setOnProgress(ProgressCallback onProgress) async {}

  @override
  Future<void> setOnWebResourceError(WebResourceErrorCallback onWebResourceError) async {}

  @override
  Future<void> setOnNavigationRequest(NavigationRequestCallback onNavigationRequest) async {}

  @override
  Future<void> setOnUrlChange(UrlChangeCallback onUrlChange) async {}
  
  @override
  Future<void> setOnHttpAuthRequest(HttpAuthRequestCallback onHttpAuthRequest) async {}
  
  @override
  Future<void> setOnHttpError(HttpResponseErrorCallback onHttpError) async {}
}
// --- End of pasted mock classes ---

void main() {
  setUp(() {
    // Set the mock platform implementation before each test
    WebViewPlatform.instance = MockWebViewPlatform();
  });

  group('LoadingPage', () {
    testWidgets('should display correct UI elements', (WidgetTester tester) async {
      // Build the LoadingPage widget with navigation disabled
      await tester.pumpWidget(
        const MaterialApp(
          home: LoadingPage(navigateAfterDelay: false),
        ),
      );

      // Verify UI elements
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
      
      // Verify styling
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      final gradient = decoration.gradient as LinearGradient;
      
      expect(gradient.colors.length, 2);
      expect(gradient.colors[0], Colors.blue);
      expect(gradient.colors[1], Colors.lightBlueAccent);
    });

    testWidgets('should wait exactly 2 seconds before navigating', (WidgetTester tester) async {
      // Build the LoadingPage widget with navigation enabled
      await tester.pumpWidget(
        const MaterialApp(
          home: LoadingPage(),
        ),
      );

      // Verify LoadingPage is initially shown
      expect(find.byType(LoadingPage), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);

      // Wait for 1 second - should still be on LoadingPage
      await tester.pump(const Duration(seconds: 1));
      
      // Verify still on LoadingPage after 1 second
      expect(find.byType(LoadingPage), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);
      
      // Wait for 0.9 seconds (total 1.9 seconds) - should still be on LoadingPage
      await tester.pump(const Duration(milliseconds: 900));
      
      // Verify still on LoadingPage after 1.9 seconds
      expect(find.byType(LoadingPage), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);
      
      // Wait for 0.2 seconds more (total 2.1 seconds) - should now be on HomePage
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
      
      // Verify that HomePage is now shown after 2.1 seconds
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(LoadingPage), findsNothing);
    });

    testWidgets('should navigate to HomePage after exactly 2 seconds', (WidgetTester tester) async {
      // Build the LoadingPage widget with navigation enabled
      await tester.pumpWidget(
        const MaterialApp(
          home: LoadingPage(),
        ),
      );

      // Verify LoadingPage is initially shown
      expect(find.byType(LoadingPage), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);

      // Wait for 1.9 seconds - should still be on LoadingPage
      await tester.pump(const Duration(milliseconds: 1900));
      expect(find.byType(LoadingPage), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);

      // Wait until just after 2 seconds (the new expected delay)
      await tester.pump(const Duration(milliseconds: 200));

      // Trigger the animation
      await tester.pumpAndSettle();

      // Verify that HomePage is now shown
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(LoadingPage), findsNothing);
    });

    testWidgets('should not navigate when navigateAfterDelay is false', (WidgetTester tester) async {
      // Build the LoadingPage widget with navigation disabled
      await tester.pumpWidget(
        const MaterialApp(
          home: LoadingPage(navigateAfterDelay: false),
        ),
      );

      // Verify LoadingPage is initially shown
      expect(find.byType(LoadingPage), findsOneWidget);

      // Wait longer than the normal navigation delay
      await tester.pump(const Duration(seconds: 2));

      // Verify that we're still on the LoadingPage
      expect(find.byType(LoadingPage), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);
    });
    
    testWidgets('should handle widget disposal during timer', (WidgetTester tester) async {
      // Use a stateful wrapper to control the widget tree
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return const LoadingPage();
            },
          ),
        ),
      );
      
      // Verify LoadingPage is shown
      expect(find.byType(LoadingPage), findsOneWidget);
      
      // Replace the LoadingPage with a different widget before the timer completes
      // Using 1 second (half of the 2-second timer)
      await tester.pump(const Duration(seconds: 1));
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Text('Another Page')),
        ),
      );
      
      // Verify we're on the new page
      expect(find.text('Another Page'), findsOneWidget);
      
      // Wait for more than the timer duration
      await tester.pump(const Duration(seconds: 1, milliseconds: 100));
      
      // Verify we're still on the new page (no crashes)
      expect(find.text('Another Page'), findsOneWidget);
    });
  });
}
