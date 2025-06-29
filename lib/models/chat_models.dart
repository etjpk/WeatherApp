import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a single chat message between two users.
class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final Timestamp timestamp;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      message: data['message'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
      'isRead': isRead,
    };
  }
}

class Conversation {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final Timestamp lastMessageTime;
  final Map<String, dynamic> participantData;

  Conversation({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.participantData,
  });
}
