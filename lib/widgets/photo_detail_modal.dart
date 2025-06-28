import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../models/photo.dart';
import '../models/comment.dart';
import '../providers/app_providers.dart';
import '../services/ownership_service.dart';
import '../services/auth_service.dart';
import 'fullscreen_image_viewer.dart';
import 'comment_card.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhotoDetailModal extends ConsumerStatefulWidget {
  final Photo photo;
  const PhotoDetailModal({super.key, required this.photo});

  @override
  ConsumerState<PhotoDetailModal> createState() => _PhotoDetailModalState();
}

class _PhotoDetailModalState extends ConsumerState<PhotoDetailModal> {
  final _commentController = TextEditingController();
  final _commentFocusNode = FocusNode();
  String? _replyToCommentId;

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  String _getUploaderDisplayName(Photo photo) {
    // Check if current user is admin by comparing email
    final currentUser = ref.read(authServiceProvider).currentUser;
    final isAdmin = currentUser?.email == AuthService.adminEmail;
    
    if (isAdmin && photo.uploaderName != null) {
      return '${photo.uploaderName} (${photo.uploaderNTID ?? 'No ID'})';
    }
    return 'Anonymous';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final photosAsync = ref.watch(photosProvider);
        
        return photosAsync.when(
          data: (photos) {
            final currentPhoto = photos.firstWhere(
              (p) => p.id == widget.photo.id,
              orElse: () => widget.photo,
            );
            
            final isAdmin = ref.watch(isAdminProvider);

            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      // Handle
                      Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Clickable Image
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FullscreenImageViewer(
                                        imageUrl: currentPhoto.imageUrl,
                                      ),
                                    ),
                                  );
                                },
                                child: Hero(
                                  tag: currentPhoto.id,
                                  child: Stack(
                                    children: [
                                      Container(
                                        height: MediaQuery.of(context).size.height * 0.4,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                          image: DecorationImage(
                                            image: NetworkImage(currentPhoto.imageUrl),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 12,
                                        right: 12,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.4),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.fullscreen,
                                            color: Colors.white70,
                                            size: 28,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Caption
                                    Text(
                                      currentPhoto.description,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    // Uploader info
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person,
                                          size: 16,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _getUploaderDisplayName(currentPhoto),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                        if (isAdmin && currentPhoto.uploaderName != null) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.red.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              'ADMIN VIEW',
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
                                    const SizedBox(height: 8),
                                    // Timestamp
                                    Text(
                                      'Uploaded ${_formatTimestamp(currentPhoto.uploadDate)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Divider(color: Colors.grey[800]),
                                    const SizedBox(height: 16),
                                    // Action Buttons
                                    Row(
                                      children: [
                                        // Like Button
                                        IconButton(
                                          icon: Icon(
                                            currentPhoto.isLiked
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: currentPhoto.isLiked
                                                ? Colors.red
                                                : Colors.white,
                                          ),
                                          onPressed: () {
                                            ref.read(photosNotifierProvider.notifier).toggleLike(currentPhoto.id);
                                          },
                                        ),
                                        Text(
                                          '${currentPhoto.likes}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 24),
                                        // Share Button
                                        IconButton(
                                          icon: const Icon(Icons.share, color: Colors.white),
                                          onPressed: () {
                                            Share.share(
                                              'Check out this photo from the contest! ${currentPhoto.imageUrl}',
                                              subject: 'Awesome Photo!',
                                            );
                                          },
                                        ),
                                        const Spacer(),
                                        // Owner Buttons
                                        FutureBuilder<bool>(
                                          future: ref.read(ownershipServiceProvider).isOwner(currentPhoto.id),
                                          builder: (context, snapshot) {
                                            final isOwner = snapshot.data ?? false;
                                            
                                            // Show edit/delete buttons for owners OR admins
                                            if (isOwner || isAdmin) {
                                              return Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(Icons.edit, color: Colors.white70),
                                                    onPressed: () => _showEditOptionsDialog(context, ref, currentPhoto),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                                                    onPressed: () => _showDeleteConfirmationDialog(context, ref, currentPhoto),
                                                  ),
                                                  if (isAdmin && !isOwner) ...[
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
                                              );
                                            }
                                            return const SizedBox.shrink();
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    // Comments Section
                                    const Text(
                                      'Comments',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Comment Input
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: _commentController,
                                            focusNode: _commentFocusNode,
                                            decoration: InputDecoration(
                                              hintText: _replyToCommentId != null
                                                  ? 'Reply to comment...'
                                                  : 'Add a comment...',
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(25),
                                              ),
                                              contentPadding: const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 12,
                                              ),
                                            ),
                                            maxLines: null,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(Icons.send, color: Colors.red),
                                          onPressed: () async {
                                            if (_commentController.text.trim().isNotEmpty) {
                                              final prefs = await SharedPreferences.getInstance();
                                              final commenterName = prefs.getString('user_name') ?? '';
                                              final commenterNTID = prefs.getString('department_id') ?? '';
                                              await ref.read(firebaseServiceProvider).addComment(
                                                currentPhoto.id,
                                                _commentController.text.trim(),
                                                commenterName: commenterName,
                                                commenterNTID: commenterNTID,
                                                parentId: _replyToCommentId,
                                              );
                                              _commentController.clear();
                                              _replyToCommentId = null;
                                              _commentFocusNode.unfocus();
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                    if (_replyToCommentId != null) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Text(
                                            'Replying to comment',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[400],
                                            ),
                                          ),
                                          const Spacer(),
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                _replyToCommentId = null;
                                              });
                                            },
                                            child: const Text('Cancel'),
                                          ),
                                        ],
                                      ),
                                    ],
                                    const SizedBox(height: 16),
                                    // Comments List
                                    Consumer(
                                      builder: (context, ref, child) {
                                        final commentsAsync = ref.watch(commentsProvider(currentPhoto.id));
                                        return commentsAsync.when(
                                          data: (comments) => comments.isEmpty
                                              ? const Center(
                                                  child: Padding(
                                                    padding: EdgeInsets.all(32.0),
                                                    child: Text(
                                                      'No comments yet. Be the first to comment!',
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : Column(
                                                  children: comments
                                                      .where((comment) => comment.parentId == null)
                                                      .map((comment) => CommentCard(
                                                        comment: comment,
                                                        photoId: currentPhoto.id,
                                                        allComments: comments,
                                                        onReply: () {
                                                          setState(() {
                                                            _replyToCommentId = comment.id;
                                                          });
                                                          _commentFocusNode.requestFocus();
                                                        },
                                                      ))
                                                      .toList(),
                                                ),
                                          loading: () => const Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(32.0),
                                              child: CircularProgressIndicator(),
                                            ),
                                          ),
                                          error: (error, stack) => Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(32.0),
                                              child: Text(
                                                'Error loading comments: $error',
                                                style: const TextStyle(color: Colors.red),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        );
      },
    );
  }

  void _showEditOptionsDialog(BuildContext context, WidgetRef ref, Photo photo) {
    final isAdmin = ref.read(isAdminProvider);
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return FutureBuilder<bool>(
          future: ref.read(ownershipServiceProvider).isOwner(photo.id),
          builder: (context, snapshot) {
            final isOwner = snapshot.data ?? false;
            return SafeArea(
              child: Wrap(
                children: <Widget>[
                  if (isAdmin && !isOwner) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: Colors.red.withOpacity(0.1),
                      child: Row(
                        children: [
                          Icon(Icons.admin_panel_settings, color: Colors.red[400], size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Admin Action: Modifying another user\'s content',
                            style: TextStyle(
                              color: Colors.red[400],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  ListTile(
                    leading: const Icon(Icons.edit_note),
                    title: const Text('Edit Description'),
                    subtitle: isAdmin && !isOwner ? const Text('Admin: Editing user content') : null,
                    onTap: () {
                      Navigator.pop(context);
                      _showEditCaptionDialog(context, ref, photo, isAdmin: isAdmin, isOwner: isOwner);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.image),
                    title: const Text('Replace Photo'),
                    subtitle: isAdmin && !isOwner ? const Text('Admin: Replacing user photo') : null,
                    onTap: () async {
                      Navigator.pop(context);
                      final imagePicker = ImagePicker();
                      final XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        final newBytes = await image.readAsBytes();
                        // Show a loading indicator
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                const SizedBox(width: 8),
                                Text(isAdmin && !isOwner ? 'Admin: Replacing photo...' : 'Replacing photo...'),
                              ],
                            ),
                            duration: const Duration(seconds: 10),
                          ),
                        );
                        try {
                          final newImageUrl = await ref.read(firebaseServiceProvider).replacePhoto(photo.imageUrl, newBytes);
                          await ref.read(firebaseServiceProvider).updatePhotoUrl(photo.id, newImageUrl);
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text(isAdmin && !isOwner ? 'Admin: Photo replaced successfully!' : 'Photo replaced successfully!'),
                                ],
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.cancel),
                    title: const Text('Cancel'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditCaptionDialog(BuildContext context, WidgetRef ref, Photo photo, {required bool isAdmin, required bool isOwner}) {
    final captionController = TextEditingController(text: photo.description);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Text('Edit Description'),
              if (isAdmin && !isOwner) ...[
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
              if (isAdmin && !isOwner) ...[
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
                          'You are editing content uploaded by: ${photo.uploaderName ?? 'Unknown'} (${photo.uploaderNTID ?? 'No ID'})',
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
              TextField(
                controller: captionController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Enter new description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (captionController.text.isNotEmpty) {
                  ref.read(firebaseServiceProvider).updatePhotoDescription(photo.id, captionController.text);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(isAdmin && !isOwner ? 'Admin: Description updated!' : 'Description updated!'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref, Photo photo) {
    final isAdmin = ref.read(isAdminProvider);
    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<bool>(
          future: ref.read(ownershipServiceProvider).isOwner(photo.id),
          builder: (context, snapshot) {
            final isOwner = snapshot.data ?? false;
            return AlertDialog(
              title: Row(
                children: [
                  const Text('Delete Photo?'),
                  if (isAdmin && !isOwner) ...[
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
                  if (isAdmin && !isOwner) ...[
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
                              'You are deleting content uploaded by: ${photo.uploaderName ?? 'Unknown'} (${photo.uploaderNTID ?? 'No ID'})',
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
                    await ref.read(firebaseServiceProvider).deletePhoto(photo.id, photo.imageUrl);
                    await ref.read(ownershipServiceProvider).removeOwnedPhoto(photo.id);
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Close detail modal
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.delete_forever, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(isAdmin && !isOwner ? 'Admin: Photo deleted!' : 'Photo deleted!'),
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
      },
    );
  }
} 