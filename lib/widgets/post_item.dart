// import 'package:application_journey/Services/post_service.dart';
import 'package:application_journey/screens/comments_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:application_journey/models/blog_post.dart';

import 'package:intl/intl.dart'; // For date formatting
import 'dart:convert';
// Correct import (lowercase 's'):
import 'package:application_journey/services/post_service.dart';
import 'package:carousel_slider/carousel_slider.dart';

class PostItem extends StatefulWidget {
  final BlogPost post;
  final PostService postService;
  final String? currentUserId;
  final List<String>? currentUserFollowing; // Add this
  final VoidCallback? onFollowToggled;

  const PostItem({
    super.key,
    required this.post,
    required this.postService,
    this.currentUserFollowing, // Required parameters first
    this.currentUserId, // Optional parameters last
    this.onFollowToggled,
  });

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  late List<String> currentLikes;
  bool isLiking = false;
  bool _isFollowing = false;
  bool _isProcessingFollow = false;
  @override
  void initState() {
    super.initState();
    currentLikes = List.from(widget.post.likes);
    _isFollowing =
        widget.currentUserFollowing?.contains(widget.post.authorId) ?? false;
  }

  Widget _buildContent() {
    try {
      // Try to parse as rich text
      final quillController = QuillController(
        document: Document.fromJson(jsonDecode(widget.post.content)),
        selection: const TextSelection.collapsed(offset: 0),
        readOnly: true,
      );
      return QuillEditor.basic(controller: quillController);
    } catch (e) {
      // Fallback to plain text
      return Text(widget.post.content, style: TextStyle(fontSize: 16));
    }
  }

  Future<void> _toggleFollow() async {
    if (widget.currentUserId == null ||
        widget.post.authorId == widget.currentUserId ||
        _isProcessingFollow)
      return;

    setState(() => _isProcessingFollow = true);

    try {
      await widget.postService.toggleFollow(
        currentUserId: widget.currentUserId!,
        targetUserId: widget.post.authorId,
      );

      setState(() => _isFollowing = !_isFollowing);

      if (widget.onFollowToggled != null) {
        widget.onFollowToggled!();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Follow error: $e')));
    } finally {
      setState(() => _isProcessingFollow = false);
    }
  }

  Future<void> _toggleLike() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null || isLiking) return;

    setState(() {
      isLiking = true;
      // Optimistic update for instant feedback
      if (currentLikes.contains(userId)) {
        currentLikes.remove(userId);
      } else {
        currentLikes.add(userId);
      }
    });

    try {
      await widget.postService.toggleLike(widget.post.id, userId);
    } catch (e) {
      // Revert on error
      setState(() {
        if (currentLikes.contains(userId)) {
          currentLikes.remove(userId);
        } else {
          currentLikes.add(userId);
        }
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update like: $e')));
    } finally {
      setState(() {
        isLiking = false;
      });
    }
  }

  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isLiked = currentLikes.contains(userId);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author header
          ListTile(
            // Replace the CircleAvatar code
            leading: CircleAvatar(
              backgroundColor: Colors.grey[300],
              backgroundImage: (widget.post.authorAvatar?.isNotEmpty == true)
                  ? CachedNetworkImageProvider(widget.post.authorAvatar!)
                  : null,
              child: (widget.post.authorAvatar?.isEmpty != false)
                  ? Icon(Icons.person, color: Colors.grey[600])
                  : null,
            ),

            // leading: CircleAvatar(
            //   backgroundImage: CachedNetworkImageProvider(widget.post.authorAvatar),
            // ),
            title: Text(
              //
              widget.post.authorName ?? 'Unknown User',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.post.authorUsername ?? 'unknown'), // Added username
                Text(
                  // Keep timestamp
                  DateFormat.yMMMd().add_jm().format(
                    widget.post.timestamp.toDate(),
                  ),
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.post.visibility == 'public'
                      ? Icons.public
                      : Icons.lock_person,
                  size: 16,
                  color: widget.post.visibility == 'public'
                      ? Colors.blue
                      : Colors.orange,
                ),
                // ADD FOLLOW BUTTON HERE
                // Show follow button only in Explore context
                if (widget.currentUserId != null &&
                    widget.post.authorId != widget.currentUserId &&
                    widget.currentUserFollowing != null) // Add this condition
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: _isProcessingFollow
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : IconButton(
                            icon: Icon(
                              _isFollowing ? Icons.person : Icons.person_add,
                              color: _isFollowing ? Colors.blue : Colors.grey,
                            ),
                            onPressed: _toggleFollow,
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                  ),
              ],
            ),
          ),

          // Rich text content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildContent(), // We'll create this method next
          ),

          // Image grid
          // Replace this section in PostItem:
          if (widget.post.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 12),
            // Instagram-style swipeable carousel
            CarouselSlider(
              options: CarouselOptions(
                height: 220,
                viewportFraction: 1.0,
                enableInfiniteScroll: false,
                enlargeCenterPage: false,
                aspectRatio: 16 / 9,
              ),
              items: widget.post.imageUrls.map((imageUrl) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 220,
                        color: Colors.grey[200],
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 220,
                        color: Colors.grey[200],
                        child: Icon(Icons.error),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            // Optional: Show image counter for multiple images
            if (widget.post.imageUrls.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Center(
                  child: Text(
                    '1/${widget.post.imageUrls.length}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ),
              ),
          ],

          // Interaction bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : null,
                  ),
                  onPressed: isLiking ? null : _toggleLike,
                ),
                Text(currentLikes.length.toString()),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.comment),
                  onPressed: () => _navigateToComments(widget.post.id),
                ),
                Text(
                  widget.post.comments.length.toString(),
                ), // Fixed comment count
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleLike(String postId) {
    // Implement like functionality
    print('Liked post $postId');
  }

  void _navigateToComments(String postId) {
    // Implement comment navigation

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CommentsScreen(postId: postId)),
    );
  }
}
