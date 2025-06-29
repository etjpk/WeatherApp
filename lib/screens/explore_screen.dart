import 'package:application_journey/models/blog_post.dart';
import 'package:application_journey/screens/search_screen.dart';
import 'package:flutter/material.dart';
// import 'package:application_journey/services/post_service.dart';
import 'package:application_journey/widgets/post_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Correct import (lowercase 's'):
import 'package:application_journey/services/post_service.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ADD THIS

class ExploreScreen extends StatefulWidget {
  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  // final PostService _postService = PostService();
  // final _postService = PostService();
  final User? _currentUser = FirebaseAuth.instance.currentUser; // ADD THIS LINE
  List<String> _currentUserFollowing = [];
  late final PostService _postService;

  final ScrollController _scrollController = ScrollController();
  List<BlogPost> _posts = [];
  DocumentSnapshot? _lastVisible;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    _postService = PostService(); // Initialize properly
    super.initState();
    _loadInitialPosts();
    _loadCurrentUserFollowing(); // ADD THIS
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _loadCurrentUserFollowing() async {
    if (_currentUser == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser!.uid)
        .get();

    if (userDoc.exists) {
      setState(() {
        _currentUserFollowing = List<String>.from(
          userDoc.data()!['following'] ?? [],
        );
      });
    }
  }

  Future<void> _loadInitialPosts() async {
    setState(() => _isLoading = true);

    try {
      final result = await _postService.getPublicPosts(
        lastDocument: _lastVisible,
      );

      setState(() {
        _posts = result.posts; // ← HERE
        _lastVisible = result.lastVisible; // ← HERE
        _isLoading = false;
        _hasMore = result.posts.length == 10;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading posts: $e')));
    }
  }

  // Future<void> _loadInitialPosts() async {
  //   setState(() => _isLoading = true);
  //   final result = await _postService.getPublicPosts();
  //   setState(() {
  //     _posts = result.posts;
  //     _lastVisible = result.lastVisible;
  //     _isLoading = false;
  //     _hasMore = _posts.length == 10; // Assuming page size is 10
  //   });
  // }
  Future<void> _loadMorePosts() async {
    if (!_hasMore || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final result = await _postService.getPublicPosts(
        lastDocument: _lastVisible, // ← HERE
      );

      setState(() {
        _posts.addAll(result.posts); // ← HERE
        _lastVisible = result.lastVisible; // ← HERE
        _isLoading = false;
        _hasMore = result.posts.isNotEmpty;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _lastVisible = null;
      _posts = [];
      _hasMore = true;
    });
    await _loadInitialPosts();
  }

  // Future<void> _loadMorePosts() async {
  //   if (!_hasMore || _isLoading) return;

  //   setState(() => _isLoading = true);
  //   final result = await _postService.getPublicPosts(
  //     lastDocument: _lastVisible,
  //   );

  //   setState(() {
  //     _posts.addAll(result.posts);
  //     _lastVisible = result.lastVisible;
  //     _isLoading = false;
  //     _hasMore = result.posts.isNotEmpty;
  //   });
  // }

  // Future<void> _refreshPosts() async {
  //   setState(() {
  //     _lastVisible = null;
  //     _posts = [];
  //     _hasMore = true;
  //   });
  //   await _loadInitialPosts();
  // }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMorePosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Explore',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            fontFamily: 'Montserrat', // optional for a modern font
            letterSpacing: 1.2,
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
        // Optionally add actions (search, filter, etc.)
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _posts.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= _posts.length) {
              return _isLoading
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : SizedBox.shrink();
            }
            return PostItem(
              post: _posts[index],
              postService: _postService,
              currentUserId: _currentUser?.uid,
              currentUserFollowing: _currentUserFollowing,
              onFollowToggled: _loadCurrentUserFollowing,
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
