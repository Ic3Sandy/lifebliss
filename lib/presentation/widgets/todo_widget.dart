import 'package:flutter/material.dart';

/// A widget that displays a Todo item
class TodoWidget extends StatelessWidget {
  /// The title of the todo
  final String title;

  /// Whether the todo is completed
  final bool isCompleted;

  /// Callback when the todo completion status is toggled
  final Function(bool) onToggleCompleted;

  /// Callback when the todo item is tapped
  final VoidCallback onTap;

  /// Creates a new [TodoWidget]
  const TodoWidget({
    super.key,
    required this.title,
    required this.isCompleted,
    required this.onToggleCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: Checkbox(
          value: isCompleted,
          onChanged: (value) {
            if (value != null) {
              onToggleCompleted(value);
            }
          },
        ),
        title: Text(
          title,
          style: TextStyle(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? Colors.grey : Colors.black,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
