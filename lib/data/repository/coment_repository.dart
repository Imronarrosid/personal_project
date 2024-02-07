import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:personal_project/domain/model/comment_model.dart';
import 'package:personal_project/domain/model/user.dart';
import 'package:personal_project/domain/services/firebase/firebase_service.dart';
import 'package:personal_project/domain/services/uuid_generator.dart';

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

  Future<Comment> postComment({
    required String commentText,
    required String postId,
  }) async {
    String uid = firebaseAuth.currentUser!.uid;
    late Comment comment;
    try {
      if (commentText.isNotEmpty) {
        // var allDocs = await firebaseFirestore
        //     .collection('videos')
        //     .doc(postId)
        //     .collection('comments')
        //     .get();
        String len = generateUuid();
        final DocumentSnapshot doc = await firebaseFirestore
            .collection('videos')
            .doc(postId)
            .collection('comments')
            .doc(len)
            .get();
        while (doc.exists) {
          len = generateUuid();
        }
        comment = Comment(
          id: len,
          comment: commentText.trim(),
          likes: [],
          likesCount: 0,
          uid: uid,
          datePublished: Timestamp.fromDate(DateTime.now()),
          repliesCount: 0,
        );

        await firebaseFirestore
            .collection('videos')
            .doc(postId)
            .collection('comments')
            .doc(len)
            .set(comment.toJson());

        // DocumentSnapshot doc =
        //     await firebaseFirestore.collection('videos').doc(postId).get();

        // await firebaseFirestore.collection('videos').doc(postId).update({
        //   'commentCount': (doc.data() as dynamic)['commentCount'] + 1,
        // });

        DocumentReference documentReference = firebaseFirestore.collection('videos').doc(postId);
        firebaseFirestore.runTransaction((transaction) {
          return transaction.get(documentReference).then((value) {
            int currentCount = (value.data() as Map<String, dynamic>)['commentCount'];
            transaction.update(documentReference, {'commentCount': currentCount + 1});
          });
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return comment;
  }

  Future<Comment?> addReply({
    required String postId,
    required String commentId,
    required String comment,
  }) async {
    try {
      String len = generateUuid();
      final DocumentSnapshot doc = await firebaseFirestore
          .collection('videos')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .doc(len)
          .get();
      while (doc.exists) {
        len = generateUuid();
      }
      var reply = Comment(
        id: len,
        comment: comment.trim(),
        likes: [],
        likesCount: 0,
        uid: firebaseAuth.currentUser!.uid,
        datePublished: Timestamp.fromDate(DateTime.now()),
        repliesCount: 0,
      );

      await firebaseFirestore
          .collection('videos')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .doc(len)
          .set(reply.toJson());
      DocumentReference documentReference = firebaseFirestore.collection('videos').doc(postId);
      firebaseFirestore.runTransaction((transaction) {
        return transaction.get(documentReference).then((value) {
          int currentCount = (value.data() as Map<String, dynamic>)['commentCount'];
          transaction.update(documentReference, {'commentCount': currentCount + 1});
        });
      });
      DocumentReference replyReference =
          firebaseFirestore.collection('videos').doc(postId).collection('comments').doc(commentId);
      firebaseFirestore.runTransaction((transaction) {
        return transaction.get(replyReference).then((value) {
          debugPrint(Comment.fromSnap(value).toString());
          int currentRepliesCount = (value.data() as Map<String, dynamic>)['repliesCount'];
          transaction.update(replyReference, {'repliesCount': currentRepliesCount + 1});
        });
      });
      return reply;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
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
      firebaseFirestore.collection('videos').doc(postId).collection('comments').doc(id).update({
        'likes': FieldValue.arrayRemove([uid]),
      });
    } else {
      firebaseFirestore.collection('videos').doc(postId).collection('comments').doc(id).update({
        'likes': FieldValue.arrayUnion([uid]),
      });
    }
    DocumentReference documentReference =
        firebaseFirestore.collection('videos').doc(postId).collection('comments').doc(id);
    firebaseFirestore.runTransaction((transaction) {
      return transaction.get(documentReference).then((value) {
        if ((value.data() as Map<String, dynamic>).containsKey('likesCount')) {
          int currentCount = (value.data() as Map<String, dynamic>)['likesCount'];
          if ((doc.data()! as dynamic)['likes'].contains(uid)) {
            transaction.update(documentReference, {'likesCount': currentCount - 1});
          } else {
            transaction.update(documentReference, {'likesCount': currentCount + 1});
          }
        } else {
          final List<dynamic> likes = (value.data() as Map<String, dynamic>)['likes'];
          int currentCount = likes.length;
          Comment comment = Comment.fromSnap(value);
          if ((doc.data()! as dynamic)['likes'].contains(uid)) {
            transaction
                .set(documentReference, {...comment.toJson(), 'likesCount': currentCount - 1});
          } else {
            transaction
                .set(documentReference, {...comment.toJson(), 'likesCount': currentCount + 1});
          }
        }
      });
    });
  }

  Future<void> likeReply({required String id, postId, required String replyId}) async {
    var uid = firebaseAuth.currentUser!.uid;
    debugPrint(postId + id);
    DocumentSnapshot doc = await firebaseFirestore
        .collection('videos')
        .doc(postId)
        .collection('comments')
        .doc(id)
        .collection('replies')
        .doc(replyId)
        .get();

    if ((doc.data()! as dynamic)['likes'].contains(uid)) {
      firebaseFirestore
          .collection('videos')
          .doc(postId)
          .collection('comments')
          .doc(id)
          .collection('replies')
          .doc(replyId)
          .update({
        'likes': FieldValue.arrayRemove([uid]),
      });
    } else {
      firebaseFirestore
          .collection('videos')
          .doc(postId)
          .collection('comments')
          .doc(id)
          .collection('replies')
          .doc(replyId)
          .update({
        'likes': FieldValue.arrayUnion([uid]),
      });
    }
    DocumentReference documentReference = firebaseFirestore
        .collection('videos')
        .doc(postId)
        .collection('comments')
        .doc(id)
        .collection('replies')
        .doc(replyId);
    firebaseFirestore.runTransaction((transaction) {
      return transaction.get(documentReference).then((value) {
        if ((value.data() as Map<String, dynamic>).containsKey('likesCount')) {
          int currentCount = (value.data() as Map<String, dynamic>)['likesCount'];
          if ((doc.data()! as dynamic)['likes'].contains(uid)) {
            transaction.update(documentReference, {'likesCount': currentCount - 1});
          } else {
            transaction.update(documentReference, {'likesCount': currentCount + 1});
          }
        } else {
          final List<dynamic> likes = (value.data() as Map<String, dynamic>)['likes'];
          int currentCount = likes.length;
          Comment comment = Comment.fromSnap(value);
          if ((doc.data()! as dynamic)['likes'].contains(uid)) {
            transaction
                .set(documentReference, {...comment.toJson(), 'likesCount': currentCount - 1});
          } else {
            transaction
                .set(documentReference, {...comment.toJson(), 'likesCount': currentCount + 1});
          }
        }
      });
    });
  }

  Future<User> getVideoOwnerData(String uid) async {
    DocumentSnapshot docs = await firebaseFirestore.collection('users').doc(uid).get();

    return User.fromSnap(docs);
  }
}
