import 'package:flutter/material.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

/// Sets up the mock WebView platform for testing
void setupMockWebViewPlatform() {
  final mockPlatform = MockWebViewPlatform();
  WebViewPlatform.instance = mockPlatform;
}

//------------------------------------------------------------------------------
// Mock WebView Controllers
//------------------------------------------------------------------------------

/// Mock implementation of WebViewPlatform for testing
class MockWebViewPlatform extends WebViewPlatform {
  // Track the last created controller for easier access in tests
  static PlatformWebViewController? lastCreatedController;

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
    final controller = MockPlatformWebViewController(params);
    lastCreatedController = controller;
    return controller;
  }

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(PlatformNavigationDelegateCreationParams params) {
    return MockPlatformNavigationDelegate(params);
  }
}

/// Mock implementation of PlatformWebViewWidget for testing
class MockPlatformWebViewWidget extends PlatformWebViewWidget {
  MockPlatformWebViewWidget(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      key: ValueKey('MockPlatformWebViewWidget'),
      width: 100,
      height: 100,
    );
  }
}

/// Mock implementation of PlatformWebViewController for testing
class MockPlatformWebViewController extends PlatformWebViewController {
  MockPlatformWebViewController(super.params) : super.implementation();

  // Tracking properties for testing
  String? lastLoadedHtml;
  String? lastLoadedUrl;
  String? lastExecutedJavaScript;
  final List<String> executedJavaScripts = [];
  final List<JavaScriptChannelParams> addedJavaScriptChannels = [];
  PlatformNavigationDelegate? navigationDelegate;

  //----------------------------------------------------------------------------
  // Implemented methods
  //----------------------------------------------------------------------------

  @override
  Future<void> loadRequest(LoadRequestParams params) async {
    if (params.uri.scheme == 'data') {
      lastLoadedHtml = Uri.decodeComponent(params.uri.toString().split(',')[1]);
    } else {
      lastLoadedUrl = params.uri.toString();
    }
  }

  @override
  Future<void> loadHtmlString(String html, {String? baseUrl}) async {
    lastLoadedHtml = html;
  }

  @override
  Future<void> runJavaScript(String javaScript) async {
    lastExecutedJavaScript = javaScript;
    executedJavaScripts.add(javaScript);
  }

  @override
  Future<Object> runJavaScriptReturningResult(String javaScript) async {
    lastExecutedJavaScript = javaScript;
    executedJavaScripts.add(javaScript);

    // Simple mock implementation to return a boolean for document.getElementById check
    if (javaScript.contains('document.getElementById')) {
      return true;
    }

    return Object();
  }

  @override
  Future<void> addJavaScriptChannel(JavaScriptChannelParams javaScriptChannelParams) async {
    addedJavaScriptChannels.add(javaScriptChannelParams);
  }

  @override
  Future<void> setPlatformNavigationDelegate(PlatformNavigationDelegate handler) async {
    navigationDelegate = handler;
  }

  @override
  Future<void> removeJavaScriptChannel(String javaScriptChannelName) async {
    addedJavaScriptChannels.removeWhere((channel) => channel.name == javaScriptChannelName);
  }

  //----------------------------------------------------------------------------
  // Stub implementations (return default values)
  //----------------------------------------------------------------------------

  @override
  Future<void> setJavaScriptMode(JavaScriptMode mode) async {}
  @override
  Future<void> setBackgroundColor(Color color) async {}
  @override
  Future<void> loadFile(String absoluteFilePath) async {}
  @override
  Future<String?> currentUrl() async => lastLoadedUrl;
  @override
  Future<bool> canGoBack() async => false;
  @override
  Future<bool> canGoForward() async => false;
  @override
  Future<void> goBack() async {}
  @override
  Future<void> goForward() async {}
  @override
  Future<void> reload() async {}
  @override
  Future<void> clearCache() async {}
  @override
  Future<void> clearLocalStorage() async {}
  @override
  Future<String?> getTitle() async => null;
  @override
  Future<void> scrollTo(int x, int y) async {}
  @override
  Future<void> scrollBy(int x, int y) async {}
  @override
  Future<Offset> getScrollPosition() async => Offset.zero;
  @override
  Future<void> enableZoom(bool enabled) async {}
  Future<void> setMediaPlaybackRequiresUserGesture(bool require) async {}
  @override
  Future<void> setUserAgent(String? userAgent) async {}
}

/// Mock implementation of PlatformNavigationDelegate for testing
class MockPlatformNavigationDelegate extends PlatformNavigationDelegate {
  MockPlatformNavigationDelegate(super.params) : super.implementation();

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
