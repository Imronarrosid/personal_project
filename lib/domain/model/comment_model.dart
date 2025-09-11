import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String comment;
  final Timestamp datePublished;
  final String uid;
  final String? id;
  final int repliesCount;
  final int likesCount;
  final bool isLiked;
  final Status status;
  final String? authorUserName;
  final String? avatar;

  Comment({
    this.status = Status.uploading,
    required this.comment,
    required this.datePublished,
    this.likesCount = 0,
    required this.uid,
    this.id,
    required this.repliesCount,
    this.authorUserName,
    this.avatar,
    this.isLiked = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'authorId': uid,
        'message': comment,
        'likesCount': likesCount,
        'repliesCount': repliesCount,
        'createdAt': datePublished,
        'authorName': authorUserName,
        'avatar': avatar,
        'isLiked': isLiked,
        'status': status.index,
      };

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      authorUserName: json['authorName'],
      avatar: json['avatar'],
      isLiked: json['isLiked'] ?? false,
      status: json['status'] != null ? Status.values[json['status']] : Status.uploaded,
      comment: json['message'] ?? json['comment'],
      datePublished: json['createdAt'] ?? json['datePublished'],
      uid: json['authorId'],
      id: json['id'],
      repliesCount: json['repliesCount'],
      likesCount: json['likesCount'] ?? (json['likes'] as List).length,
    );
  }
  static Comment fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Comment(
      comment: snapshot['comment'],
      datePublished: snapshot['datePublished'].millisecondsSinceEpoch,
      uid: snapshot['uid'],
      id: snap.id,
      repliesCount: snapshot['repliesCount'],
      authorUserName: snapshot['authorName'] ?? '',
      likesCount: snapshot['likesCount'] ?? (snapshot['likes'] as List).length,
    );
  }

  Comment copyWith({
    String? comment,
    Timestamp? datePublished,
    int? likesCount,
    String? uid,
    String? id,
    int? repliesCount,
    String? authorUserName,
    String? avatar,
    bool? isLiked,
    Status? status,
  }) {
    return Comment(
      comment: comment ?? this.comment,
      status: status ?? this.status,
      isLiked: isLiked ?? this.isLiked,
      datePublished: datePublished ?? this.datePublished,
      likesCount: likesCount ?? this.likesCount,
      uid: uid ?? this.uid,
      id: id ?? this.id,
      repliesCount: repliesCount ?? this.repliesCount,
      authorUserName: authorUserName ?? this.authorUserName,
      avatar: avatar ?? this.avatar,
    );
  }
}

enum Status {
  uploaded,
  uploading,
  deleted,
  error,
}

extension CommentStatusExtension on Status {
  bool get isUploading => this == Status.uploading;
  bool get isUploaded => this == Status.uploaded;
  bool get isDeleted => this == Status.deleted;
  bool get isError => this == Status.error;
}
