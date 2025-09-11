import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:personal_project/data/repository/coment_repository.dart';
import 'package:personal_project/domain/model/comment_model.dart';
import 'package:personal_project/domain/model/reply_models.dart';
import 'package:personal_project/domain/model/user.dart';
import 'package:personal_project/domain/services/firebase/firebase_service.dart';
import 'package:personal_project/domain/services/uuid_generator.dart';
import 'package:rxdart/rxdart.dart';

class RepliesRepository {
  final CommentRepository commentsRepository;
  RepliesRepository({required this.commentsRepository});

  final int limit = 5;
  final List<Reply> _replies = [];

  List<Reply> get replies => _replies;

  final List<DocumentSnapshot> _repliesDoc = [];

  final List<Reply> _repliesFromLocal = [];
  bool _isLastReply = false;

  List<DocumentSnapshot> get repliesDoc => _repliesDoc;
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
        final comment = Reply.fromJson(element.data() as Map<String, dynamic>);

        _replies.add(comment);
      }

      // setState(() {
      //   _hasMore = false;
      // });
    } catch (e) {
      debugPrint(e.toString());
    }
    return listDocs;
  }

  Future<void> loadReplies({
    required String postId,
    required String commentId,
  }) async {
    List<Reply> newReplies = [];

    QuerySnapshot querySnapshot;
    try {
      final List<User> users = [];
      final List<String> uids = [];

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
            .startAt([_replies.last.datePublished])
            .limit(limit)
            .get();
      }

      if (newReplies.length < limit) {
        _isLastReply = true;
      }

      for (var element in newReplies) {
        final reply = Reply.fromJson(element as Map<String, dynamic>);
        final uid = reply.uid;
        if (reply.repliedUserId.isNotEmpty) {
          uids.add(reply.repliedUserId);
        }

        uids.add(uid);
      }

      for (var element in querySnapshot.docs) {
        final reply = element.data() as Map<String, dynamic>;
        reply['id'] = element.id;
        reply['createdAt'] = (reply['createdAt'] as Timestamp).millisecondsSinceEpoch;

        reply['authorUseName'] = users
            .firstWhere(
              (element) => element.id == reply['authorId'],
            )
            .userName;
        reply['avatar'] = users
            .firstWhere(
              (element) => element.id == reply['authorId'],
            )
            .photo;
        reply['repliedUserName'] = users
            .firstWhere(
              (element) => element.id == reply['authorId'],
            )
            .userName;
        _replies.add(Reply.fromJson(reply));
      }

      // setState(() {
      //   _hasMore = false;
      // });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void addReply({
    required Reply reply,
  }) {
    _replies.insert(0, reply);
  }
}
