import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:personal_project/data/repository/coment_repository.dart';
import 'package:personal_project/domain/model/comment_model.dart';

class ComentsPagingRepository {
  PagingController<int, Comment>? controller;
  CommentRepository commentRepository = CommentRepository();
  final int _pageSize = 20;
  final List<Comment> _currentLoadedComments = [];
  List<Comment> get currentLoadedComments => _currentLoadedComments;

  final List<Comment> _commentLocal = [];
  List<Comment> get commentLocal => _commentLocal;
  set addCommentLocal(Comment comment) => _commentLocal.add(comment);

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
      final newItems =
          await commentRepository.getListCommentsDocs(limit: _pageSize, postId: postId);
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

  void moveItemToFirstIndex(List<dynamic> list, dynamic item) {
    // Remove the item from its current position in the list
    list.remove(item);

    // Insert the item at the first index
    list.insert(0, item);
  }
}
