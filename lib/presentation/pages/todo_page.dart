import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lifebliss_app/domain/models/todo.dart';
import 'package:lifebliss_app/domain/services/todo_service.dart';
import 'package:lifebliss_app/presentation/widgets/todo_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// A page that displays a list of todos and can interact with JavaScript and native code
class TodoPage extends StatefulWidget {
  /// Creates a new [TodoPage]
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  late final WebViewController _controller;
  late final TodoService _todoService;
  final List<Todo> _todos = [];
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _todoService = TodoService();
    _initializeWebViewController();
    _loadSampleTodos();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // Sample todos for testing
  void _loadSampleTodos() {
    _todos.addAll([
      Todo(id: '1', title: 'Learn Flutter'),
      Todo(id: '2', title: 'Build Todo App'),
      Todo(id: '3', title: 'Test JavaScript bridge', isCompleted: true),
    ]);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _initializeWebViewController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel(
        'flutter_todo',
        onMessageReceived: (JavaScriptMessage message) {
          _handleJavaScriptMessage(message.message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            developer.log('Todo WebView page finished loading');
            _initializeJavaScriptTodo();
          },
        ),
      );

    _loadHtmlFromString();
  }

  Future<void> _loadHtmlFromString() async {
    const String htmlContent = '''
      <!DOCTYPE html>
      <html>
      <head>
        <title>Todo Web Interface</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body {
            font-family: Arial, sans-serif;
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 20px;
            background-color: #f8f8f8;
          }
          button {
            background-color: #4CAF50;
            border: none;
            color: white;
            padding: 10px 20px;
            text-align: center;
            text-decoration: none;
            display: inline-block;
            font-size: 16px;
            margin: 10px 2px;
            cursor: pointer;
            border-radius: 4px;
          }
          .todo-container {
            width: 100%;
            max-width: 500px;
            margin-top: 20px;
            background-color: white;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
          }
        </style>
      </head>
      <body>
        <div class="todo-container">
          <h2>Web Todo Interface</h2>
          <p>Click the button below to create a sample todo:</p>
          <button id="create-todo-btn">Create Sample Todo</button>
          <div id="result"></div>
        </div>
        <script>
          document.getElementById('create-todo-btn').addEventListener('click', function() {
            const result = document.getElementById('result');
            result.innerHTML = "Creating todo...";
            
            try {
              // Call Flutter with a new todo request
              if (window.flutter_todo) {
                window.flutter_todo.postMessage(JSON.stringify({
                  action: 'createTodo',
                  todo: {
                    title: 'Todo from JavaScript - ' + new Date().toLocaleTimeString()
                  }
                }));
                result.innerHTML = "Todo request sent to Flutter!";
              } else {
                result.innerHTML = "Error: Flutter bridge not available";
              }
            } catch (e) {
              result.innerHTML = "Error: " + e.message;
            }
          });
          
          // Function that Flutter can call
          function updateTodoStatus(id, completed) {
            const result = document.getElementById('result');
            result.innerHTML = `Todo #\${id} updated to: \${completed ? 'Completed' : 'Active'}`;
            return true;
          }
        </script>
      </body>
      </html>
    ''';

    await _controller.loadHtmlString(htmlContent);
  }

  void _initializeJavaScriptTodo() {
    // Test JavaScript interaction
    _safeRunJavaScript('''
      console.log("Todo WebView initialized");
      if (document.getElementById('create-todo-btn')) {
        console.log("Todo button found in DOM");
      } else {
        console.error("Todo button not found in DOM");
      }
    ''');
  }

  /// Safely run JavaScript with error handling
  Future<void> _safeRunJavaScript(String script) async {
    try {
      await _controller.runJavaScript(script);
    } catch (e) {
      developer.log('Error executing JavaScript: $e');
    }
  }

  void _handleJavaScriptMessage(String message) {
    try {
      final data = jsonDecode(message);
      developer.log('Received message from JavaScript: $data');

      if (data is Map && data['action'] == 'createTodo') {
        final todoData = data['todo'];
        if (todoData is Map && todoData['title'] is String) {
          _addTodo(todoData['title'] as String);
        }
      }
    } catch (e) {
      developer.log('Error handling JavaScript message: $e');
    }
  }

  void _addTodo(String title) {
    if (title.isEmpty) return;

    final newTodo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
    );

    setState(() {
      _todos.add(newTodo);
      _textController.clear();
    });
  }

  void _toggleTodoCompleted(String id, bool isCompleted) {
    setState(() {
      final index = _todos.indexWhere((todo) => todo.id == id);
      if (index != -1) {
        _todos[index] = _todos[index].copyWith(isCompleted: isCompleted);

        // Notify JavaScript of the status change
        _safeRunJavaScript(
          'updateTodoStatus("$id", $isCompleted);',
        );
      }
    });
  }

  void _showNativeDialog(Todo todo) async {
    try {
      await _todoService.showNativeDialog(todo.title);
    } catch (e) {
      // If native dialog fails, show Flutter dialog as fallback
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Todo Details'),
            content: Text(todo.title),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  flex: 3,
                  child: ListView.builder(
                    itemCount: _todos.length,
                    itemBuilder: (context, index) {
                      final todo = _todos[index];
                      return TodoWidget(
                        title: todo.title,
                        isCompleted: todo.isCompleted,
                        onToggleCompleted: (value) {
                          _toggleTodoCompleted(todo.id, value);
                        },
                        onTap: () => _showNativeDialog(todo),
                      );
                    },
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: WebViewWidget(controller: _controller),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Add Todo'),
              content: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: 'Enter todo title',
                ),
                autofocus: true,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (_textController.text.isNotEmpty) {
                      _addTodo(_textController.text);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
