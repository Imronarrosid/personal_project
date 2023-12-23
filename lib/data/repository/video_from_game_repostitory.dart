import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:personal_project/domain/model/game_fav_modal.dart';
import 'package:personal_project/domain/model/video_model.dart';
import 'package:personal_project/domain/reporsitory/video_repository.dart';

class VideoFromGameRepository {
  PagingController<int, Video>? controller;
  final VideoRepository _videoRepository = VideoRepository();
  final int _pageSize = 15;
  void clearAllVideoFromGame() {
    _videoRepository.allVideoFromGame.clear();
  }

  void initPagingController(GameFav game) {
    controller = PagingController<int, Video>(firstPageKey: 0);
    controller!.addPageRequestListener((pageKey) {
      debugPrint(_videoRepository.currentPageIndex.toString());
      try {
        _fetchPage(pageKey, game);
      } catch (e) {
        debugPrint('Fetch data:$e');
      }
    });
  }

  Future<void> _fetchPage(int pageKey, GameFav game) async {
    try {
      List<Video> listVideo = [];
      final newItems = await _videoRepository.getListVideoFromGame(
          limit: _pageSize, game: game);
      final isLastPage = newItems.length < _pageSize;

      debugPrint('new items$newItems');

      for (var element in newItems) {
        listVideo.add(Video.fromSnap(element));
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
