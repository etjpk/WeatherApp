import 'package:flutter/material.dart';
import 'package:application_journey/services/user_service.dart';

class FollowButton extends StatefulWidget {
  final String targetUserId;
  final String targetUserName;

  const FollowButton({
    super.key,
    required this.targetUserId,
    required this.targetUserName,
  });

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  final UserService _userService = UserService();
  bool _isFollowing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkFollowingStatus();
  }

  Future<void> _checkFollowingStatus() async {
    final isFollowing = await _userService.isFollowing(widget.targetUserId);
    setState(() => _isFollowing = isFollowing);
  }

  Future<void> _toggleFollow() async {
    setState(() => _isLoading = true);

    try {
      if (_isFollowing) {
        await _userService.unfollowUser(widget.targetUserId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unfollowed ${widget.targetUserName}')),
        );
      } else {
        await _userService.followUser(widget.targetUserId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Following ${widget.targetUserName}')),
        );
      }

      setState(() => _isFollowing = !_isFollowing);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _toggleFollow,
      style: ElevatedButton.styleFrom(
        backgroundColor: _isFollowing ? Colors.grey : Colors.blue,
        foregroundColor: Colors.white,
      ),
      child: _isLoading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(_isFollowing ? 'Unfollow' : 'Follow'),
    );
  }
}
