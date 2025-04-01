import 'package:flutter/material.dart';
import 'dart:async';
import 'home_page.dart';

/// A loading page that automatically navigates to the home page after a delay
class LoadingPage extends StatefulWidget {
  /// The duration to wait before navigating to the home page
  static const Duration navigationDelay = Duration(seconds: 2);
  
  /// Creates a new [LoadingPage]
  /// 
  /// If [navigateAfterDelay] is true, the page will automatically navigate
  /// to the home page after [navigationDelay].
  const LoadingPage({super.key, this.navigateAfterDelay = true});

  /// Whether to automatically navigate to the home page after a delay
  final bool navigateAfterDelay;

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  Timer? _navigationTimer;
  
  @override
  void initState() {
    super.initState();
    
    // Only navigate automatically if the flag is true
    if (widget.navigateAfterDelay) {
      _scheduleNavigation();
    }
  }
  
  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }
  
  /// Schedules navigation to the home page after the delay
  void _scheduleNavigation() {
    _navigationTimer = Timer(LoadingPage.navigationDelay, () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.lightBlueAccent],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Colors.white,
              ),
              SizedBox(height: 20),
              Text(
                'Loading...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
