import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  String id; // Firestore document ID
  String title;
  String description;
  DateTime dueDate;
  bool isCompleted;

  Todo({
    this.id = '',
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
  });

  // Toggle completion status
  Todo toggleComplete() => Todo(
    id: id,
    title: title,
    description: description,
    dueDate: dueDate,
    isCompleted: !isCompleted,
  );
  Todo copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Convert to Firestore JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'dueDate': dueDate,
    'isCompleted': isCompleted,
  };

  // Convert from Firestore JSON
  static Todo fromJson(Map<String, dynamic> json) => Todo(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    dueDate: (json['dueDate'] as Timestamp).toDate(),
    isCompleted: json['isCompleted'] ?? false,
  );
}
