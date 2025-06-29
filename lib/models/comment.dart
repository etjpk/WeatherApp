import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String text;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final Timestamp timestamp;

  Comment({
    required this.text,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.timestamp,
  });

  // Convert a Firestore map to a Comment object
  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      text: map['text'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      authorAvatar: map['authorAvatar'] ?? '',
      timestamp: map['timestamp'] ?? Timestamp.now(),
    );
  }

  // Convert a Comment object to a Firestore map
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'timestamp': timestamp,
    };
  }
}
