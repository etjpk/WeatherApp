import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:application_journey/models/blog_post.dart';
import 'package:application_journey/secrets.dart';

class PostsResult {
  final List<BlogPost> posts;
  final DocumentSnapshot? lastVisible;

  PostsResult({required this.posts, this.lastVisible});
}

class PostService {
  static final PostService _instance = PostService._internal();
  factory PostService() => _instance;

  PostService._internal() : _firestore = FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;
  final uri = Uri.parse('https://api.imgbb.com/1/upload?key=$imgbbApiKey');

  Future<void> createPost({
    required String title,
    required String content,
    required String authorId,
    required String authorName,
    required String authorUsername,
    required String authorAvatar,
    required List<File> imageFiles,
    required String visibility,
    bool isPublic = true,
  }) async {
    try {
      // 1. Upload images to ImgBB
      List<String> imageUrls = [];
      if (imageFiles.isNotEmpty) {
        imageUrls = await _uploadToImgBB(imageFiles);
      }

      // 2. Get current user info (you'll need to fetch this)
      final userDoc = await _firestore.collection('users').doc(authorId).get();
      // STEP 1B: Handle missing user document
      if (!userDoc.exists) {
        throw Exception('User document not found for ID: $authorId');
      }
      final userData = userDoc.data() ?? {};

      // 3. Create post data with complete author info
      final postData = {
        'title': title,
        'content': content,
        'authorId': authorId,
        'authorName': userData['name'] ?? 'Unknown',
        'authorUsername': userData['username'] ?? 'unknown',
        'authorAvatar': userData['profileImageUrl'] ?? '',

        'timestamp': Timestamp.now(),
        'imageUrls': imageUrls,
        'likes': [],
        'comments': [],
        'isPublic': isPublic,
        'visibility': visibility,
      };

      // 4. Save to Firestore
      final docRef = _firestore.collection('posts').doc();
      await docRef.set(postData);
    } catch (e) {
      print("Error creating post: $e");
      rethrow;
    }
  }

  // Add this method to your PostService class
  Future<void> toggleFollow({
    required String currentUserId,
    required String targetUserId,
  }) async {
    final currentUserRef = _firestore.collection('users').doc(currentUserId);
    final targetUserRef = _firestore.collection('users').doc(targetUserId);

    // Check current follow status
    final currentUserDoc = await currentUserRef.get();
    final followingList = List<String>.from(
      currentUserDoc.data()?['following'] ?? [],
    );
    final isFollowing = followingList.contains(targetUserId);

    final batch = _firestore.batch();

    if (isFollowing) {
      // Unfollow
      batch.update(currentUserRef, {
        'following': FieldValue.arrayRemove([targetUserId]),
      });
      batch.update(targetUserRef, {
        'followers': FieldValue.arrayRemove([currentUserId]),
      });
    } else {
      // Follow
      batch.update(currentUserRef, {
        'following': FieldValue.arrayUnion([targetUserId]),
      });
      batch.update(targetUserRef, {
        'followers': FieldValue.arrayUnion([currentUserId]),
      });
    }

    await batch.commit();
  }

  Future<List<String>> _uploadToImgBB(List<File> images) async {
    final List<String> urls = [];
    for (final image in images) {
      final uri = Uri.parse('https://api.imgbb.com/1/upload?key=$imgbbApiKey');
      final request = http.MultipartRequest('POST', uri)
        ..files.add(
          await http.MultipartFile.fromBytes(
            'image',
            await image.readAsBytes(),
            filename: 'post_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        );

      final response = await request.send();
      if (response.statusCode == 200) {
        final json = jsonDecode(await response.stream.bytesToString());
        urls.add(json['data']['url'] as String);
      } else {
        throw Exception('Image upload failed');
      }
    }
    return urls;
  }

  //3. Get all public posts (for Explore feed)
  Future<PostsResult> getPublicPosts({DocumentSnapshot? lastDocument}) async {
    const pageSize = 10;
    Query query = _firestore
        .collection('posts')
        .where('visibility', isEqualTo: 'public')
        // .where('isPublic', isEqualTo: true)
        .orderBy('timestamp', descending: true)
        .limit(pageSize);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();
    final posts = snapshot.docs
        .map((doc) => BlogPost.fromFirestore(doc))
        .toList();

    return PostsResult(
      posts: posts,
      lastVisible: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
    );
  }

  // 4. Get posts from followed users (for Following feed)
  Stream<List<BlogPost>> getFollowingPosts(
    List<String> followingUserIds,
    String currentUserId,
  ) {
    final allUserIds = [...followingUserIds, currentUserId];
    if (followingUserIds.isEmpty) return Stream.value([]);

    return _firestore
        .collection('posts')
        .where('authorId', whereIn: followingUserIds)
        .where('visibility', whereIn: ['public', 'following'])
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              //
              // .map((doc) => BlogPost.fromMap(doc.data()))
              .map((doc) => BlogPost.fromFirestore(doc))
              .toList();
        });
  }

  // 5. Delete a post
  Future<void> deletePost(String postId) async {
    await _firestore.collection('posts').doc(postId).delete();
  }

  // 6. Toggle like on post
  Future<void> toggleLike(String postId, String userId) async {
    final postRef = _firestore.collection('posts').doc(postId);

    await _firestore.runTransaction((transaction) async {
      final postDoc = await transaction.get(postRef);
      final currentLikes = List<String>.from(postDoc['likes'] ?? []);

      if (currentLikes.contains(userId)) {
        currentLikes.remove(userId);
      } else {
        currentLikes.add(userId);
      }

      transaction.update(postRef, {'likes': currentLikes});
    });
  }

  // CORRECTED METHOD - accepts a Map instead of String
  Future<void> addComment(String postId, Map<String, dynamic> comment) async {
    await FirebaseFirestore.instance.collection('posts').doc(postId).update({
      'comments': FieldValue.arrayUnion([comment]),
    });
  }
}
