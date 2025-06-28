import 'dart:typed_data';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/photo.dart';
import '../models/comment.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Photos collection
  CollectionReference get _photosCollection => _firestore.collection('photos');

  // Get all photos
  Stream<List<Photo>> getPhotos() {
    return _photosCollection
        .orderBy('uploadDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Photo.fromFirestore(doc)).toList();
    });
  }

  // Upload photo from bytes (for web)
  Future<String> uploadPhotoBytes(Uint8List imageBytes, String fileName, Photo photo) async {
    try {
      final ref = _storage.ref('photos/$fileName');
      await ref.putData(imageBytes);
      final imageUrl = await ref.getDownloadURL();
      final ownerToken = DateTime.now().millisecondsSinceEpoch.toString();
      final docRef = await _firestore.collection('photos').add({
        'imageUrl': imageUrl,
        'description': photo.description,
        'likes': photo.likes,
        'uploadDate': FieldValue.serverTimestamp(),
        'ownerToken': ownerToken,
        'uploaderName': photo.uploaderName,
        'uploaderNTID': photo.uploaderNTID,
        'uploaderEmail': photo.uploaderEmail,
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to upload photo: $e');
    }
  }

  // Delete photo (note: this is now an open action)
  Future<void> deletePhoto(String photoId, String imageUrl) async {
    try {
      // Delete from Firestore
      await _firestore.collection('photos').doc(photoId).delete();
      // Delete from Firebase Storage
      await _storage.refFromURL(imageUrl).delete();
    } catch (e) {
      // Don't throw if it's just a not-found error, as the file might already be gone.
      if (e is FirebaseException && e.code != 'object-not-found') {
        throw Exception('Failed to delete photo: $e');
      }
    }
  }

  Future<void> updatePhotoLike(String photoId, {required bool isLiked}) async {
    try {
      await _firestore.collection('photos').doc(photoId).update({
        'likes': FieldValue.increment(isLiked ? 1 : -1),
      });
    } catch (e) {
      throw Exception('Failed to update photo like: $e');
    }
  }

  // Comments
  Stream<List<Comment>> getComments(String photoId) {
    return _firestore
        .collection('photos')
        .doc(photoId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Comment.fromFirestore(doc))
            .toList());
  }

  Future<void> addComment(String photoId, String text, {required String commenterName, required String commenterNTID, String? parentId}) async {
    try {
      await _firestore
          .collection('photos')
          .doc(photoId)
          .collection('comments')
          .add({
        'photoId': photoId,
        'text': text,
        'parentId': parentId,
        'likeCount': 0,
        'timestamp': FieldValue.serverTimestamp(),
        'commenterName': commenterName,
        'commenterNTID': commenterNTID,
      });
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  Future<void> toggleCommentLike(String photoId, String commentId, {required bool isLiked}) async {
    try {
      await _firestore
          .collection('photos')
          .doc(photoId)
          .collection('comments')
          .doc(commentId)
          .update({
        'likeCount': FieldValue.increment(isLiked ? 1 : -1),
      });
    } catch (e) {
      throw Exception('Failed to toggle comment like: $e');
    }
  }

  Future<void> deleteComment(String photoId, String commentId) async {
    try {
      await _firestore
          .collection('photos')
          .doc(photoId)
          .collection('comments')
          .doc(commentId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete comment: $e');
    }
  }

  Future<String> replacePhoto(String oldImageUrl, Uint8List newImageBytes) async {
    try {
      // Delete the old image from storage
      await _storage.refFromURL(oldImageUrl).delete();
      // Upload the new image
      final newImageRef = _storage.ref('photos/${DateTime.now().millisecondsSinceEpoch}');
      await newImageRef.putData(newImageBytes);
      return await newImageRef.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to replace photo: $e');
    }
  }

  Future<void> updatePhotoUrl(String photoId, String newUrl) async {
    try {
      await _firestore.collection('photos').doc(photoId).update({
        'imageUrl': newUrl,
      });
    } catch (e) {
      throw Exception('Failed to update photo URL: $e');
    }
  }

  Future<void> updatePhotoDescription(String photoId, String newDescription) async {
    try {
      await _firestore.collection('photos').doc(photoId).update({
        'description': newDescription,
      });
    } catch (e) {
      throw Exception('Failed to update description: $e');
    }
  }
}