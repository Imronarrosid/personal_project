import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:personal_project/domain/model/comment_model.dart';

class Reply extends Comment {
  final String repliedUid;
  Reply({
    super.id,
    required super.comment,
    required this.repliedUid,
    required super.datePublished,
    required super.likes,
    required super.likesCount,
    required super.uid,
    required super.repliesCount,
  });

  @override
  Map<String, dynamic> toJson() => {
        'comment': comment,
        'datePublished': datePublished,
        'likes': likes,
        'uid': uid,
        'id': id,
        'likesCount': likesCount,
        'repliesCount': repliesCount,
        'repliedUid': repliedUid,
      };

  static Reply fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Reply(
      repliedUid: snapshot['repliedUid'] ?? '',
      comment: snapshot['comment'],
      datePublished: snapshot['datePublished'],
      likes: snapshot['likes'],
      uid: snapshot['uid'],
      id: snap.id,
      repliesCount: snapshot['repliesCount'],
      likesCount: snapshot['likesCount'] ?? (snapshot['likes'] as List).length,
    );
  }
}
