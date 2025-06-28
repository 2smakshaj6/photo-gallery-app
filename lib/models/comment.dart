import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String photoId;
  final String text;
  final DateTime timestamp;
  final int likeCount;
  final String? parentId; // For threaded replies
  final bool isLiked; // For local state
  final String commenterName;
  final String commenterNTID;

  Comment({
    required this.id,
    required this.photoId,
    required this.text,
    required this.timestamp,
    required this.commenterName,
    required this.commenterNTID,
    this.likeCount = 0,
    this.parentId,
    this.isLiked = false, // Default to not liked
  });

  factory Comment.fromFirestore(DocumentSnapshot doc, {bool isLiked = false}) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      photoId: data['photoId'] ?? '',
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likeCount: data['likeCount'] ?? 0,
      parentId: data['parentId'],
      isLiked: isLiked,
      commenterName: data['commenterName'] ?? 'Anonymous',
      commenterNTID: data['commenterNTID'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'photoId': photoId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'likeCount': likeCount,
      'commenterName': commenterName,
      'commenterNTID': commenterNTID,
      if (parentId != null) 'parentId': parentId,
    };
  }

  Comment copyWith({
    int? likeCount,
    bool? isLiked,
    String? commenterName,
    String? commenterNTID,
  }) {
    return Comment(
      id: id,
      photoId: photoId,
      text: text,
      timestamp: timestamp,
      parentId: parentId,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      commenterName: commenterName ?? this.commenterName,
      commenterNTID: commenterNTID ?? this.commenterNTID,
    );
  }
} 