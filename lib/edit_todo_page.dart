import 'package:flutter/material.dart';
import 'todo_model.dart';
import 'to_do_service.dart';

class EditTodoPage extends StatefulWidget {
  final Todo todo;

  const EditTodoPage({super.key, required this.todo});

  @override
  State<EditTodoPage> createState() => _EditTodoPageState();
}

class _EditTodoPageState extends State<EditTodoPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late DateTime _dueDate;
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo.title);
    _descriptionController = TextEditingController(
      text: widget.todo.description,
    );
    _dueDate = widget.todo.dueDate;
    _isCompleted = widget.todo.isCompleted;
  }

  Future<void> _pickDueDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 10),
    );
    if (pickedDate != null) {
      setState(() => _dueDate = pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit To-Do'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              final updatedTodo = widget.todo.copyWith(
                title: _titleController.text,
                description: _descriptionController.text,
                dueDate: _dueDate,
                isCompleted: _isCompleted,
              );
              await TodoService().updateTodo(
                widget.todo.id,
                updatedTodo.toJson(),
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Due: ${_dueDate.toString().split(' ')[0]}'),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _pickDueDate,
                  child: const Text('Change Date'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Completed:'),
                Checkbox(
                  value: _isCompleted,
                  onChanged: (value) =>
                      setState(() => _isCompleted = value ?? false),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
