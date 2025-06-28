import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase_service.dart';
import '../services/like_service.dart';
import '../models/photo.dart';
import '../models/comment.dart';
import '../services/comment_like_service.dart';
import '../services/ownership_service.dart';
import '../services/auth_service.dart';
import 'package:uuid/uuid.dart';

// Provides an instance of FirebaseService
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

// Provides an instance of LikeService
final likeServiceProvider = Provider<LikeService>((ref) {
  return LikeService();
});

// Provides an instance of OwnershipService
final ownershipServiceProvider = Provider<OwnershipService>((ref) {
  return OwnershipService();
});

// Provides an instance of CommentLikeService
final commentLikeServiceProvider = Provider<CommentLikeService>((ref) {
  return CommentLikeService();
});

// Provides the stream of photos from Firestore and updates their like status
final photosProvider = StreamProvider<List<Photo>>((ref) {
  final photosStream = ref.watch(firebaseServiceProvider).getPhotos();
  final likeService = ref.watch(likeServiceProvider);

  // This stream will now correctly combine photo data with local like/ownership data.
  return photosStream.asyncMap((photos) async {
    final likedPhotoIds = await likeService.getLikedPhotoIds();
    return photos
        .map((photo) => photo.copyWith(
              isLiked: likedPhotoIds.contains(photo.id),
            ))
        .toList();
  });
});

// Provides the stream of comments from Firestore and updates their like status
final commentsProvider = StreamProvider.family<List<Comment>, String>((ref, photoId) {
  final commentsStream = ref.watch(firebaseServiceProvider).getComments(photoId);
  final commentLikeService = ref.watch(commentLikeServiceProvider);

  return commentsStream.asyncMap((comments) async {
    final likedCommentIds = await commentLikeService.getLikedCommentIds();
    return comments
        .map((comment) =>
            comment.copyWith(isLiked: likedCommentIds.contains(comment.id)))
        .toList();
  });
});

// Provider for managing photo likes
final photosNotifierProvider =
    StateNotifierProvider<PhotosNotifier, AsyncValue<List<Photo>>>((ref) {
  return PhotosNotifier(ref.read(firebaseServiceProvider), ref.read(likeServiceProvider));
});

class PhotosNotifier extends StateNotifier<AsyncValue<List<Photo>>> {
  final FirebaseService _firebaseService;
  final LikeService _likeService;

  PhotosNotifier(this._firebaseService, this._likeService) : super(const AsyncValue.loading()) {
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    try {
      state = const AsyncValue.loading();
      final photosStream = _firebaseService.getPhotos();
      await for (final photos in photosStream) {
        state = AsyncValue.data(photos);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> toggleLike(String photoId) async {
    final isLiked = (await _likeService.getLikedPhotoIds()).contains(photoId);
    
    // First, update the local state in SharedPreferences
    if (isLiked) {
      await _likeService.unlikePhoto(photoId);
    } else {
      await _likeService.likePhoto(photoId);
    }

    // Then, update the like count in Firebase
    await _firebaseService.updatePhotoLike(photoId, isLiked: !isLiked);
  }
}

final commentsNotifierProvider =
    StateNotifierProvider<CommentsNotifier, AsyncValue<void>>((ref) {
  return CommentsNotifier(
    ref.read(firebaseServiceProvider),
    ref.read(commentLikeServiceProvider),
  );
});

class CommentsNotifier extends StateNotifier<AsyncValue<void>> {
  final FirebaseService _firebaseService;
  final CommentLikeService _commentLikeService;

  CommentsNotifier(this._firebaseService, this._commentLikeService)
      : super(const AsyncValue.data(null));

  Future<void> addComment(String photoId, String text, {String? parentId}) async {
    try {
      state = const AsyncValue.loading();
      await _firebaseService.addComment(photoId, text, commenterName: '', commenterNTID: '', parentId: parentId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleCommentLike(String photoId, String commentId) async {
    final isLiked = (await _commentLikeService.getLikedCommentIds()).contains(commentId);

    if (isLiked) {
      await _commentLikeService.unlikeComment(commentId);
    } else {
      await _commentLikeService.likeComment(commentId);
    }

    await _firebaseService.toggleCommentLike(photoId, commentId, isLiked: !isLiked);
  }
} 