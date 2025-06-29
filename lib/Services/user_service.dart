import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Add this method for creating/updating user profile
  Future<void> createOrUpdateUserProfile({
    required String userId,
    required String name,
    required String username,
    String? email,
    String? profileImageUrl,
    String? bio,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'id': userId,
        'name': name,
        'username': username,
        'email': email ?? '',
        'profileImageUrl': profileImageUrl ?? '',
        'bio': bio ?? '',
        'followers': [],
        'following': [],
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // Use merge to update existing fields
    } catch (e) {
      print('Error creating/updating user profile: $e');
      rethrow;
    }
  }

  // Add this method to get user data
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Add this method to update just the username
  Future<void> updateUsername(String userId, String newUsername) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'username': newUsername,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating username: $e');
      rethrow;
    }
  }

  // Add this method to sync user on first login
  Future<void> syncUserOnLogin() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // Check if user document exists
    final userData = await getUserData(currentUser.uid);

    if (userData == null) {
      // Create user document if it doesn't exist
      await createOrUpdateUserProfile(
        userId: currentUser.uid,
        name: currentUser.displayName ?? 'User',
        username:
            currentUser.email?.split('@')[0] ??
            'user${currentUser.uid.substring(0, 6)}',
        email: currentUser.email,
        profileImageUrl: currentUser.photoURL,
      );
    }
  }

  // Follow a user
  Future<void> followUser(String targetUserId) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null || currentUserId == targetUserId) return;

    final currentUserRef = _firestore.collection('users').doc(currentUserId);
    final targetUserRef = _firestore.collection('users').doc(targetUserId);

    await _firestore.runTransaction((transaction) async {
      final currentUserDoc = await transaction.get(currentUserRef);
      final targetUserDoc = await transaction.get(targetUserRef);

      // Add to current user's following array
      final following = List<String>.from(
        currentUserDoc.data()?['following'] ?? [],
      );
      if (!following.contains(targetUserId)) {
        following.add(targetUserId);
        transaction.update(currentUserRef, {'following': following});
      }

      // Add to target user's followers array
      final followers = List<String>.from(
        targetUserDoc.data()?['followers'] ?? [],
      );
      if (!followers.contains(currentUserId)) {
        followers.add(currentUserId);
        transaction.update(targetUserRef, {'followers': followers});
      }
    });
  }

  // Unfollow a user
  Future<void> unfollowUser(String targetUserId) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    final currentUserRef = _firestore.collection('users').doc(currentUserId);
    final targetUserRef = _firestore.collection('users').doc(targetUserId);

    await _firestore.runTransaction((transaction) async {
      final currentUserDoc = await transaction.get(currentUserRef);
      final targetUserDoc = await transaction.get(targetUserRef);

      // Remove from current user's following array
      final following = List<String>.from(
        currentUserDoc.data()?['following'] ?? [],
      );
      following.remove(targetUserId);
      transaction.update(currentUserRef, {'following': following});

      // Remove from target user's followers array
      final followers = List<String>.from(
        targetUserDoc.data()?['followers'] ?? [],
      );
      followers.remove(currentUserId);
      transaction.update(targetUserRef, {'followers': followers});
    });
  }

  // Check if current user is following target user
  Future<bool> isFollowing(String targetUserId) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return false;

    final userDoc = await _firestore
        .collection('users')
        .doc(currentUserId)
        .get();
    final following = List<String>.from(userDoc.data()?['following'] ?? []);
    return following.contains(targetUserId);
  }

  // Get following count
  Stream<int> getFollowingCount(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => List<String>.from(doc.data()?['following'] ?? []).length);
  }

  // Get followers count
  Stream<int> getFollowersCount(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => List<String>.from(doc.data()?['followers'] ?? []).length);
  }
}
