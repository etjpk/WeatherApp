import 'package:cloud_firestore/cloud_firestore.dart';

class BlogPost {
  final String id;
  final String title;
  final String content; // JSON string from flutter_quill
  final String authorId;
  final String authorName;
  final String authorUsername;
  final String authorAvatar;
  final Timestamp timestamp;
  final List<String> imageUrls;
  final List<String> likes; // List of user IDs who liked
  final String visibility;
  final List<dynamic> comments;
  final bool isPublic;

  BlogPost({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.authorUsername,
    required this.authorAvatar,
    required this.timestamp,
    this.imageUrls = const [],
    // this.likes = const [],
    required this.likes,
    this.isPublic = true,
    required this.comments,
    required this.visibility,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'authorUsername': authorUsername,
      'authorAvatar': authorAvatar,
      'timestamp': timestamp,
      'imageUrls': imageUrls,
      'likes': likes,
      'isPublic': isPublic,
      'visibility': visibility,
    };
  }

  // Create from Firestore document
  factory BlogPost.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BlogPost(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Unknown',
      authorUsername: data['authorUsername'] ?? 'unknown',
      authorAvatar: data['authorAvatar'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      likes: List<String>.from(data['likes'] ?? []),
      // likes: List<String>.from(data['likes'] ?? []),
      comments: data['comments'] ?? [],
      // isPublic: data['isPublic'] ?? true,
      visibility: data['visibility'] ?? 'public',
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
