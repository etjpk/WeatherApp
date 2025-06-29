import 'package:application_journey/models/chat_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get conversation ID between two users
  String _getConversationId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    return ids.join('_');
  }

  // Send a message
  Future<void> sendMessage(String receiverId, String message) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final conversationId = _getConversationId(currentUser.uid, receiverId);

    // Create message
    final chatMessage = ChatMessage(
      id: '',
      senderId: currentUser.uid,
      receiverId: receiverId,
      message: message,
      timestamp: Timestamp.now(),
    );

    // Add message to messages subcollection
    await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .add(chatMessage.toMap());

    // Update conversation document
    await _firestore.collection('conversations').doc(conversationId).set({
      'participants': [currentUser.uid, receiverId],
      'lastMessage': message,
      'lastMessageTime': Timestamp.now(),
      'lastSenderId': currentUser.uid,
    }, SetOptions(merge: true));

    // Send notification
    await _sendMessageNotification(receiverId, message);
  }

  // Get messages stream
  Stream<List<ChatMessage>> getMessages(String receiverId) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);

    final conversationId = _getConversationId(currentUser.uid, receiverId);

    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ChatMessage.fromFirestore(doc))
              .toList();
        });
  }

  // Get user conversations
  Stream<List<Map<String, dynamic>>> getUserConversations() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection('conversations')
        .where('participants', arrayContains: currentUser.uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          List<Map<String, dynamic>> conversations = [];

          for (var doc in snapshot.docs) {
            final data = doc.data();
            final participants = List<String>.from(data['participants']);
            final otherUserId = participants.firstWhere(
              (id) => id != currentUser.uid,
            );

            // Get other user's data
            final userDoc = await _firestore
                .collection('users')
                .doc(otherUserId)
                .get();
            final userData = userDoc.data() ?? {};

            conversations.add({
              'id': doc.id,
              'otherUserId': otherUserId,
              'otherUserName': userData['name'] ?? 'Unknown',
              'otherUserAvatar': userData['profileImageUrl'] ?? '',
              'lastMessage': data['lastMessage'] ?? '',
              'lastMessageTime': data['lastMessageTime'],
              'lastSenderId': data['lastSenderId'] ?? '',
            });
          }

          return conversations;
        });
  }

  // Send message notification
  Future<void> _sendMessageNotification(
    String receiverId,
    String message,
  ) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final senderDoc = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .get();
    final senderName = senderDoc.data()?['name'] ?? 'Someone';

    await _firestore.collection('notifications').add({
      'userId': receiverId,
      'type': 'message',
      'title': 'New Message',
      'body': '$senderName sent you a message',
      'data': {
        'senderId': currentUser.uid,
        'senderName': senderName,
        'message': message,
      },
      'timestamp': Timestamp.now(),
      'isRead': false,
    });
  }
}
