import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_platform_interface/src/types/types.dart' hide WebViewPlatform;

/// Mock class for WebViewPlatform to be used in tests
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
  PlatformNavigationDelegate createPlatformNavigationDelegate(
      PlatformNavigationDelegateCreationParams params) {
    return MockPlatformNavigationDelegate(params);
  }
}

/// Mock class for PlatformWebViewWidget to be used in tests
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

/// Mock class for PlatformWebViewController to be used in tests
class MockPlatformWebViewController extends PlatformWebViewController {
  MockPlatformWebViewController(super.params)
      : super.implementation();
      
  // Track resource loading for testing
  String? lastLoadedHtml;
  String? lastLoadedUrl;
  String? lastExecutedJavaScript;
  
  // Track javascript executions
  final List<String> executedJavaScripts = [];
  
  // Track added JavaScript channels
  final List<JavaScriptChannelParams> addedJavaScriptChannels = [];
  
  // Track navigation delegate
  PlatformNavigationDelegate? navigationDelegate;
  
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
  
  @override Future<void> setJavaScriptMode(JavaScriptMode mode) async { }
  @override Future<void> setBackgroundColor(Color color) async { }
  @override Future<void> loadFile(String absoluteFilePath) async { }
  @override Future<String?> currentUrl() async => lastLoadedUrl;
  @override Future<bool> canGoBack() async => false;
  @override Future<bool> canGoForward() async => false;
  @override Future<void> goBack() async { }
  @override Future<void> goForward() async { }
  @override Future<void> reload() async { }
  @override Future<void> clearCache() async { }
  @override Future<void> clearLocalStorage() async { }
  @override Future<void> removeJavaScriptChannel(String javaScriptChannelName) async { 
    addedJavaScriptChannels.removeWhere((channel) => channel.name == javaScriptChannelName);
  }
  @override Future<String?> getTitle() async => null;
  @override Future<void> scrollTo(int x, int y) async { }
  @override Future<void> scrollBy(int x, int y) async { }
  @override Future<Offset> getScrollPosition() async => Offset.zero;
  @override Future<void> enableZoom(bool enabled) async { }
  @override Future<void> setMediaPlaybackRequiresUserGesture(bool require) async { }
  @override Future<void> setUserAgent(String? userAgent) async { }
}

/// Mock class for PlatformNavigationDelegate to be used in tests
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