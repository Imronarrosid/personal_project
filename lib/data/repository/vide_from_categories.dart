import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:personal_project/domain/model/category_model.dart';
import 'package:personal_project/domain/model/video_model.dart';
import 'package:personal_project/domain/reporsitory/video_repository.dart';
import 'package:personal_project/domain/services/firebase/firebase_service.dart';

class VBCREpository {
  PagingController<int, Video>? controller;
  final VideoRepository _videoRepository = VideoRepository();
  final List<DocumentSnapshot> allVideoFromCategory = [];
  final List<DocumentSnapshot> _videoFromGame = [];
  final int _pageSize = 15;
  void clearAllVideoFromGame() {
    _videoRepository.allVideoFromGame.clear();
  }

  void initPagingController(VideoCategory category) {
    controller = PagingController<int, Video>(firstPageKey: 0);
    controller!.addPageRequestListener((pageKey) {
      debugPrint(_videoRepository.currentPageIndex.toString());
      try {
        _fetchPage(pageKey, category);
      } catch (e) {
        debugPrint('Fetch data:$e');
      }
    });
  }

//
  Future<void> _fetchPage(int pageKey, VideoCategory category) async {
    try {
      List<Video> listVideo = [];
      final List<DocumentSnapshot<Object?>> newItems;
      if (category.category != null) {
        newItems = await getListVideoFromCategory(limit: _pageSize, category: category);
      } else {
        newItems = await getListVideoByGame(limit: _pageSize, category: category);
      }
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

  Future<List<DocumentSnapshot>> getListVideoFromCategory(
      {required int limit, required VideoCategory category}) async {
    List<DocumentSnapshot> listDocs = [];

    QuerySnapshot querySnapshot;
    try {
      if (allVideoFromCategory.isEmpty) {
        querySnapshot = await firebaseFirestore
            .collection('videos')
            .where('category', isEqualTo: category.category)
            .orderBy('createdAt', descending: true)
            .limit(limit)
            .get();
      } else {
        querySnapshot = await firebaseFirestore
            .collection('videos')
            .where('category', isEqualTo: category.category)
            .orderBy('createdAt', descending: true)
            .startAfterDocument(allVideoFromCategory.last)
            .limit(limit)
            .get();
      }

      ///List to get last documet
      allVideoFromCategory.addAll(querySnapshot.docs);

      //list that send to infinity list package
      listDocs.addAll(querySnapshot.docs);

      for (var element in querySnapshot.docs) {
        debugPrint(Video.fromSnap(element).videoUrl);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return listDocs;
  }

  Future<List<DocumentSnapshot>> getListVideoByGame(
      {required int limit, required VideoCategory category}) async {
    List<DocumentSnapshot> listDocs = [];

    QuerySnapshot querySnapshot;

    try {
      if (_videoFromGame.isEmpty) {
        querySnapshot = await firebaseFirestore
            .collection('videos')
            .where('game.title', isEqualTo: category.gameFav!.gameTitle)
            .limit(limit)
            .get();
      } else {
        querySnapshot = await firebaseFirestore
            .collection('videos')
            .where('game.title', isEqualTo: category.gameFav!.gameTitle)
            .startAfterDocument(_videoFromGame.last)
            .limit(limit)
            .get();
      }

      ///List to get last documet
      _videoFromGame.addAll(querySnapshot.docs);

      //list that send to infinity list package
      listDocs.addAll(querySnapshot.docs);

      return listDocs;
    } catch (e) {
      debugPrint(e.toString());

      return [];
      // return listDocs;
    }
  }
}
