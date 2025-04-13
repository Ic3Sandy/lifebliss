import 'dart:convert'; // Required for encoding

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for loading assets
import 'package:lifebliss_app/domain/services/color_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomePage extends StatefulWidget {
  final ColorService? colorService;

  const HomePage({super.key, this.colorService});

  @override
  State<HomePage> createState() => _HomePageState();

  /// Static method for testing
  static void testColorService(ColorService colorService) {
    colorService.getRandomColorHex();
  }
}

class _HomePageState extends State<HomePage> {
  late final WebViewController _controller;
  late final ColorService _colorService;

  @override
  void initState() {
    super.initState();

    // Initialize color service
    _colorService = widget.colorService ?? ColorService();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // Enable JavaScript
      ..setBackgroundColor(
        const Color(0x00000000),
      ) // Make background transparent
      ..addJavaScriptChannel(
        'flutter',
        onMessageReceived: (JavaScriptMessage message) {
          debugPrint('Message from JavaScript: ${message.message}');

          // When title is clicked, generate a random color in Flutter
          if (message.message == 'titleClicked') {
            _applyRandomBackgroundColor();
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Optional: Implement a loading indicator
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            debugPrint('Page finished loading');

            // Verify JavaScript channel is working
            _controller.runJavaScript('''
              console.log("Testing Flutter channel availability");
              if (window.flutter) {
                console.log("Flutter channel is available");
              } else {
                console.log("Flutter channel is NOT available");
              }
            ''');
          },
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
        ),
      );

    _loadHtmlFromAssets(); // Load the local HTML content
  }

  /// Apply a random background color using Flutter's ColorService
  Future<void> _applyRandomBackgroundColor() async {
    // Get random color from Flutter ColorService
    final String hexColor = _colorService.getRandomColorHex();
    debugPrint('Generated random color in Flutter: $hexColor');

    // Apply the color to the webpage background
    await _controller.runJavaScript(
      'document.body.style.backgroundColor = "$hexColor";',
    );
  }

  Future<void> _loadHtmlFromAssets() async {
    try {
      final String fileText = await rootBundle.loadString('assets/index.html');
      await _controller.loadRequest(Uri.dataFromString(
        fileText,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8'),
      ));
    } on Exception catch (e) {
      debugPrint('Error loading HTML from assets: $e');
      // Optionally load fallback content or show an error message
      await _controller.loadHtmlString(
        '<html><body><h1>Error loading content</h1></body></html>',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
      ),
      body: WebViewWidget(
        controller: _controller,
      ),
    );
  }
}
