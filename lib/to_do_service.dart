import 'package:cloud_firestore/cloud_firestore.dart';
import 'todo_model.dart';

class TodoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new to-do
  Future<void> createTodo(Todo todo) async {
    final docRef = _firestore.collection('todos').doc();
    await docRef.set(todo.copyWith(id: docRef.id).toJson());
  }

  // Get real-time stream of all to-dos
  Stream<List<Todo>> getTodosStream() {
    return _firestore
        .collection('todos')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Todo.fromJson(doc.data())).toList(),
        );
  }

  // Toggle completion status
  Future<void> toggleTodoCompletion(String todoId, bool currentStatus) async {
    await _firestore.collection('todos').doc(todoId).update({
      'isCompleted': !currentStatus,
    });
  }

  // Update specific fields of a to-do (e.g., description, due date)
  Future<void> updateTodo(String todoId, Map<String, dynamic> updates) async {
    await _firestore.collection('todos').doc(todoId).update(updates);
  }

  // Delete a to-do
  Future<void> deleteTodo(String todoId) async {
    await _firestore.collection('todos').doc(todoId).delete();
  }

  // Get completed to-dos (real-time stream)
  Stream<List<Todo>> getCompletedTodos() {
    return _firestore
        .collection('todos')
        .where('isCompleted', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Todo.fromJson(doc.data())).toList(),
        );
  }

  // Get to-dos due on a specific date (real-time stream)
  Stream<List<Todo>> getTodosByDueDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _firestore
        .collection('todos')
        .where('dueDate', isGreaterThanOrEqualTo: startOfDay)
        .where('dueDate', isLessThanOrEqualTo: endOfDay)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Todo.fromJson(doc.data())).toList(),
        );
  }
}
