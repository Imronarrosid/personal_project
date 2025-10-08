import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:personal_project/data/repository/coment_repository.dart';
import 'package:personal_project/domain/model/comment_model.dart';
import 'package:personal_project/domain/model/reply_models.dart';
import 'package:personal_project/domain/model/user.dart';
import 'package:personal_project/domain/services/firebase/firebase_service.dart';
import 'package:personal_project/domain/services/uuid_generator.dart';
import 'package:personal_project/utils/debug_mode_print.dart';
import 'package:rxdart/rxdart.dart';

class RepliesRepository {
  final CommentRepository commentsRepository;
  RepliesRepository({required this.commentsRepository});

  final int limit = 1;
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

    try {
      List<User> users = [];
      Set<String> uids = {};
      Set<String> repliedUserId = {};
      List<User> repliedUsers = [];

      if (isLastReply) {
        debugModePrint('is last page');
        return;
      }
      final newItems = await commentsRepository.getRepliesDocs(
        postId,
        commentId,
        limit,
      );
      final List<String> likedCommentIds = await commentsRepository.getLikedCommentIds(
        postId: postId,
        commentIds: newItems.fold([], (previousValue, element) {
          return [...previousValue, element.id];
        }),
      );
      _isLastReply = newItems.length < limit;

      for (var element in newItems) {
        Map replyData = element.data() as Map<String, dynamic>;
        uids.add(replyData['uid'] ?? replyData['authorId']);
        repliedUserId.add(replyData['repliedUserId'] ?? replyData['repliedUid']);
      }

      final List<DocumentSnapshot> nameDocuments =
          await commentsRepository.fetchDocumentsBulk(postId, uids.toList());

      final List<DocumentSnapshot> repliedUserDocument =
          await commentsRepository.fetchDocumentsBulk(postId, repliedUserId.toList());

      users = nameDocuments.fold([], (previousValue, element) {
        final user = User.fromSnap(element);
        return [
          ...previousValue,
          user,
        ];
      });
      repliedUsers = repliedUserDocument.fold([], (previousValue, element) {
        final user = User.fromSnap(element);
        return [
          ...previousValue,
          user,
        ];
      });

      for (var element in newItems) {
        final commentData = element.data() as Map<String, dynamic>;

        final author = users.firstWhere(
          (user) => user.id == (commentData['uid'] ?? commentData['authorId']),
          orElse: () {
            return users.first;
          },
        );
        final repliedUser = users.firstWhere(
          (user) => user.id == (commentData['repliedUserId']),
          orElse: () {
            return users.first;
          },
        );
        commentData['id'] == element.id;
        commentData['datePublished'] = commentData['datePublished'];
        commentData['likesCount'] = commentData['likesCount'] ?? 0;
        commentData['isLiked'] = likedCommentIds.contains(element.id);
        commentData['authorName'] = author.userName;
        commentData['avatar'] = author.photo;
        commentData['authorId'] = author.id;
        commentData['repliedUserName'] = repliedUser.name;
        _replies.add(Reply.fromJson(commentData));
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

  Future<void> likeReply({
    required String replyId,
    required String postId,
    required String commentId,
  }) async {
    Reply reply = _replies.firstWhere((element) => element.id == replyId);
    int index = _replies.indexOf(reply);
    if (reply.isLiked) {
      _replies[index] = reply.copyWith(isLiked: false, likesCount: reply.likesCount - 1);
    } else {
      _replies[index] = reply.copyWith(isLiked: true, likesCount: reply.likesCount + 1);
    }
    await commentsRepository.likeReply(
      commentId: commentId,
      postId: postId,
      replyId: replyId,
    );
  }

  Future<void> likeReplyReset({
    required String postId,
    required String replyId,
  }) async {
    Reply reply = _replies.firstWhere((element) => element.id == replyId);
    int index = _replies.indexOf(reply);
    if (reply.isLiked) {
      _replies[index] = reply.copyWith(isLiked: false, likesCount: reply.likesCount - 1);
    } else {
      _replies[index] = reply.copyWith(isLiked: true, likesCount: reply.likesCount + 1);
    }
  }
}
