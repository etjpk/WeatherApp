import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:application_journey/models/blog_post.dart';
import 'package:application_journey/widgets/post_item.dart';
import 'package:application_journey/services/post_service.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final PostService _postService = PostService();
  List<BlogPost> _searchResults = [];
  List<BlogPost> _allPosts = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _loadAllPosts();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadAllPosts() async {
    setState(() => _isLoading = true);
    try {
      final result = await _postService.getPublicPosts();
      setState(() {
        _allPosts = result.posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _hasSearched = true;
      _searchResults = _allPosts.where((post) {
        final titleMatch = post.title.toLowerCase().contains(query);
        final contentMatch = post.content.toLowerCase().contains(query);
        final authorMatch = (post.authorName ?? '').toLowerCase().contains(
          query,
        );

        return titleMatch || contentMatch || authorMatch;
      }).toList();
    });
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
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search posts...',
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                : null,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Search for posts',
              style: TextStyle(color: Colors.grey, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Type to search by title, content, or author',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(color: Colors.grey, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Try different keywords',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return PostItem(
          post: _searchResults[index],
          postService: _postService,
          currentUserId: FirebaseAuth.instance.currentUser?.uid,
          currentUserFollowing: [], // Empty for search results
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
