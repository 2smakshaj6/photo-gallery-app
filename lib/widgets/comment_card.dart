import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/comment.dart';
import '../providers/app_providers.dart';
import '../services/auth_service.dart';

class CommentCard extends ConsumerWidget {
  final String photoId;
  final Comment comment;
  final VoidCallback onReply;
  final List<Comment> allComments;

  const CommentCard({
    super.key,
    required this.photoId,
    required this.comment,
    required this.onReply,
    required this.allComments,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    
    // Find replies to this comment
    final replies = allComments
        .where((c) => c.parentId == comment.id)
        .toList();

    String displayName = isAdmin
      ? (comment.commenterName.isNotEmpty ? comment.commenterName : 'Unknown') +
        (comment.commenterNTID.isNotEmpty ? ' (${comment.commenterNTID})' : '')
      : 'Anonymous';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: [
                          TextSpan(
                            text: '$displayName ',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: comment.text),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          _formatTimestamp(comment.timestamp),
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: onReply,
                          child: Text(
                            'Reply',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (isAdmin) ...[
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () => _showDeleteCommentDialog(context, ref),
                            child: Text(
                              'Delete',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red[400],
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'ADMIN',
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    iconSize: 18,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      comment.isLiked ? Icons.favorite : Icons.favorite_border,
                      color: comment.isLiked ? Colors.red : Colors.grey[400],
                    ),
                    onPressed: () {
                      ref
                          .read(commentsNotifierProvider.notifier)
                          .toggleCommentLike(photoId, comment.id);
                    },
                  ),
                  Text(
                    '${comment.likeCount}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
          // Display replies
          if (replies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 40.0, top: 8.0),
              child: Column(
                children: replies.map((reply) => CommentCard(
                  photoId: photoId,
                  comment: reply,
                  onReply: () {}, // For now, we don't support nested replies
                  allComments: allComments,
                )).toList(),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showDeleteCommentDialog(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.read(isAdminProvider);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Text('Delete Comment?'),
              if (isAdmin) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'ADMIN',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isAdmin) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.admin_panel_settings, color: Colors.red[400], size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Admin: Deleting user comment',
                          style: TextStyle(
                            color: Colors.red[400],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const Text('This action cannot be undone.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                await ref.read(firebaseServiceProvider).deleteComment(photoId, comment.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.delete_forever, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(isAdmin ? 'Admin: Comment deleted!' : 'Comment deleted!'),
                      ],
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
} 