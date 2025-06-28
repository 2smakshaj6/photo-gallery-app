import 'package:cloud_firestore/cloud_firestore.dart';

class Photo {
  final String id;
  final String imageUrl;
  final String description;
  final DateTime uploadDate;
  final int likes;
  final String? ownerToken; // Secret token for ownership
  
  // User information (only visible to admin)
  final String? uploaderName;
  final String? uploaderNTID;
  final String? uploaderEmail;

  // Local state, not in Firestore
  final bool isLiked;

  Photo({
    required this.id,
    required this.imageUrl,
    required this.description,
    required this.uploadDate,
    this.likes = 0,
    this.ownerToken,
    this.uploaderName,
    this.uploaderNTID,
    this.uploaderEmail,
    this.isLiked = false,
  });

  factory Photo.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Photo(
      id: doc.id,
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
      uploadDate: (data['uploadDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likes: data['likes'] ?? 0,
      ownerToken: data['ownerToken'],
      uploaderName: data['uploaderName'],
      uploaderNTID: data['uploaderNTID'],
      uploaderEmail: data['uploaderEmail'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'imageUrl': imageUrl,
      'description': description,
      'uploadDate': Timestamp.fromDate(uploadDate),
      'likes': likes,
      if (ownerToken != null) 'ownerToken': ownerToken,
      if (uploaderName != null) 'uploaderName': uploaderName,
      if (uploaderNTID != null) 'uploaderNTID': uploaderNTID,
      if (uploaderEmail != null) 'uploaderEmail': uploaderEmail,
    };
  }

  Photo copyWith({
    String? id,
    String? imageUrl,
    String? description,
    DateTime? uploadDate,
    int? likes,
    String? ownerToken,
    String? uploaderName,
    String? uploaderNTID,
    String? uploaderEmail,
    bool? isLiked,
  }) {
    return Photo(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      uploadDate: uploadDate ?? this.uploadDate,
      likes: likes ?? this.likes,
      ownerToken: ownerToken ?? this.ownerToken,
      uploaderName: uploaderName ?? this.uploaderName,
      uploaderNTID: uploaderNTID ?? this.uploaderNTID,
      uploaderEmail: uploaderEmail ?? this.uploaderEmail,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'description': description,
      'uploadDate': uploadDate.millisecondsSinceEpoch,
      'likes': likes,
    };
  }

  factory Photo.fromMap(Map<String, dynamic> map) {
    return Photo(
      id: map['id'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      description: map['description'] ?? '',
      uploadDate: DateTime.fromMillisecondsSinceEpoch(map['uploadDate'] ?? 0),
      likes: map['likes'] ?? 0,
      ownerToken: map['ownerToken'],
      uploaderName: map['uploaderName'],
      uploaderNTID: map['uploaderNTID'],
      uploaderEmail: map['uploaderEmail'],
      isLiked: map['isLiked'] ?? false,
    );
  }
} 