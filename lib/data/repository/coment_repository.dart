import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:personal_project/domain/model/comment_model.dart';
import 'package:personal_project/domain/services/firebase/firebase_service.dart';

class CommentRepository {
  final String postId;

  CommentRepository({required this.postId});

  getCommentOwnerData(){

  }
  getComment() async {
    firebaseFirestore
        .collection('videos')
        .doc(postId)
        .collection('comments')
        .snapshots()
        .map((QuerySnapshot query) {
      List<Comment> retValue = [];

      for (var element in query.docs) {
        retValue.add(Comment.fromSnap(element));
      }
      return retValue;
    });
  }

  postComment(String commentText) async {
    String uid = firebaseAuth.currentUser!.uid;
    try {
      if (commentText.isNotEmpty) {
        var allDocs = await firebaseFirestore
            .collection('videos')
            .doc(postId)
            .collection('comments')
            .get();
        int len = allDocs.docs.length;

        Comment comment = Comment(
            comment: commentText.trim(),
            likes: [],
            uid: uid,
            id: 'Comment $len',
            datePublished: Timestamp.fromDate(DateTime.now()));

        await firebaseFirestore
            .collection('videos')
            .doc(postId)
            .collection('comments')
            .doc('Comment $len')
            .set(comment.toJson());

        DocumentSnapshot doc =
            await firebaseFirestore.collection('videos').doc(postId).get();

        await firebaseFirestore.collection('videos').doc(postId).update({
          'commentCount': (doc.data() as dynamic)['commentCount'] + 1,
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  likeComment(String id) async {
    var uid = firebaseAuth.currentUser!.uid;
    DocumentSnapshot doc = await firebaseFirestore
        .collection('videos')
        .doc(postId)
        .collection('comments')
        .doc(id)
        .get();

    if ((doc.data()! as dynamic)['likes'].contains(uid)) {
      firebaseFirestore
          .collection('videos')
          .doc(postId)
          .collection('comments')
          .doc(id)
          .update({
        'likes': FieldValue.arrayRemove([uid]),
      });
    } else {
      firebaseFirestore
          .collection('videos')
          .doc(postId)
          .collection('comments')
          .doc(id)
          .update({
        'likes': FieldValue.arrayUnion([uid]),
      });
    }
  }
}
