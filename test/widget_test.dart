import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifebliss_app/presentation/pages/loading_page.dart';
import 'package:lifebliss_app/presentation/pages/home_page.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter/webview_flutter.dart';
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

  group('MyApp', () {
    testWidgets('should display LoadingPage as home', (WidgetTester tester) async {
      // Override the LoadingPage to disable auto-navigation for testing
      await tester.pumpWidget(const MaterialApp(
        home: LoadingPage(navigateAfterDelay: false),
      ));

      // Verify that LoadingPage is shown
      expect(find.byType(LoadingPage), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('LoadingPage', () {
    testWidgets('should display loading indicator and text', (WidgetTester tester) async {
      // Build the LoadingPage widget
      await tester.pumpWidget(
        const MaterialApp(
          home: LoadingPage(navigateAfterDelay: false), // Disable auto-navigation for this test
        ),
      );

      // Verify that the loading indicator and text are displayed
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('should navigate to HomePage after delay', (WidgetTester tester) async {
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
      expect(find.byType(LoadingPage), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);

      // Wait for the navigation delay (slightly more than 2 seconds total)
      await tester.pump(const Duration(seconds: 1, milliseconds: 100));

      // Trigger the animation
      await tester.pumpAndSettle();

      // Verify that HomePage is now shown
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(LoadingPage), findsNothing);
    });
  });

  group('HomePage', () {
    testWidgets('should display WebViewWidget', (WidgetTester tester) async {
      // Build the HomePage widget
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );
      // Verify that the WebViewWidget is displayed (via the mock)
      expect(find.byType(WebViewWidget), findsOneWidget);
    });
  });
}
