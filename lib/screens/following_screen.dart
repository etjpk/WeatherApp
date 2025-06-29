import 'package:application_journey/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:application_journey/services/post_service.dart';
import 'package:application_journey/widgets/post_item.dart';
import 'package:application_journey/models/blog_post.dart';

/// Screen for viewing posts from users the current user follows.
class FollowingScreen extends StatefulWidget {
  @override
  _FollowingScreenState createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  final PostService _postService = PostService();
  final ScrollController _scrollController = ScrollController();

  List<BlogPost> _posts = []; // List of posts from followed users
  DocumentSnapshot? _lastDocument; // Last document for pagination
  bool _isLoading = false; // Loading state
  bool _hasMore = true; // Whether more posts are available
  List<String> _followingList = []; // List of user IDs being followed
  String _currentUserId = ''; // Current user ID
  bool _isInitializing = true; // Initial loading state

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser!.uid;
    _initializeFollowing(); // Load list of followed users
    _scrollController.addListener(_onScroll); // Listen for scroll events

    // Debug method to check following data (optional)
    debugFollowingData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Optional: Print debug info about followed users and their posts
  Future<void> debugFollowingData() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUserId)
        .get();

    final following = List<String>.from(userDoc.data()?['following'] ?? []);
    print('🔍 Current user following: $following');

    for (String userId in following) {
      final postsQuery = await FirebaseFirestore.instance
          .collection('posts')
          .where('authorId', isEqualTo: userId)
          .get();
      print('📝 User $userId has ${postsQuery.docs.length} posts');
    }
  }

  // Load list of users the current user follows
  Future<void> _initializeFollowing() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUserId)
          .get();

      final following = List<String>.from(userDoc.data()?['following'] ?? []);
      setState(() {
        _followingList = [...following, _currentUserId]; // Include own posts
        _isInitializing = false;
      });

      if (_followingList.isNotEmpty) {
        _loadPosts();
      }
    } catch (e) {
      print('Error initializing following: $e');
      setState(() => _isInitializing = false);
    }
  }

  // Load posts from followed users (and self), with pagination
  Future<void> _loadPosts({bool refresh = false}) async {
    if (_isLoading || (!_hasMore && !refresh)) return;
    if (_followingList.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      // Split following list into chunks of 10 (Firestore whereIn limit)
      final chunks = <List<String>>[];
      for (int i = 0; i < _followingList.length; i += 10) {
        chunks.add(_followingList.skip(i).take(10).toList());
      }

      List<BlogPost> allNewPosts = [];

      for (final chunk in chunks) {
        Query query = FirebaseFirestore.instance
            .collection('posts')
            .where('authorId', whereIn: chunk)
            .where('visibility', whereIn: ['public', 'following'])
            .orderBy('timestamp', descending: true)
            .limit(10);

        if (!refresh && _lastDocument != null && chunks.indexOf(chunk) == 0) {
          query = query.startAfterDocument(_lastDocument!);
        }

        final snapshot = await query.get();
        final chunkPosts = snapshot.docs
            .map((doc) => BlogPost.fromFirestore(doc))
            .toList();

        allNewPosts.addAll(chunkPosts);

        if (chunks.indexOf(chunk) == 0 && snapshot.docs.isNotEmpty) {
          _lastDocument = snapshot.docs.last;
        }
      }

      // Sort all posts by timestamp (newest first)
      allNewPosts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      setState(() {
        if (refresh) {
          _posts = allNewPosts;
          _hasMore = true;
        } else {
          _posts.addAll(allNewPosts);
        }

        _hasMore = allNewPosts.length >= 10;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading posts: $e');
      setState(() => _isLoading = false);
    }
  }

  // Load more posts when scrolling to the bottom
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadPosts();
    }
  }

  // Refresh the feed by reloading posts from scratch
  Future<void> _refreshPosts() async {
    _lastDocument = null;
    await _initializeFollowing();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Following',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  // Build the main body of the screen
  Widget _buildBody() {
    if (_followingList.length <= 1) {
      // Only current user (no one else followed)
      return _buildEmptyFollowingState();
    }

    if (_posts.isEmpty && !_isLoading) {
      // No posts from followed users
      return _buildNoPostsState();
    }

    // Posts feed with stats header and infinite scroll
    return RefreshIndicator(
      onRefresh: _refreshPosts,
      backgroundColor: Colors.grey[800],
      color: Colors.white,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Stats header (following count, post count, today's posts)
          SliverToBoxAdapter(child: _buildStatsHeader()),

          // Posts list with infinite scroll
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index < _posts.length) {
                // Show post item
                return PostItem(
                  post: _posts[index],
                  postService: _postService,
                  currentUserId: FirebaseAuth.instance.currentUser?.uid,
                );
              } else if (_hasMore) {
                // Show loading indicator if more posts are available
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                );
              } else {
                // Show end of feed message
                return _buildEndOfFeedIndicator();
              }
            }, childCount: _posts.length + (_hasMore ? 1 : 1)),
          ),
        ],
      ),
    );
  }

  // Build stats header (following count, post count, today's posts)
  Widget _buildStatsHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Following', '${_followingList.length - 1}'),
          _buildStatItem('Posts', '${_posts.length}'),
          _buildStatItem('Today', _getTodayPostsCount().toString()),
        ],
      ),
    );
  }

  // Build a stat item (count + label)
  Widget _buildStatItem(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
      ],
    );
  }

  // Count posts from today
  int _getTodayPostsCount() {
    final today = DateTime.now();
    return _posts.where((post) {
      final postDate = post.timestamp.toDate();
      return postDate.year == today.year &&
          postDate.month == today.month &&
          postDate.day == today.day;
    }).length;
  }

  // Show empty following state (no one followed)
  Widget _buildEmptyFollowingState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 80, color: Colors.grey[600]),
            SizedBox(height: 24),
            Text(
              'Start Following People',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Find interesting people to follow\nand see their posts here',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
                height: 1.5,
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to explore
                DefaultTabController.of(context)?.animateTo(0);
              },
              icon: Icon(Icons.explore),
              label: Text('Discover People'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show no posts state (followed users haven't posted)
  Widget _buildNoPostsState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 80, color: Colors.grey[600]),
            SizedBox(height: 24),
            Text(
              'No Recent Posts',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'People you follow haven\'t\nposted anything recently',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
                height: 1.5,
              ),
            ),
            SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: _refreshPosts,
              icon: Icon(Icons.refresh, color: Colors.white),
              label: Text(
                'Refresh Feed',
                style: TextStyle(color: Colors.white),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.white),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show end of feed indicator (no more posts)
  Widget _buildEndOfFeedIndicator() {
    return Container(
      padding: EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.grey[600], size: 48),
          SizedBox(height: 12),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Check back later for new posts',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Show search dialog (currently unused, but available for future)
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Search Posts', style: TextStyle(color: Colors.white)),
        content: TextField(
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search in following feed...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[600]!),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement search
              Navigator.pop(context);
            },
            child: Text('Search', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }
}
