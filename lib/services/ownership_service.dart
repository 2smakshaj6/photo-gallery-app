import 'package:shared_preferences/shared_preferences.dart';

class OwnershipService {
  static const _ownedPhotosKey = 'owned_photos';

  // Fetches a map of photoId -> ownerToken
  Future<Map<String, String>> getOwnedPhotoTokens() async {
    final prefs = await SharedPreferences.getInstance();
    final ownedPhotosList = prefs.getStringList(_ownedPhotosKey) ?? [];
    final Map<String, String> ownedPhotosMap = {};
    for (String entry in ownedPhotosList) {
      final parts = entry.split(':');
      if (parts.length == 2) {
        ownedPhotosMap[parts[0]] = parts[1];
      }
    }
    return ownedPhotosMap;
  }

  // Adds a new photo and its token to local storage
  Future<void> addOwnedPhoto(String photoId, String ownerToken) async {
    final prefs = await SharedPreferences.getInstance();
    final ownedPhotosList = prefs.getStringList(_ownedPhotosKey) ?? [];
    ownedPhotosList.add('$photoId:$ownerToken');
    await prefs.setStringList(_ownedPhotosKey, ownedPhotosList);
  }

  // Removes a photo from local storage after deletion
  Future<void> removeOwnedPhoto(String photoId) async {
    final prefs = await SharedPreferences.getInstance();
    final ownedPhotosList = prefs.getStringList(_ownedPhotosKey) ?? [];
    ownedPhotosList.removeWhere((entry) => entry.startsWith('$photoId:'));
    await prefs.setStringList(_ownedPhotosKey, ownedPhotosList);
  }

  // Check if user owns a specific photo
  Future<bool> isOwner(String photoId) async {
    final ownedTokens = await getOwnedPhotoTokens();
    return ownedTokens.containsKey(photoId);
  }
} 