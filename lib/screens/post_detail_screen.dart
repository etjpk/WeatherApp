import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:application_journey/services/post_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'dart:convert';

class PostDetailScreen extends StatelessWidget {
  final String postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.black, // Set background to black
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Post Details', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .doc(postId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return SizedBox();
              final post = snapshot.data!.data() as Map<String, dynamic>?;
              if (post == null || post['authorId'] != currentUserId)
                return SizedBox();
              return IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDelete(context, postId),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          final postData = snapshot.data!.data() as Map<String, dynamic>?;
          if (postData == null) {
            return Center(
              child: Text(
                'Post not found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title at top
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    postData['title'] ?? 'Untitled',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Images grid (if images exist)
                if (postData['imageUrls'] != null &&
                    postData['imageUrls'].isNotEmpty)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                      ),
                      itemCount: postData['imageUrls'].length,
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: postData['imageUrls'][index],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[800],
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[800],
                              child: Icon(Icons.error, color: Colors.white),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                // Content (render as Quill if not empty)
                if ((postData['content'] ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildQuillContent(postData['content']),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Renders Quill Delta content properly, just like on Explore page
  Widget _buildQuillContent(String contentJson) {
    try {
      // Parse the Quill Delta JSON and create a document
      final doc = Document.fromJson(jsonDecode(contentJson));
      final controller = QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );

      // Return QuillEditor in read-only mode
      return QuillEditor.basic(controller: controller);
    } catch (e) {
      // Fallback to plain text if parsing fails
      print('Error parsing Quill content: $e');
      return Text(
        contentJson,
        style: TextStyle(fontSize: 16, color: Colors.white),
      );
    }
  }

  void _confirmDelete(BuildContext context, String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Delete Post', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete this post?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await PostService().deletePost(postId);
                Navigator.pop(context); // Go back to profile
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Post deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete post: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
