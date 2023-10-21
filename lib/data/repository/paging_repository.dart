import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:personal_project/domain/model/video_model.dart';
import 'package:personal_project/domain/reporsitory/video_repository.dart';

class PagingRepository {
  PagingController<int, Video>? controller;
  VideoRepository videoRepository = VideoRepository();
  int _pageSize = 2;
  final List<Video> currentLoadedVideo = [];

  void initPagingController() {
    controller = PagingController(firstPageKey: 0);
    controller!.addPageRequestListener((pageKey) {
      debugPrint(videoRepository.currentPageIndex.toString());
      try {
        _fetchPage(pageKey);
      } catch (e) {
        debugPrint('Fetch data:$e');
      }
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      List<Video> listVideo = [];
      final newItems = await videoRepository.getListVideo(limit: _pageSize);
      final isLastPage = newItems.length < _pageSize;

      debugPrint('new items' + newItems.toString());

      for (var element in newItems) {
        listVideo.add(Video.fromSnap(element));
      }
      if (newItems.isEmpty) {
        for (var element in currentLoadedVideo) {
          listVideo.add(element);
          debugPrint('current loaded' + element.videoUrl);
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
