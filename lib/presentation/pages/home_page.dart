import 'dart:async'; // Required for Timer
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
  bool _webViewInitialized = false;
  Timer? _initTimer;

  @override
  void dispose() {
    // Cancel any pending timers
    _initTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Initialize color service
    _colorService = widget.colorService ?? ColorService();

    // Initialize controller with safer configuration
    _initializeWebViewController();
  }

  void _initializeWebViewController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel(
        'flutter',
        onMessageReceived: (JavaScriptMessage message) {
          try {
            debugPrint('Message from JavaScript: ${message.message}');

            if (message.message == 'titleClicked') {
              debugPrint('Title click detected via JS channel!');
              _applyRandomBackgroundColor();
            } else if (message.message == 'channelTest') {
              debugPrint('Channel test message received');
            }
          } on Exception catch (e) {
            debugPrint('Error processing JavaScript message: $e');
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView loading progress: $progress%');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');

            if (!_webViewInitialized) {
              _webViewInitialized = true;

              // Verify JavaScript channel is working with safer execution
              _safeRunJavaScript('''
                console.log("Testing Flutter channel availability");
                if (window.flutter) {
                  console.log("Flutter channel is available");
                  try {
                    window.flutter.postMessage("channelTest");
                    console.log("Test message sent successfully");
                  } catch(e) {
                    console.error("Error sending test message: " + e);
                  }
                } else {
                  console.error("Flutter channel is NOT available - critical error");
                }
              ''');
            }
          },
          onWebResourceError: (WebResourceError error) {
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

    _loadHtmlFromAssets();
  }

  /// Safely run JavaScript with error handling
  Future<void> _safeRunJavaScript(String script) async {
    try {
      await _controller.runJavaScript(script);
    } on PlatformException catch (e) {
      debugPrint('Error executing JavaScript: $e');
    }
  }

  /// Apply a random background color using Flutter's ColorService
  Future<void> _applyRandomBackgroundColor() async {
    try {
      // Get random color from Flutter ColorService - no need to check for black
      // as that's handled in the ColorService now
      final String hexColor = _colorService.getRandomColorHex();
      debugPrint('Generated random color in Flutter: $hexColor');

      // Apply the color to the webpage background using proper JavaScript syntax
      await _safeRunJavaScript('document.body.style.backgroundColor = "$hexColor";');

      // Also change the title color for better visibility
      await _safeRunJavaScript('document.getElementById("app-title").style.color = "#FFFFFF";');

      // Force a repaint
      await _safeRunJavaScript('document.body.offsetHeight;');

      debugPrint('Applied background color: $hexColor');
    } on Exception catch (e) {
      debugPrint('Error applying random background color: $e');
    }
  }

  Future<void> _loadHtmlFromAssets() async {
    try {
      final String fileText = await rootBundle.loadString('assets/index.html');
      debugPrint('Loaded HTML from assets, length: ${fileText.length}');

      await _controller.loadRequest(Uri.dataFromString(
        fileText,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8'),
      ));

      // Add a delay to ensure the WebView is fully loaded
      _initTimer = Timer(const Duration(milliseconds: 1000), () {
        if (mounted) {
          // Test JavaScript execution and the DOM with safer execution
          _safeRunJavaScript('''
            console.log("WebView loaded - testing DOM access");
            const title = document.getElementById('app-title');
            if (title) {
              console.log("Title element found: " + title.innerText);
              
              // Add extra test click listener to verify DOM interaction
              title.addEventListener('click', function(e) {
                console.log("Direct click listener triggered");
                document.body.style.backgroundColor = "#FF5733";
                if (window.flutter) {
                  try {
                    window.flutter.postMessage("titleClicked");
                  } catch(err) {
                    console.error("Error sending click message:", err);
                  }
                }
                e.preventDefault();
              });
            } else {
              console.error("CRITICAL: app-title element not found in DOM");
            }
          ''');
        }
      });
    } on Exception catch (e) {
      debugPrint('Error loading HTML from assets: $e');
      // Provide a simpler fallback with minimal content
      await _controller.loadHtmlString(
        '<html><body style="display:flex;justify-content:center;align-items:center;'
        'height:100vh;"><h1>Error loading content</h1></body></html>',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Lifebliss'),
        actions: [
          // Add a button to directly test background color changing
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: () {
              debugPrint('Manual color change test');
              _applyRandomBackgroundColor();
            },
          ),
          // Add a refresh button for testing
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _webViewInitialized = false;
                _initializeWebViewController();
              });
              debugPrint('Refreshing WebView content');
            },
          ),
        ],
      ),
      body: WebViewWidget(
        controller: _controller,
      ),
    );
  }
}
