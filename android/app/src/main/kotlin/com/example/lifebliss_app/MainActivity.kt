package com.example.lifebliss_app

import android.app.AlertDialog
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val TODO_CHANNEL = "com.lifebliss.app/todo"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, TODO_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "showTodoDialog" -> {
                    val title = call.argument<String>("title") ?: "Todo Item"
                    showNativeTodoDialog(title, result)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    private fun showNativeTodoDialog(title: String, result: MethodChannel.Result) {
        try {
            AlertDialog.Builder(this)
                .setTitle("Todo Details (Native)")
                .setMessage("You selected: $title")
                .setPositiveButton("OK") { dialog, _ ->
                    dialog.dismiss()
                    result.success(true)
                }
                .show()
        } catch (e: Exception) {
            result.error("NATIVE_ERROR", "Failed to show native dialog: ${e.message}", null)
        }
    }
}
