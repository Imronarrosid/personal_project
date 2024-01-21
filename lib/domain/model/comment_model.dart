import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String comment;
  final Timestamp datePublished;
  final List likes;
  final int likesCount;
  final String uid;
  final String id;

  Comment({
    required this.comment,
    required this.datePublished,
    required this.likes,
    required this.likesCount,
    required this.uid,
    required this.id,
  });

  Map<String, dynamic> toJson() => {
        'comment': comment,
        'datePublished': datePublished,
        'likes': likes,
        'uid': uid,
        'id': id,
        'likesCount': likesCount,
      };

  static Comment fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Comment(
      comment: snapshot['comment'],
      datePublished: snapshot['datePublished'],
      likes: snapshot['likes'],
      uid: snapshot['uid'],
      id: snapshot['id'],
      likesCount: snapshot['likesCount'] ?? (snapshot['likes'] as List).length,
    );
  }
}
