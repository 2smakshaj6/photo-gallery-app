import 'package:shared_preferences/shared_preferences.dart';

class CommentLikeService {
  static const _likedCommentsKey = 'liked_comments';

  Future<Set<String>> getLikedCommentIds() async {
    final prefs = await SharedPreferences.getInstance();
    final likedComments = prefs.getStringList(_likedCommentsKey);
    return likedComments?.toSet() ?? {};
  }

  Future<void> likeComment(String commentId) async {
    final prefs = await SharedPreferences.getInstance();
    final likedComments = (prefs.getStringList(_likedCommentsKey) ?? []).toSet();
    likedComments.add(commentId);
    await prefs.setStringList(_likedCommentsKey, likedComments.toList());
  }

  Future<void> unlikeComment(String commentId) async {
    final prefs = await SharedPreferences.getInstance();
    final likedComments = (prefs.getStringList(_likedCommentsKey) ?? []).toSet();
    likedComments.remove(commentId);
    await prefs.setStringList(_likedCommentsKey, likedComments.toList());
  }
} 