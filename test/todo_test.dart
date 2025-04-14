import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifebliss_app/domain/models/todo.dart';
import 'package:lifebliss_app/domain/services/todo_service.dart';
import 'package:lifebliss_app/presentation/widgets/todo_widget.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'todo_test.mocks.dart';

@GenerateMocks([TodoService])
void main() {
  group('Todo Model Tests', () {
    test('Todo should be created with correct values', () {
      final todo = Todo(id: '1', title: 'Test Todo');

      expect(todo.id, '1');
      expect(todo.title, 'Test Todo');
      expect(todo.isCompleted, false);
    });

    test('Todo copyWith creates a new instance with updated values', () {
      final todo = Todo(id: '1', title: 'Test Todo');
      final updatedTodo = todo.copyWith(isCompleted: true);

      expect(updatedTodo.id, '1');
      expect(updatedTodo.title, 'Test Todo');
      expect(updatedTodo.isCompleted, true);

      // Original should be unchanged
      expect(todo.isCompleted, false);
    });
  });

  group('TodoWidget Tests', () {
    testWidgets('TodoWidget displays correct title', (WidgetTester tester) async {
      const title = 'Test Todo';
      bool toggledValue = false;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TodoWidget(
            title: title,
            isCompleted: false,
            onToggleCompleted: (value) {
              toggledValue = value;
            },
            onTap: () {},
          ),
        ),
      ));

      expect(find.text(title), findsOneWidget);
    });

    testWidgets('TodoWidget toggles completion status', (WidgetTester tester) async {
      const title = 'Test Todo';
      bool toggledValue = false;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TodoWidget(
            title: title,
            isCompleted: false,
            onToggleCompleted: (value) {
              toggledValue = value;
            },
            onTap: () {},
          ),
        ),
      ));

      // Find and tap the checkbox
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      expect(toggledValue, true);
    });
  });

  group('TodoService Tests', () {
    late MockTodoService mockTodoService;

    setUp(() {
      mockTodoService = MockTodoService();
    });

    test('showNativeDialog calls native method', () async {
      when(mockTodoService.showNativeDialog('Test Todo')).thenAnswer((_) async => true);

      await mockTodoService.showNativeDialog('Test Todo');

      verify(mockTodoService.showNativeDialog('Test Todo')).called(1);
    });
  });
}
