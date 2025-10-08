import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:personal_project/domain/model/comment_model.dart';
import 'package:personal_project/domain/model/reply_models.dart';
import 'package:personal_project/domain/model/user.dart';
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';
import 'package:personal_project/domain/services/firebase/firebase_service.dart';
import 'package:personal_project/domain/services/uuid_generator.dart';
import 'package:rxdart/rxdart.dart';

class CommentRepository {
  final AuthRepository authRepository;
  CommentRepository({required this.authRepository});
  final List<DocumentSnapshot> allDocs = [];
  final List<DocumentSnapshot> repliesDocs = [];
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

  Stream<List<Comment>> commmentsStream({
    required String postId,
  }) {
    try {
      if (allDocs.isNotEmpty) {
        return firebaseFirestore
            .collection('videos')
            .doc(postId)
            .collection('comments')
            .orderBy('datePublished', descending: false)
            .startAfterDocument(allDocs.first)
            .snapshots()
            .debounceTime(const Duration(seconds: 4))
            .asBroadcastStream()
            .map(
              (event) => event.docs.fold(
                [],
                (previousValue, element) => [
                  ...previousValue,
                  Comment.fromSnap(element),
                ],
              ),
            );
      } else {
        return Stream.value([]);
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
      return Stream.value([]);
    }
  }

  Future<List<DocumentSnapshot>> getListCommentsDocs({
    required String postId,
    required int limit,
    List<Object?>? startAfter,
  }) async {
    List<DocumentSnapshot> listDocs = [];

    QuerySnapshot querySnapshot;
    try {
      if (allDocs.isEmpty) {
        querySnapshot = await firebaseFirestore
            .collection('videos')
            .doc(postId)
            .collection('comments')
            .orderBy('datePublished', descending: false)
            .limit(limit)
            .get();
      } else {
        querySnapshot = await firebaseFirestore
            .collection('videos')
            .doc(postId)
            .collection('comments')
            .orderBy('datePublished', descending: false)
            .startAfter(startAfter ?? [])
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

  Future<List<String>> getLikedCommentIds({
    required String postId,
    required List<String> commentIds,
  }) async {
    try {
      final int batchSize = 10; // Firestore 'in' operator limit
      List<String> likedCommentIds = [];
      for (int i = 0; i < commentIds.length; i += batchSize) {
        commentIds = commentIds.skip(i).take(batchSize).toList();

        // Query documents using 'in' operator
        final QuerySnapshot querySnapshot = await firebaseFirestore
            .collection('commentLikes')
            .where('commentId', whereIn: commentIds)
            .where('uid', isEqualTo: authRepository.currentUser?.uid)
            .get();

        likedCommentIds = querySnapshot.docs.fold(
          [],
          (previousValue, element) {
            return [
              ...previousValue,
              element['commentId'],
            ];
          },
        );
      }
      return likedCommentIds;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  Future<Comment> postComment({
    required String commentText,
    required String postId,
  }) async {
    String uid = authRepository.currentUser!.uid;
    late Comment comment;
    try {
      if (commentText.isNotEmpty) {
        // var allDocs = await firebaseFirestore
        //     .collection('videos')
        //     .doc(postId)
        //     .collection('comments')
        //     .get();
        String len = generateUuid();
        final DocumentSnapshot doc =
            await firebaseFirestore.collection('videos').doc(postId).collection('comments').doc(len).get();
        while (doc.exists) {
          len = generateUuid();
        }
        comment = Comment(
          id: len,
          comment: commentText.trim(),
          likesCount: 0,
          uid: uid,
          datePublished: Timestamp.now(),
          repliesCount: 0,
        );
        final commentMap = comment.toJson();
        commentMap['createdAt'] = FieldValue.serverTimestamp();
        commentMap.remove('status');
        await firebaseFirestore.collection('videos').doc(postId).collection('comments').doc(len).set(commentMap);

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

  Future<void> addReply({
    required String repliedUid,
    required String postId,
    required String commentId,
    required String comment,
  }) async {
    try {
      String replyId = generateUuid();
      final DocumentSnapshot doc = await firebaseFirestore
          .collection('videos')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .doc(replyId)
          .get();
      while (doc.exists) {
        replyId = generateUuid();
      }

      final replyMap = Reply(
        id: replyId,
        comment: comment,
        repliedUserId: repliedUid,
        datePublished: Timestamp.now(),
        uid: authRepository.currentUser!.uid,
      ).toJson();

      await firebaseFirestore
          .collection('videos')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .doc(replyId)
          .set(replyMap);
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
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> likeComment({required String id, postId}) async {
    var uid = authRepository.currentUser!.uid;
    debugPrint(postId + id);
    DocumentSnapshot doc =
        await firebaseFirestore.collection('videos').doc(postId).collection('comments').doc(id).get();

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

    final DocumentReference likesreff = firebaseFirestore.collection('commentLikes').doc('${postId}_${id}_$uid');

    final DocumentReference commentReff =
        firebaseFirestore.collection('videos').doc(postId).collection('comments').doc(id);

    firebaseFirestore.runTransaction((transaction) async {
      await transaction.get(likesreff).then((value) {
        if (value.exists) {
          transaction.delete(likesreff);
          commentReff.update({
            'likesCount': FieldValue.increment(-1),
          });
        } else {
          transaction.set(likesreff, {'uid': uid, 'postId': postId, 'commentId': id});
          commentReff.update({
            'likesCount': FieldValue.increment(1),
          });
        }
      });
      // await transaction.get(documentReference).then((value) {
      //   if ((value.data() as Map<String, dynamic>).containsKey('likesCount')) {
      //     int currentCount = (value.data() as Map<String, dynamic>)['likesCount'];
      //     if ((doc.data()! as dynamic)['likes'].contains(uid)) {
      //       transaction.update(documentReference, {'likesCount': currentCount - 1});
      //     } else {
      //       transaction.update(documentReference, {'likesCount': currentCount + 1});
      //     }
      //   } else {
      //     final List<dynamic> likes = (value.data() as Map<String, dynamic>)['likes'];
      //     int currentCount = likes.length;
      //     Comment comment = Comment.fromSnap(value);
      //     if ((doc.data()! as dynamic)['likes'].contains(uid)) {
      //       transaction.set(documentReference, {...comment.toJson(), 'likesCount': currentCount - 1});
      //     } else {
      //       transaction.set(documentReference, {...comment.toJson(), 'likesCount': currentCount + 1});
      //     }
      //   }
      // });
    });
  }

  Future<void> likeReply({
    required String commentId,
    postId,
    required String replyId,
  }) async {
    var uid = authRepository.currentUser!.uid;

    DocumentReference documentReference = firebaseFirestore
        .collection('videos')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .collection('replies')
        .doc(replyId);
    DocumentReference likesreff = firebaseFirestore
        .collection('videos')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .collection('replies')
        .doc(replyId)
        .collection('likes')
        .doc(uid);

    firebaseFirestore.runTransaction((transaction) async {
      await transaction.get(likesreff).then((value) {
        if (value.exists) {
          transaction.delete(likesreff);
          transaction.update(documentReference, {
            'likesCount:': FieldValue.increment(-1),
          });
        } else {
          transaction.set(likesreff, {
            'uid': uid,
            'postId': postId,
            'commentId': commentId,
            'replyId': replyId,
            'likedAt': FieldValue.serverTimestamp(),
          });
          transaction.update(documentReference, {
            'likesCount:': FieldValue.increment(1),
          });
        }
      });
    });
  }

  Future<User> getVideoOwnerData(String uid) async {
    DocumentSnapshot docs = await firebaseFirestore.collection('users').doc(uid).get();

    return User.fromSnap(docs);
  }

  Future<List<DocumentSnapshot>> fetchDocumentsBulk(
    String videoId,
    List<String> documentIds,
  ) async {
    if (documentIds.isEmpty) {
      return [];
    }

    const int batchSize = 10; // Firestore 'in' operator limit
    List<DocumentSnapshot> fetchedUsers = [];

    try {
      // Split document IDs into batches of 10
      for (int i = 0; i < documentIds.length; i += batchSize) {
        final batch = documentIds.skip(i).take(batchSize).toList();

        // Query documents using 'in' operator
        final QuerySnapshot querySnapshot =
            await firebaseFirestore.collection('users').where(FieldPath.documentId, whereIn: batch).get();

        fetchedUsers.addAll(querySnapshot.docs);
      }

      return fetchedUsers;
    } catch (e) {
      print('Error fetching documents in bulk: $e');
      rethrow;
    }
  }

  Future<List<DocumentSnapshot>> getRepliesDocs(
    String postId,
    String commentId,
    int limit,
  ) async {
    QuerySnapshot querySnapshot;
    List<DocumentSnapshot> newReplies = [];
    if (repliesDocs.isEmpty) {
      querySnapshot = await firebaseFirestore
          .collection('videos')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .orderBy('datePublished', descending: false)
          .limit(limit)
          .get();
      if (querySnapshot.docs.isEmpty) {
        querySnapshot = await firebaseFirestore
            .collection('videos')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .collection('replies')
            .orderBy('createdAt', descending: false)
            .limit(limit)
            .get();
      }
    } else {
      querySnapshot = await firebaseFirestore
          .collection('videos')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .orderBy('datePublished', descending: false)
          .startAt([repliesDocs.last['datePublished']])
          .limit(limit)
          .get();
      if (querySnapshot.docs.isEmpty) {
        querySnapshot = await firebaseFirestore
            .collection('videos')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .collection('replies')
            .orderBy('createdAt', descending: false)
            .startAt([repliesDocs.last['datePublished']])
            .limit(limit)
            .get();
      }
      for (var element in querySnapshot.docs) {
        repliesDocs.add(element);
      }
    }
    return querySnapshot.docs;
  }
}
