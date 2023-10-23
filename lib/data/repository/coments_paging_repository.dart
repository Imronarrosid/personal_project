import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:personal_project/data/repository/coment_repository.dart';
import 'package:personal_project/data/repository/coment_repository.dart';
import 'package:personal_project/domain/model/comment_model.dart';
import 'package:personal_project/domain/model/video_model.dart';
import 'package:personal_project/domain/reporsitory/video_repository.dart';
import 'package:personal_project/domain/services/firebase/firebase_service.dart';

class ComentsPagingRepository {
  PagingController<int, Comment>? controller;
  CommentRepository commentRepository = CommentRepository();
  int _pageSize = 2;
  final List<Comment> currentLoadedComments = [];

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

  Future<void> _fetchPage(
      {required String postId, required int pageKey}) async {
    try {
      List<Comment> listComments = [];
      final newItems = await commentRepository.getListCommentsDocs(
          limit: _pageSize, postId: postId);
      final isLastPage = newItems.length < _pageSize;

      debugPrint('new items' + newItems.toString());

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
        controller!.appendPage(
            currentLoadedComments.isEmpty ? listComments : currentLoadedComments,
            nextPageKey);
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
