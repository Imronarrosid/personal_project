import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:personal_project/data/repository/coment_repository.dart';
import 'package:personal_project/data/repository/coment_repository.dart';
import 'package:personal_project/domain/model/comment_model.dart';
import 'package:personal_project/domain/model/video_model.dart';
import 'package:personal_project/domain/reporsitory/video_repository.dart';

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
      List<Comment> listVideo = [];
      final newItems = await commentRepository.getListCommentsDocs(
          limit: _pageSize, postId: postId);
      final isLastPage = newItems.length < _pageSize;

      debugPrint('new items' + newItems.toString());

      for (var element in newItems) {
        listVideo.add(Comment.fromSnap(element));
      }
      if (newItems.isEmpty) {
        for (var element in currentLoadedComments) {
          listVideo.add(element);
        }
      }

      if (isLastPage) {
        controller!.appendLastPage(listVideo);
      } else {
        final nextPageKey = pageKey + newItems.length;
        controller!.appendPage(listVideo, nextPageKey);
      }
    } catch (error) {
      controller!.error = error;
    }
  }
}
