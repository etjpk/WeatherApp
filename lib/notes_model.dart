import 'package:cloud_firestore/cloud_firestore.dart';

enum NoteCategory { handwritten, defaultNotebook, recentlyAdded, important }

class Note {
  String id; // Firestore document ID
  String title;
  String content;
  NoteCategory category;
  DateTime creationDate;
  DateTime? lastModifiedDate;

  Note({
    this.id = '',
    required this.title,
    required this.content,
    required this.category,
    required this.creationDate,
    this.lastModifiedDate,
  });

  Note copyWith({
    String? id,
    String? title,
    String? content,
    NoteCategory? category,
    DateTime? creationDate,
    DateTime? lastModifiedDate,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      creationDate: creationDate ?? this.creationDate,
      lastModifiedDate: lastModifiedDate ?? this.lastModifiedDate,
    );
  }

  // Convert to Firestore JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'category': _categoryToString(category),
    'creationDate': creationDate,
    'lastModifiedDate': lastModifiedDate,
  };

  // Convert from Firestore JSON
  static Note fromJson(Map<String, dynamic> json) => Note(
    id: json['id'],
    title: json['title'],
    content: json['content'],
    category: _stringToCategory(json['category']),
    creationDate: (json['creationDate'] as Timestamp).toDate(),
    lastModifiedDate: json['lastModifiedDate'] != null
        ? (json['lastModifiedDate'] as Timestamp).toDate()
        : null,
  );

  // Helper: Convert enum to string for Firestore
  static String _categoryToString(NoteCategory category) {
    switch (category) {
      case NoteCategory.handwritten:
        return 'handwritten';
      case NoteCategory.defaultNotebook:
        return 'default';
      case NoteCategory.recentlyAdded:
        return 'recent';
      case NoteCategory.important:
        return 'important';
      // default:
      // return 'default';
    }
  }

  // Helper: Convert string to enum from Firestore
  static NoteCategory _stringToCategory(String category) {
    switch (category) {
      case 'handwritten':
        return NoteCategory.handwritten;
      case 'recent':
        return NoteCategory.recentlyAdded;
      case 'important':
        return NoteCategory.important;
      default:
        return NoteCategory.defaultNotebook;
    }
  }
}
