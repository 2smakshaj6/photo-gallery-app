import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/photo.dart';
import 'photo_detail_modal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';

class PhotoGrid extends StatelessWidget {
  final List<Photo> photos;

  const PhotoGrid({super.key, required this.photos});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth / 250).floor().clamp(1, 5);

    return GridView.builder(
      padding: const EdgeInsets.all(24.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.75,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];
        return PhotoCard(photo: photo);
      },
    );
  }
}

class PhotoCard extends ConsumerStatefulWidget {
  final Photo photo;
  const PhotoCard({super.key, required this.photo});

  @override
  ConsumerState<PhotoCard> createState() => _PhotoCardState();
}

class _PhotoCardState extends ConsumerState<PhotoCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()
          ..scale(_isHovered ? 1.05 : 1.0),
        child: Card(
          elevation: _isHovered ? 8 : 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => _showPhotoDetail(context),
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.network(
                            widget.photo.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(
                                    Icons.error,
                                    color: Colors.grey,
                                    size: 48,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      // Gradient overlay for caption
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.5, 1.0],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        left: 12,
                        right: 12,
                        child: Text(
                          widget.photo.description,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            shadows: [
                              Shadow(
                                blurRadius: 4.0,
                                color: Colors.black,
                                offset: Offset(1.0, 1.0),
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          widget.photo.isLiked ? Icons.favorite : Icons.favorite_border,
                          color: widget.photo.isLiked ? Colors.red : Colors.grey[400],
                        ),
                        onPressed: () {
                          // Toggle like
                          final photoNotifier = ref.read(photosNotifierProvider.notifier);
                          photoNotifier.toggleLike(widget.photo.id);
                        },
                      ),
                      Text(
                        '${widget.photo.likes}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatTimestamp(widget.photo.uploadDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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

  void _showPhotoDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PhotoDetailModal(photo: widget.photo),
    );
  }
} 