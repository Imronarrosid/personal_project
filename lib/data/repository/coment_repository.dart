import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:personal_project/domain/model/comment_model.dart';
import 'package:personal_project/domain/model/user.dart';
import 'package:personal_project/domain/services/firebase/firebase_service.dart';

class CommentRepository {
  final List<DocumentSnapshot> allDocs = [];
  getCommentOwnerData() {}
  getComment(String postId) async {
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

  Future<List<DocumentSnapshot>> getListCommentsDocs(
      {required String postId, required int limit}) async {
    List<DocumentSnapshot> listDocs = [];

    QuerySnapshot querySnapshot;
    try {
      if (allDocs.isEmpty) {
        querySnapshot = await firebaseFirestore
            .collection('videos')
            .doc(postId)
            .collection('comments')
            .orderBy('datePublished', descending: true)
            .limit(limit)
            .get();
      } else {
        querySnapshot = await firebaseFirestore
            .collection('videos')
            .doc(postId)
            .collection('comments')
            .orderBy('datePublished', descending: true)
            .startAfterDocument(allDocs.last)
            .limit(limit)
            .get();
      }

      ///List to get last documet
      allDocs.addAll(querySnapshot.docs);

      //list that send to infinity list package
      listDocs.addAll(querySnapshot.docs);
      // setState(() {
      //   _hasMore = false;
      // });
    } catch (e) {
      debugPrint(e.toString());
    }
    return listDocs;
  }

  Future<Comment> postComment(
      {required String commentText, required String postId}) async {
    String uid = firebaseAuth.currentUser!.uid;
    late Comment comment;
    try {
      if (commentText.isNotEmpty) {
        var allDocs = await firebaseFirestore
            .collection('videos')
            .doc(postId)
            .collection('comments')
            .get();
        int len = allDocs.docs.length;

        comment = Comment(
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
    return comment;
  }

  Future<void> likeComment({required String id, postId}) async {
    var uid = firebaseAuth.currentUser!.uid;
    debugPrint(postId + id);
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

  Future<User> getVideoOwnerData(String uid) async {
    DocumentSnapshot docs =
        await firebaseFirestore.collection('users').doc(uid).get();

    return User(
        id: docs['uid'], userName: docs['userName'], photo: docs['photoUrl']);
  }
}
