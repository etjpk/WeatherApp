import 'package:application_journey/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Displays a list of a user's followers or following users.
class FollowersFollowingScreen extends StatefulWidget {
  final String userId; // The user whose followers/following are being shown
  final String type; // Either 'followers' or 'following'
  final String userName; // The user's name for display

  const FollowersFollowingScreen({
    super.key,
    required this.userId,
    required this.type,
    required this.userName,
  });

  @override
  State<FollowersFollowingScreen> createState() =>
      _FollowersFollowingScreenState();
}

class _FollowersFollowingScreenState extends State<FollowersFollowingScreen> {
  List<Map<String, dynamic>> users = []; // List of user data to display
  bool isLoading = true; // Loading state flag

  @override
  void initState() {
    super.initState();
    _loadUsers(); // Load user data on initialization
  }

  /// Fetches the user's followers or following list and their details.
  Future<void> _loadUsers() async {
    try {
      // Get the user document from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (!userDoc.exists) return;

      final userData = userDoc.data()!;
      final List<String> userIds = List<String>.from(
        userData[widget.type] ?? [],
      );

      if (userIds.isEmpty) {
        setState(() => isLoading = false);
        return;
      }

      // Fetch details for each user in the list
      final List<Map<String, dynamic>> fetchedUsers = [];

      for (String userId in userIds) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (doc.exists) {
          final data = doc.data()!;
          data['id'] = doc.id;
          fetchedUsers.add(data);
        }
      }

      setState(() {
        users = fetchedUsers;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading users: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.type == 'followers'
              ? '${widget.userName}\'s Followers'
              : '${widget.userName}\'s Following',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.white))
          : users.isEmpty
          ? _buildEmptyState()
          : _buildUsersList(),
    );
  }

  /// Shows a centered message when there are no followers/following.
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.type == 'followers'
                ? Icons.people_outline
                : Icons.person_add_outlined,
            size: 64,
            color: Colors.grey[600],
          ),
          SizedBox(height: 16),
          Text(
            widget.type == 'followers'
                ? 'No followers yet'
                : 'Not following anyone yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a scrollable list of users.
  Widget _buildUsersList() {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return _buildUserItem(user);
      },
    );
  }

  /// Builds a single user item with avatar, name, username, and a message button.
  Widget _buildUserItem(Map<String, dynamic> user) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isCurrentUser = currentUserId == user['id'];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // User Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey[800],
            backgroundImage:
                user['profileImageUrl'] != null &&
                    user['profileImageUrl'].isNotEmpty
                ? NetworkImage(user['profileImageUrl'])
                : null,
            child:
                user['profileImageUrl'] == null ||
                    user['profileImageUrl'].isEmpty
                ? Icon(Icons.person, color: Colors.grey[400], size: 24)
                : null,
          ),
          SizedBox(width: 12),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['username'] ?? 'unknown',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  user['name'] ?? 'User',
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                ),
              ],
            ),
          ),

          // Action Button (Message) - only shown for other users
          if (!isCurrentUser)
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      receiverId: user['id'],
                      receiverName: user['name'] ?? 'User',
                      receiverAvatar: user['profileImageUrl'] ?? '',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                'Message',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
