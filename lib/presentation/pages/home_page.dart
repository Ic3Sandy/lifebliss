import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart'; // Required for loading assets
import 'dart:convert'; // Required for encoding

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // Enable JavaScript
      ..setBackgroundColor(const Color(0x00000000)) // Optional: Make background transparent
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Optional: Implement a loading indicator
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {
            // Optional: Handle loading errors
            debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
          },
          // Optional: Control navigation
          // onNavigationRequest: (NavigationRequest request) {
          //   if (request.url.startsWith('some_prefix_to_block')) {
          //     return NavigationDecision.prevent;
          //   }
          //   return NavigationDecision.navigate;
          // },
        ),
      );

    _loadHtmlFromAssets(); // Load the local HTML content
  }

  Future<void> _loadHtmlFromAssets() async {
    try {
      final String fileText = await rootBundle.loadString('assets/index.html');
      _controller.loadRequest(Uri.dataFromString(
        fileText,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8'),
      ));
    } catch (e) {
      debugPrint('Error loading HTML from assets: $e');
      // Optionally load fallback content or show an error message
      _controller.loadHtmlString('<html><body><h1>Error loading content</h1></body></html>');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
      ),
      body: Container(
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}
