/// A model representing a todo item
class Todo {
  /// Unique identifier for the todo
  final String id;

  /// The title or description of the todo
  final String title;

  /// Whether the todo is completed
  final bool isCompleted;

  /// Creates a new [Todo]
  const Todo({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  /// Creates a copy of this todo with the given fields replaced with new values
  Todo copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
