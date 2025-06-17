import 'package:application_journey/edit_todo_page.dart';
import 'package:flutter/material.dart';
import 'todo_model.dart';
import 'to_do_service.dart';
import 'create_todo_page.dart';

class TodosPage extends StatelessWidget {
  const TodosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TodoService _todoService = TodoService();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Expanded(child: Divider(thickness: 0.5, color: Colors.grey)),
            const Text(
              'To-Do List',
              style: TextStyle(
                color: Color.fromARGB(255, 241, 200, 214),
                fontStyle: FontStyle.normal,
                fontSize: 30,
              ),
            ),
            Expanded(child: Divider(thickness: 0.5, color: Colors.grey)),
          ],
        ),
      ),
      body: StreamBuilder<List<Todo>>(
        stream: _todoService.getTodosStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading to-dos'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No to-dos yet'));
          }
          final todos = snapshot.data!;
          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index];
              return ListTile(
                title: Text(todo.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(todo.description),
                    Text('Due: ${todo.dueDate.toString().split(' ')[0]}'),
                  ],
                ),
                trailing: SizedBox(
                  width: 100, // Fixed width to prevent layout shifts
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildStatusIcon(todo), // Extracted widget for clarity
                      PopupMenuButton<String>(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ],
                        onSelected: (value) async {
                          if (value == 'edit') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditTodoPage(todo: todo),
                              ),
                            );
                          } else if (value == 'delete') {
                            await TodoService().deleteTodo(todo.id);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateTodoPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Extracted method to handle status icon logic
  Widget _buildStatusIcon(Todo todo) {
    final now = DateTime.now();
    final dueDate = DateTime(
      todo.dueDate.year,
      todo.dueDate.month,
      todo.dueDate.day,
    );
    final startOfDueDate = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
      0,
      0,
      0,
    );
    final endOfDueDate = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
      23,
      59,
      59,
    );

    if (todo.isCompleted) {
      return const Icon(Icons.check, color: Colors.green, size: 24);
    } else if (now.isAfter(endOfDueDate)) {
      return const Icon(Icons.close, color: Colors.red, size: 24);
    } else if (now.isBefore(startOfDueDate)) {
      return const Checkbox(value: false, onChanged: null);
    } else {
      return Checkbox(
        value: todo.isCompleted,
        onChanged: (value) {
          if (value == true) {
            TodoService().toggleTodoCompletion(todo.id, todo.isCompleted);
          }
        },
      );
    }
  }
}
