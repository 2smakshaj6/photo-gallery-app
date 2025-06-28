import 'package:shared_preferences/shared_preferences.dart';

class LikeService {
  static const _likedPhotosKey = 'liked_photos';

  Future<Set<String>> getLikedPhotoIds() async {
    final prefs = await SharedPreferences.getInstance();
    final likedPhotos = prefs.getStringList(_likedPhotosKey);
    return likedPhotos?.toSet() ?? {};
  }

  Future<void> likePhoto(String photoId) async {
    final prefs = await SharedPreferences.getInstance();
    final likedPhotos = (prefs.getStringList(_likedPhotosKey) ?? []).toSet();
    likedPhotos.add(photoId);
    await prefs.setStringList(_likedPhotosKey, likedPhotos.toList());
  }

  Future<void> unlikePhoto(String photoId) async {
    final prefs = await SharedPreferences.getInstance();
    final likedPhotos = (prefs.getStringList(_likedPhotosKey) ?? []).toSet();
    likedPhotos.remove(photoId);
    await prefs.setStringList(_likedPhotosKey, likedPhotos.toList());
  }
} 