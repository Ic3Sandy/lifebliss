import 'package:flutter/services.dart';
import 'dart:developer' as developer;

/// Service responsible for handling Todo-related operations including native calls
class TodoService {
  /// Method channel for communicating with native code
  static const MethodChannel _channel = MethodChannel('com.lifebliss.app/todo');

  /// Shows a native dialog with the provided todo title
  Future<void> showNativeDialog(String todoTitle) async {
    try {
      await _channel.invokeMethod('showTodoDialog', {'title': todoTitle});
      developer.log('Native dialog shown for todo: $todoTitle');
    } on PlatformException catch (e) {
      developer.log('Error showing native dialog: ${e.message}');
      // Rethrow to allow for proper error handling upstream
      rethrow;
    }
  }
}
