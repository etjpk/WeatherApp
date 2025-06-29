import 'package:application_journey/screens/followers_following_screen.dart';
import 'package:application_journey/screens/post_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:application_journey/models/user_model.dart';
import 'package:application_journey/edit_profile_page.dart';
import 'package:application_journey/widgets/follow_button.dart';
import 'package:application_journey/services/user_service.dart';

/// Profile screen for viewing a user profile, posts, followers, and following.
class ProfileScreen extends StatefulWidget {
  final String userId;
  const ProfileScreen({super.key, required this.userId});
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  late String profileUserId;

  @override
  void initState() {
    super.initState();
    profileUserId = widget.userId; // Set the profile user ID on init
  }

  // Get the current user ID
  String get currentUserId => FirebaseAuth.instance.currentUser!.uid;
  // Check if the profile belongs to the current user
  bool get isCurrentUser => currentUserId == profileUserId;

  /// Navigates to the followers or following list, or shows a message if empty.
  void _navigateToFollowersList(
    String type,
    int count,
    Map<String, dynamic> userData,
  ) {
    if (count == 0) {
      // Show a message instead of navigating
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No ${type} yet')));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FollowersFollowingScreen(
          userId: profileUserId,
          type: type,
          userName: userData['name'] ?? userData['username'] ?? 'User',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(profileUserId)
            .snapshots(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
          if (userData == null) {
            return Center(child: Text('User data not found'));
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .where('authorId', isEqualTo: profileUserId)
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, postSnapshot) {
              int postCount = 0;
              if (postSnapshot.hasData) {
                postCount = postSnapshot.data!.docs.length;
              }

              return SingleChildScrollView(
                child: Column(
                  children: [
                    // Profile header with stats and info
                    _buildProfileHeader(userData, postCount),
                    SizedBox(height: 20),

                    // User's posts grid
                    if (postSnapshot.connectionState == ConnectionState.waiting)
                      Center(child: CircularProgressIndicator()),

                    if (postSnapshot.hasData && postSnapshot.data!.docs.isEmpty)
                      Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: Text('No posts yet')),
                      ),

                    if (postSnapshot.hasData &&
                        postSnapshot.data!.docs.isNotEmpty)
                      _buildPostsGrid(postSnapshot.data!.docs),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Builds the profile header with avatar, stats, and edit/follow button.
  Widget _buildProfileHeader(Map<String, dynamic> userData, int postCount) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Top row: Avatar and stats
          Row(
            children: [
              // Profile picture
              CircleAvatar(
                radius: 40,
                backgroundImage:
                    userData['profileImageUrl'] != null &&
                        userData['profileImageUrl'].isNotEmpty
                    ? CachedNetworkImageProvider(userData['profileImageUrl'])
                    : null,
                child:
                    userData['profileImageUrl'] == null ||
                        userData['profileImageUrl'].isEmpty
                    ? Icon(Icons.person, size: 40, color: Colors.grey)
                    : null,
              ),
              SizedBox(width: 20),

              // Stats section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatColumn(postCount.toString(), 'Posts', () {}),
                  StreamBuilder<int>(
                    stream: _userService.getFollowersCount(profileUserId),
                    builder: (context, snapshot) {
                      return _buildStatColumn(
                        '${snapshot.data ?? 0}',
                        'Followers',
                        () => _navigateToFollowersList(
                          'followers',
                          snapshot.data ?? 0,
                          userData,
                        ),
                      );
                    },
                  ),
                  StreamBuilder<int>(
                    stream: _userService.getFollowingCount(profileUserId),
                    builder: (context, snapshot) {
                      return _buildStatColumn(
                        '${snapshot.data ?? 0}',
                        'Following',
                        () => _navigateToFollowersList(
                          'following',
                          snapshot.data ?? 0,
                          userData,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),

          // User info: name, username, bio
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name
              if (userData['name'] != null && userData['name'].isNotEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    userData['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              SizedBox(height: 4),

              // Username
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '@${userData['username'] ?? 'username'}',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              SizedBox(height: 8),

              // Bio
              if (userData['bio'] != null && userData['bio'].isNotEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    userData['bio'],
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16),

          // Edit profile or follow button
          if (isCurrentUser)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfilePage(
                        currentUser: Usern(
                          id: currentUserId,
                          name: userData['name'] ?? '',
                          username: userData['username'] ?? '',
                          bio: userData['bio'] ?? '',
                          profileImageUrl: userData['profileImageUrl'] ?? '',
                        ),
                      ),
                    ),
                  );
                },
                child: Text(
                  'Edit Profile',
                  style: TextStyle(color: Colors.white),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: BorderSide(color: Colors.grey),
                ),
              ),
            )
          else
            FollowButton(
              targetUserId: profileUserId,
              targetUserName: userData['name'] ?? 'User',
            ),
        ],
      ),
    );
  }

  /// Builds a grid of user posts using the first image of each post.
  Widget _buildPostsGrid(List<QueryDocumentSnapshot> posts) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index].data() as Map<String, dynamic>;
        final imageUrls = post['imageUrls'] as List<dynamic>? ?? [];
        final imageUrl = imageUrls.isNotEmpty ? imageUrls[0] as String? : null;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostDetailScreen(postId: posts[index].id),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title above image
              Container(
                padding: EdgeInsets.all(4),
                color: Colors.grey[900],
                child: Text(
                  post['title'] ?? 'Untitled',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 1,
                ),
              ),
              // Image container
              Expanded(
                child: Container(
                  color: Colors.grey[200],
                  child: imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                        )
                      : Icon(Icons.image, color: Colors.grey),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds a column for displaying a stat (number and label) with tap action.
  Widget _buildStatColumn(String number, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              number,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
