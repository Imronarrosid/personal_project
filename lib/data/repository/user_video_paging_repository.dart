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
        debugPrint('Fetch data video user:');
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
          debugPrint('Fetch data video user:${element.id}');
          // listVideo.add(Video.fromSnap(element));
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

      debugPrint('new items video user$newItems');

      //Add loaded comment to [curentLoadedComments]
      for (var element in listVideo) {
        // currentLoadedVideo.add(element);
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

  void moveItemToFirstIndex(List<dynamic> list, dynamic item) {
    // Remove the item from its current position in the list
    list.remove(item);

    // Insert the item at the first index
    list.insert(0, item);
  }
}
