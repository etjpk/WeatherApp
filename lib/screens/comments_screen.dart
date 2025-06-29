import 'package:application_journey/services/post_service.dart';
import 'package:application_journey/widgets/comment_item.dart'; // Add this import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CommentsScreen extends StatefulWidget {
  final String postId;
  const CommentsScreen({super.key, required this.postId});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final PostService _postService = PostService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Comments List
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(widget.postId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('Post not found'));
                }

                final postData = snapshot.data!.data() as Map<String, dynamic>;
                final comments = List<Map<String, dynamic>>.from(
                  postData['comments'] ?? [],
                );

                if (comments.isEmpty) {
                  return const Center(
                    child: Text('No comments yet. Be the first to comment!'),
                  );
                }

                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    return CommentItem(
                      comment: comments[index],
                    ); // Use CommentItem widget
                  },
                );
              },
            ),
          ),

          // Comment Input - SINGLE INPUT ONLY
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addComment,
                  icon: const Icon(Icons.send),
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Fetch user profile data from Firestore
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final userData = userDoc.data() ?? {};

    final comment = {
      'userId': user.uid,
      'userName': userData['name'] ?? 'Unknown User',
      'userUsername': userData['username'] ?? 'unknown',
      'userProfileImage': userData['profileImageUrl'] ?? '',
      'text': text,
      'timestamp': Timestamp.now(),
    };

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .update({
          'comments': FieldValue.arrayUnion([comment]),
        });

    _commentController.clear();
  }

  // Future<void> _addComment() async {
  //   final text = _commentController.text.trim();
  //   if (text.isEmpty) return;

  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user == null) return;

  //   // Debug: Print user info
  //   print('🔍 Current User UID: ${user.uid}');
  //   print('🔍 Current User Email: ${user.email}');

  //   try {
  //     final userDoc = await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(user.uid)
  //         .get();

  //     print('🔍 User document exists: ${userDoc.exists}');
  //     print('🔍 User document data: ${userDoc.data()}');

  //     final userData = userDoc.data() ?? {};

  //     final comment = {
  //       'userId': user.uid,
  //       'userName': userData['name'] ?? 'Unknown User',
  //       'userUsername': userData['username'] ?? 'unknown',
  //       'userProfileImage': userData['profileImageUrl'] ?? '',
  //       'text': text,
  //       'timestamp': Timestamp.now(),
  //     };

  //     await FirebaseFirestore.instance
  //         .collection('posts')
  //         .doc(widget.postId)
  //         .update({
  //           'comments': FieldValue.arrayUnion([comment]),
  //         });
  //     _commentController.clear();
  //   } catch (e) {
  //     print('❌ Error fetching user data: $e');
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('Failed to post comment: $e')));
  //   }
  // }

  // Future<void> _addComment() async {
  //   final text = _commentController.text.trim();
  //   if (text.isEmpty) return;

  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user == null) return;

  //   try {
  //     // Get current user's profile data from Firestore
  //     final userDoc = await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(user.uid)
  //         .get();

  //     final userData = userDoc.data() ?? {};

  //     final comment = {
  //       'text': text,
  //       'userId': user.uid,
  //       'userName': userData['name'] ?? 'Unknown User',
  //       'userUsername': userData['username'] ?? 'unknown',
  //       'userProfileImage': userData['profileImageUrl'] ?? '',
  //       'timestamp': Timestamp.now(),
  //     };

  //     await _postService.addComment(widget.postId, comment);
  //     _commentController.clear();
  //   } catch (e) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('Failed to post comment: $e')));
  //   }
  // }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
