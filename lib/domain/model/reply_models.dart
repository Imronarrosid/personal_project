import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:personal_project/domain/model/comment_model.dart';

class Reply extends Comment {
  final String? repliedUserName;
  final String repliedUserId;

  Reply({
    super.id,
    required super.comment,
    required this.repliedUserId,
    required super.uid,
    required super.datePublished,
    this.repliedUserName,
    super.authorUserName,
    super.repliesCount = 0,
    super.likesCount = 0,
    super.isLiked = false,
    super.avatar,
    super.status,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'message': comment,
        'authorId': uid,
        'repliesCount': repliesCount,
        'repliedUserId': repliedUserId,
        'likesCount': likesCount,
        'authorName': authorUserName,
        'avatar': avatar,
        'isLiked': isLiked,
        'status': status.index,
        'createdAt': datePublished,
      };

  factory Reply.fromJson(Map<String, dynamic> json) => Reply(
        id: json['id'],
        comment: json['message'],
        repliedUserId: json['repliedUserId'] as String,
        repliedUserName: json['repliedUserName'] as String,
        uid: json['authorId'] as String,
        authorUserName: json['authorName'] as String? ?? '',
        datePublished: json['createdAt'],
        repliesCount: json['repliesCount'] as int? ?? 0,
        likesCount: json['likesCount'] as int? ?? 0,
        isLiked: json['isLiked'] as bool? ?? false,
        avatar: json['avatar'] as String?,
      );

  @override
  Reply copyWith({
    String? id,
    String? comment,
    String? uid,
    String? authorUserName,
    Timestamp? datePublished,
    int? repliesCount,
    int? likesCount,
    bool? isLiked,
    String? avatar,
    Status? status,
    String? repliedUserId,
    String? repliedUserName,
  }) {
    return Reply(
      id: id ?? this.id,
      comment: comment ?? this.comment,
      repliedUserId: repliedUserId ?? this.repliedUserId,
      repliedUserName: repliedUserName ?? this.repliedUserName,
      uid: uid ?? this.uid,
      authorUserName: authorUserName ?? this.authorUserName,
      datePublished: datePublished ?? this.datePublished,
      repliesCount: repliesCount ?? this.repliesCount,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      avatar: avatar ?? this.avatar,
    );
  }
  // @override
  // Map<String, dynamic> toJson() => {
  //       'comment': comment,
  //       'datePublished': datePublished,
  //       'likes': likes,
  //       'uid': uid,
  //       'id': id,
  //       'likesCount': likesCount,
  //       'repliesCount': repliesCount,
  //       'repliedUid': repliedUid,
  //     };

  // static Reply fromSnap(DocumentSnapshot snap) {
  //   var snapshot = snap.data() as Map<String, dynamic>;
  //   return Reply(
  //     repliedUid: snapshot['repliedUid'] ?? '',
  //     comment: snapshot['comment'],
  //     datePublished: snapshot['datePublished'],
  //     likes: snapshot['likes'],
  //     uid: snapshot['uid'],
  //     id: snap.id,
  //     repliesCount: snapshot['repliesCount'],
  //     likesCount: snapshot['likesCount'] ?? (snapshot['likes'] as List).length,
  //   );
  // }
}
