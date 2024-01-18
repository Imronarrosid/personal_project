import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:personal_project/domain/model/video_model.dart';
import 'package:personal_project/domain/reporsitory/video_repository.dart';

enum From { user, likes, bookmark }

class UserVideoPagingRepository {
  PagingController<int, String>? controller;
  VideoRepository videoRepository = VideoRepository();

  final int _pageSize = 4;
  final List<Video> currentLoadedVideo = [];

  clearLikeVideo() {
    videoRepository.likedVideosDocs.clear();
  }

  clearUserVideo() {
    videoRepository.allUserVideosDocs.clear();
  }

  void initPagingController(String uid, {required From from}) {
    controller = PagingController(firstPageKey: 0);
    controller!.addPageRequestListener((pageKey) {
      try {
        _fetchPage(uid: uid, pageKey: pageKey, from: from);
      } catch (e) {
        debugPrint('Fetch data video user:$e');
      }
    });
  }

  Future<void> _fetchPage(
      {required From from, required String uid, required int pageKey}) async {
    try {
      List<String> listVideo = [];
      late final List<DocumentSnapshot> newItems;
      if (from == From.user) {
        newItems =
            await videoRepository.getUserVideo(limit: _pageSize, uid: uid);

        for (var element in newItems) {
          listVideo.add(element.id);
        }
      } else if ((from == From.likes)) {
        newItems =
            await videoRepository.getLikedVideo(limit: _pageSize, uid: uid);
        for (var element in newItems) {
          listVideo.add(element.id);
        }
      }

      final isLastPage = newItems.length < _pageSize;

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
