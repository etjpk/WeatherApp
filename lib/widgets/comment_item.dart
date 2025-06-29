import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentItem extends StatelessWidget {
  final Map<String, dynamic> comment;
  const CommentItem({Key? key, required this.comment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Picture
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[300],
            backgroundImage: comment['userProfileImage']?.isNotEmpty == true
                ? CachedNetworkImageProvider(comment['userProfileImage'])
                : null,
            child: comment['userProfileImage']?.isEmpty != false
                ? Icon(Icons.person, color: Colors.grey[600], size: 20)
                : null,
          ),
          const SizedBox(width: 12),
          // Comment Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Name and Username
                Row(
                  children: [
                    Text(
                      comment['userName'] ?? 'Unknown User',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '@${comment['userUsername'] ?? 'unknown'}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Comment Text
                Text(
                  comment['text'] ?? '',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                // Timestamp
                Text(
                  _formatTimestamp(comment['timestamp']),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      final dateTime = (timestamp as Timestamp).toDate();
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }
}
