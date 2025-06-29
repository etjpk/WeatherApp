// models/post_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class BlogPost {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final Timestamp timestamp;
  final List<String> imageUrls; // For multiple images
  final List<String> likes;
  final List<Comment> comments;
  final bool isPublic;

  BlogPost({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.timestamp,
    this.imageUrls = const [],
    this.likes = const [],
    this.comments = const [],
    this.isPublic = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'authorId': authorId,
      'timestamp': timestamp,
      'imageUrls': imageUrls,
      'likes': likes,
      'comments': comments.map((c) => c.toMap()).toList(),
      'isPublic': isPublic,
    };
  }

  factory BlogPost.fromMap(Map<String, dynamic> map) {
    return BlogPost(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      authorId: map['authorId'],
      timestamp: map['timestamp'],
      imageUrls: List<String>.from(map['imageUrls']),
      likes: List<String>.from(map['likes']),
      comments: List<Comment>.from(
        map['comments']?.map((x) => Comment.fromMap(x)),
      ),
      isPublic: map['isPublic'],
    );
  }
}

class Comment {
  final String userId;
  final String text;
  final Timestamp timestamp;

  Comment({required this.userId, required this.text, required this.timestamp});

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'text': text,
    'timestamp': timestamp,
  };

  factory Comment.fromMap(Map<String, dynamic> map) => Comment(
    userId: map['userId'],
    text: map['text'],
    timestamp: map['timestamp'],
  );
}
