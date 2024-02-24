import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:personal_project/domain/model/comment_model.dart';
import 'package:personal_project/domain/model/reply_models.dart';
import 'package:personal_project/domain/services/firebase/firebase_service.dart';
import 'package:personal_project/domain/services/uuid_generator.dart';
import 'package:personal_project/presentation/ui/comments/replies.dart';
import 'package:rxdart/rxdart.dart';

class RepliesRepository {
  final List<DocumentSnapshot> _repliesDoc = [];
  final List<Reply> _replies = [];
  final List<Reply> _repliesFromLocal = [];
  bool _isLastReply = false;

  List<DocumentSnapshot> get repliesDoc => _repliesDoc;
  List<Reply> get replies => _replies;
  List<Reply> get repliesFromLocal => _repliesFromLocal;

  set addNewReplies(Reply reply) {
    _repliesFromLocal.add(reply);
  }

  bool get isLastReply => _isLastReply;
  void clearReplies() {
    _repliesDoc.clear();
    _replies.clear();
  }

  void clearLocalReplies() {
    _repliesFromLocal.clear();
  }

  bool isNotifyRemoveLocalReplies() {
    for (var element1 in _replies) {
      for (var element2 in _repliesFromLocal) {
        if (element1.id == element2.id) {
          return true;
        }
      }
    }
    return false;
  }

  Future<List<DocumentSnapshot>> getListRepliesDocs({
    required String postId,
    required int limit,
    required String commentId,
  }) async {
    List<DocumentSnapshot> listDocs = [];

    QuerySnapshot querySnapshot;
    try {
      if (_repliesDoc.isEmpty) {
        querySnapshot = await firebaseFirestore
            .collection('videos')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .collection('replies')
            .orderBy('datePublished', descending: false)
            .limit(limit)
            .get();
      } else {
        querySnapshot = await firebaseFirestore
            .collection('videos')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .collection('replies')
            .orderBy('datePublished', descending: false)
            .startAfterDocument(_repliesDoc.last)
            .limit(limit)
            .get();
      }

      ///List to get last documet
      _repliesDoc.addAll(querySnapshot.docs);

      //list that send to infinity list package
      listDocs.addAll(querySnapshot.docs);

      if (listDocs.length < limit) {
        _isLastReply = true;
      }

      for (var element in querySnapshot.docs) {
        _replies.add(Reply.fromSnap(element));
      }

      // setState(() {
      //   _hasMore = false;
      // });
    } catch (e) {
      debugPrint(e.toString());
    }
    return listDocs;
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
      final Reply replyForLocal = Reply(
        repliedUid: repliedUid,
        id: replyId,
        comment: comment.trim(),
        likes: [],
        likesCount: 0,
        uid: firebaseAuth.currentUser!.uid,
        datePublished: Timestamp.fromDate(DateTime.now()),
        repliesCount: 0,
      );

      final Map<String, dynamic> replyToStore = {
        'comment': comment,
        'datePublished': FieldValue.serverTimestamp(),
        'likes': [],
        'uid': firebaseAuth.currentUser!.uid,
        'id': replyId,
        'likesCount': 0,
        'repliesCount': 0,
        'repliedUid': repliedUid,
      };

      await firebaseFirestore
          .collection('videos')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .doc(replyId)
          .set(replyToStore);
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
      _repliesFromLocal.add(replyForLocal);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Stream<List<Reply>> repliesStream({
    required String postId,
    required String commentId,
  }) {
    try {
      if (_repliesDoc.isNotEmpty) {
        return firebaseFirestore
            .collection('videos')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .collection('replies')
            .orderBy('datePublished', descending: false)
            .startAfterDocument(_repliesDoc.last)
            .snapshots()
            .debounceTime(const Duration(seconds: 1))
            .asBroadcastStream()
            .map(
              (event) => event.docs.fold(
                [],
                (previousValue, element) => [
                  ...previousValue,
                  Reply.fromSnap(element),
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
}
