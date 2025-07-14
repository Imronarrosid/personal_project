import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:personal_project/data/repository/coment_repository.dart';
import 'package:personal_project/domain/model/comment_model.dart';

import '../../domain/model/user.dart';
import '../../utils/debug_mode_print.dart';

class ComentsPagingRepository {
  PagingController<int, Comment>? controller;
  CommentRepository commentRepository = CommentRepository();
  final int _pageSize = 11;
  final List<Comment> _currentLoadedComments = [];
  List<Comment> get currentLoadedComments => _currentLoadedComments;

  final List<Comment> _commentLocal = [];
  List<Comment> get commentLocal => _commentLocal;
  set addCommentLocal(Comment comment) => _commentLocal.add(comment);

  bool _isLatPage = false;
  get isLatPage => _isLatPage;

  void clearAllcoment() {
    commentRepository.allDocs.clear();
  }

  void initPagingController(String postId) {
    controller = PagingController(firstPageKey: 0);
    controller!.addPageRequestListener((pageKey) {
      try {
        _fetchPage(postId: postId, pageKey: pageKey);
      } catch (e) {
        debugPrint('Fetch data:$e');
      }
    });
  }

  bool isNotifyRemoveLocalComments({required List<Comment> commentsLocal}) {
    for (var element1 in currentLoadedComments) {
      for (var element2 in commentsLocal) {
        if (element1.id == element2.id) {
          return true;
        }
      }
    }
    return false;
  }

  Future<void> _fetchPage({required String postId, required int pageKey}) async {
    try {
      List<Comment> listComments = [];
      final newItems = await commentRepository.getListCommentsDocs(limit: _pageSize, postId: postId);
      final isLastPage = newItems.length < _pageSize;

      debugPrint('new items$newItems');

      for (var element in newItems) {
        listComments.add(Comment.fromSnap(element));
      }

      //Add loaded comment to [curentLoadedComments]
      for (var element in listComments) {
        currentLoadedComments.add(element);
      }

      if (isLastPage) {
        controller!.appendLastPage(listComments);
      } else {
        final nextPageKey = pageKey + newItems.length;
        controller!.appendPage(listComments, nextPageKey);
      }
    } catch (error) {
      controller!.error = error;
    }
  }

  Future<void> loadComments(
    String postId,
  ) async {
    try {
      if (isLatPage) {
        debugModePrint('is last page');
        return;
      }
      List<String> uids;
      List<User> authorNames = [];
      final newItems = await commentRepository.getListCommentsDocs(
        limit: _pageSize,
        postId: postId,
        startAfter: currentLoadedComments.isNotEmpty ? [currentLoadedComments.last.datePublished] : [],
      );
      final List<String> likedCommentIds = await commentRepository.getLikedCommentIds(
        postId: postId,
        commentIds: newItems.fold([], (previousValue, element) {
          return [...previousValue, element.id];
        }),
      );
      _isLatPage = newItems.length < _pageSize;
      uids = newItems.fold([], (previousValue, element) {
        final commentData = element.data() as Map<String, dynamic>;
        commentData['id'] == element.id;
        commentData['datePublished'] = commentData['datePublished'].millisecondsSinceEpoch;
        commentData['likesCount'] = commentData['likesCount'] ?? 0;
        commentData['isLiked'] = likedCommentIds.contains(element.id);
        return [
          ...previousValue,
          Comment.fromJson(commentData).uid,
        ];
      });
      final List<DocumentSnapshot> nameDocuments = await commentRepository.fetchDocumentsBulk(postId, uids);

      authorNames = nameDocuments.fold([], (previousValue, element) {
        final user = User.fromSnap(element);
        return [
          ...previousValue,
          user,
        ];
      });

      for (var element in newItems) {
        final commentData = element.data() as Map<String, dynamic>;
        final author = authorNames.firstWhere(
          (user) => user.id == commentData['uid'],
        );
        commentData['id'] == element.id;
        commentData['datePublished'] = commentData['datePublished'].millisecondsSinceEpoch;
        commentData['likesCount'] = commentData['likesCount'] ?? 0;
        commentData['isLiked'] = likedCommentIds.contains(element.id);
        commentData['authorName'] = author.userName;
        commentData['avatar'] = author.photo;
        _currentLoadedComments.add(Comment.fromJson(commentData));
      }
    } catch (error) {
      controller!.error = error;
    }
  }

  void likeComment({
    required String postId,
    required String commentId,
  }) async {
    try {
      Comment comment = _currentLoadedComments.firstWhere((element) => element.id == commentId);
      int index = _currentLoadedComments.indexOf(comment);
      if (comment.isLiked) {
        _currentLoadedComments[index] = comment.copyWith(isLiked: false, likesCount: comment.likesCount - 1);
      } else {
        _currentLoadedComments[index] = comment.copyWith(isLiked: true, likesCount: comment.likesCount + 1);
      }
      await commentRepository.likeComment(id: commentId, postId: postId);
    } on Exception catch (e) {
      // TODO
    }
  }

  void moveItemToFirstIndex(List<dynamic> list, dynamic item) {
    // Remove the item from its current position in the list
    list.remove(item);

    // Insert the item at the first index
    list.insert(0, item);
  }
}
