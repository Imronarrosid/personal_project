import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment_model.freezed.dart';
part 'comment_model.g.dart';

@JsonSerializable()
@freezed
class Comment with _$Comment {
  final String comment;
  final int datePublished;
  final List likes;
  final String uid;
  final String? id;
  final int repliesCount;
  final int likesCount;
  final bool isLiked;
  String authorName;
  String? avatar;

  Comment({
    required this.comment,
    required this.datePublished,
    required this.likes,
    this.likesCount = 0,
    required this.uid,
    this.id,
    required this.repliesCount,
    this.authorName = '',
    this.avatar,
    this.isLiked = false,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);

  Map<String, dynamic> toJson() => _$CommentToJson(this);

  // Map<String, dynamic> toJson() => {
  //       'comment': comment,
  //       'datePublished': datePublished,
  //       'likes': likes,
  //       'uid': uid,
  //       'id': id,
  //       'likesCount': likesCount,
  //       'repliesCount': repliesCount,
  //       'authorName': authorName,
  //     };

  static Comment fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Comment(
      comment: snapshot['comment'],
      datePublished: snapshot['datePublished'].millisecondsSinceEpoch,
      likes: snapshot['likes'],
      uid: snapshot['uid'],
      id: snap.id,
      repliesCount: snapshot['repliesCount'],
      authorName: snapshot['authorName'] ?? '',
      likesCount: snapshot['likesCount'] ?? (snapshot['likes'] as List).length,
    );
  }

  // Comment copyWith({
  //   String? comment,
  //   Timestamp? datePublished,
  //   List? likes,
  //   int? likesCount,
  //   String? uid,
  //   String? id,
  //   int? repliesCount,
  //   String? authorName,
  //   String? avatar,
  // }) {
  //   return Comment(
  //     comment: comment ?? this.comment,
  //     datePublished: datePublished ?? this.datePublished,
  //     likes: likes ?? this.likes,
  //     likesCount: likesCount ?? this.likesCount,
  //     uid: uid ?? this.uid,
  //     id: id ?? this.id,
  //     repliesCount: repliesCount ?? this.repliesCount,
  //     authorName: authorName ?? this.authorName,
  //     avatar: avatar ?? this.avatar,
  //   );
  // }
}
