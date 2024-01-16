import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:personal_project/domain/model/video_model.dart';
import 'package:personal_project/domain/reporsitory/video_repository.dart';
import 'package:personal_project/domain/services/firebase/firebase_service.dart';
import 'package:personal_project/presentation/ui/video/list_video/bloc/paging_bloc.dart';

class PagingRepository {
  PagingController<int, Video>? controller;
  VideoRepository videoRepository = VideoRepository();
  final int _pageSize = 15;

  final List<DocumentSnapshot> _videoFromFollowing = [];

  List<String> _followedUid = [];
  late Future<List<String>> _gameTitle;

  Future<List<String>> getFollowedUid() async {
    try {
      List<String> results = [];
      await firebaseFirestore
          .collection('users')
          .doc(firebaseAuth.currentUser!.uid)
          .collection('following')
          .get()
          .then((value) {
        for (DocumentSnapshot element in value.docs) {
          results.add(element.id);
        }
      });
      return results;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  void clearAllVideo() {
    videoRepository.allDocs.clear();
    _followedUid.clear();
  }

  void refreshPaging() {
    videoRepository.allDocs.clear();
    _followedUid.clear();
    if (controller != null) {
      controller!.refresh();
    }
  }

  void initPagingController(VideoFrom from) {
    _gameTitle = _getGameTitleList();
    controller = PagingController(firstPageKey: 0);
    controller!.addPageRequestListener((pageKey) {
      debugPrint(videoRepository.currentPageIndex.toString());
      try {
        _fetchPage(pageKey, from: from);
      } catch (e) {
        debugPrint('Fetch data:$e');
      }
    });
  }

  Future<void> _fetchPage(
    int pageKey, {
    required VideoFrom from,
  }) async {
    try {
      List<Video> listVideo = [];
      final List<DocumentSnapshot> newItems;
      if (from == VideoFrom.following) {
        newItems = await getListVideoFromFollowing(limit: _pageSize);
      } else {
        newItems = await getListVideoByGame(limit: _pageSize);
        if (newItems.isEmpty) {
          newItems.addAll(
            await getListVideoNotByGame(limit: _pageSize),
          );
          newItems.addAll(
            await videoRepository.getListVideo(limit: _pageSize),
          );
        }
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

  Future<List<DocumentSnapshot>> getListVideoFromFollowing(
      {required int limit}) async {
    debugPrint(_followedUid.toString());
    List<DocumentSnapshot> listDocs = [];

    QuerySnapshot querySnapshot;
    try {
      if (_videoFromFollowing.isEmpty) {
        querySnapshot = await firebaseFirestore
            .collection('videos')
            .where('uid', whereIn: await getFollowedUid())
            .orderBy('createdAt', descending: true)
            .limit(limit)
            .get();
      } else {
        querySnapshot = await firebaseFirestore
            .collection('videos')
            .where('uid', whereIn: _followedUid)
            .orderBy('createdAt', descending: true)
            .startAfterDocument(_videoFromFollowing.last)
            .limit(limit)
            .get();
      }

      ///List to get last documet
      _videoFromFollowing.addAll(querySnapshot.docs);

      //list that send to infinity list package
      listDocs.addAll(querySnapshot.docs);
      // setState(() {
      //   _hasMore = false;
      // });
      for (var element in querySnapshot.docs) {
        debugPrint(Video.fromSnap(element).videoUrl);
      }
      for (var element in _videoFromFollowing) {
        debugPrint('_LISTDOCS${Video.fromSnap(element).videoUrl}');
      }
      debugPrint('DOCUMENTSNAP ${querySnapshot.docs}');
    } catch (e) {
      debugPrint(e.toString());
    }
    return listDocs;
  }

  Future<List<DocumentSnapshot>> getListVideoByGame(
      {required int limit}) async {
    debugPrint(_followedUid.toString());
    List<DocumentSnapshot> listDocs = [];

    QuerySnapshot querySnapshot;

    List<String> gameList = await _gameTitle;
    if (gameList.isEmpty) {
      return [];
    }
    try {
      if (videoRepository.allDocs.isEmpty) {
        querySnapshot = await firebaseFirestore
            .collection('videos')
            .where('game.title', whereIn: gameList)
            .limit(limit)
            .get();
      } else {
        querySnapshot = await firebaseFirestore
            .collection('videos')
            .where('game.title', whereIn: gameList)
            .startAfterDocument(videoRepository.allDocs.last)
            .limit(limit)
            .get();
      }

      ///List to get last documet
      videoRepository.allDocs.addAll(querySnapshot.docs);

      //list that send to infinity list package
      listDocs.addAll(querySnapshot.docs);

      return listDocs;
    } catch (e) {
      debugPrint(e.toString());
      if (gameList.isNotEmpty) {
        rethrow;
      }
      return [];
      // return listDocs;
    }
  }

  Future<List<DocumentSnapshot>> getListVideoNotByGame(
      {required int limit}) async {
    debugPrint(_followedUid.toString());
    List<DocumentSnapshot> listDocs = [];

    QuerySnapshot querySnapshot;
    List<String> gameList = await _gameTitle;

    if (gameList.isEmpty) {
      return [];
    }
    try {
      if (videoRepository.allDocs.isEmpty) {
        querySnapshot = await firebaseFirestore
            .collection('videos')
            .where('game.title', whereNotIn: gameList)
            .limit(limit)
            .get();
      } else {
        querySnapshot = await firebaseFirestore
            .collection('videos')
            .where('game.title', whereNotIn: gameList)
            .startAfterDocument(videoRepository.allDocs.last)
            .limit(limit)
            .get();
      }

      ///List to get last documet
      videoRepository.allDocs.addAll(querySnapshot.docs);

      //list that send to infinity list package
      listDocs.addAll(querySnapshot.docs);
      // setState(() {
      //   _hasMore = false;
      // });

      return listDocs;
    } catch (e) {
      debugPrint(e.toString());
      if (gameList.isNotEmpty) {
        rethrow;
      }
      return [];
    }
  }

  Future<List<String>> _getGameTitleList() async {
    try {
      List<String> game = [];
      DocumentSnapshot documentSnapshot = await firebaseFirestore
          .collection('users')
          .doc(firebaseAuth.currentUser!.uid)
          .collection('otherInfo')
          .doc('gameFav')
          .get();

      for (String element in documentSnapshot['titles']) {
        game.add(element);
      }
      return game;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }
}
