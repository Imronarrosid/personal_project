import 'dart:async';
import 'dart:math';

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
  final int _pageSize = 10;

  final List<DocumentSnapshot> _videoFromFollowing = [];
  final List<DocumentSnapshot> _videoFromGame = [];
  final List<DocumentSnapshot> _videoNotFromGame = [];
  final List<DocumentSnapshot> _videoGameIsNull = [];

  late Future<List<String>> _gameTitle;
  late Future<List<String>> _followingUid;

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
    _videoFromGame.clear();
    _videoNotFromGame.clear();
    _videoGameIsNull.clear();
    _videoFromFollowing.clear();
  }

  void refreshPaging() {
    videoRepository.allDocs.clear();
  }

  void initPagingController(VideoFrom from) {
    _gameTitle = _getGameTitleList();
    _followingUid = getFollowedUid();
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
        Random random = Random();
        int limit1 = random.nextInt(4) + 1;
        int limit2 = random.nextInt(3) + 1;
        newItems = await getListVideoByGame(limit: limit1);
        List<DocumentSnapshot> secondList = await getFromUnselectedGame(limit: limit2);
        newItems.addAll(secondList);
        List<DocumentSnapshot> thirdList =
            await getListVideoGameIsNull(limit: _pageSize - newItems.length);
        newItems.addAll(thirdList);
      }

      final isLastPage = newItems.length < _pageSize;

      debugPrint('new items${newItems.length}');
      debugPrint('new items${_videoFromGame.length}');
      debugPrint('new items${_videoNotFromGame.length}');
      debugPrint('new items${_videoGameIsNull.length}');

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

  Future<List<DocumentSnapshot>> getListVideoFromFollowing({required int limit}) async {
    List<DocumentSnapshot> listDocs = [];

    QuerySnapshot querySnapshot;
    try {
      if (_videoFromFollowing.isEmpty) {
        querySnapshot = await firebaseFirestore
            .collection('videos')
            .where('uid', whereIn: await _followingUid)
            .orderBy('createdAt', descending: true)
            .limit(limit)
            .get();
      } else {
        querySnapshot = await firebaseFirestore
            .collection('videos')
            .where('uid', whereIn: await _followingUid)
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
    } catch (e) {
      debugPrint("oppp$e");
    }
    return listDocs;
  }

  Future<List<DocumentSnapshot>> getListVideoByGame({required int limit}) async {
    List<DocumentSnapshot> listDocs = [];

    QuerySnapshot querySnapshot;

    List<String> gameList = await _gameTitle;
    if (gameList.isEmpty) {
      return [];
    }
    try {
      if (_videoFromGame.isEmpty) {
        querySnapshot = await firebaseFirestore
            .collection('videos')
            .where('game.title', whereIn: gameList)
            .limit(limit)
            .get();
      } else {
        querySnapshot = await firebaseFirestore
            .collection('videos')
            .where('game.title', whereIn: gameList)
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
      if (gameList.isNotEmpty) {
        rethrow;
      }
      return [];
      // return listDocs;
    }
  }

  Future<List<DocumentSnapshot>> getFromUnselectedGame({required int limit}) async {
    List<DocumentSnapshot> listDocs = [];

    QuerySnapshot querySnapshot;
    List<String> gameList = await _gameTitle;

    try {
      if (_videoNotFromGame.isEmpty && gameList.isNotEmpty) {
        querySnapshot = await firebaseFirestore
            .collection('videos')
            .where('game.title', whereNotIn: gameList)
            .limit(limit)
            .get();
      } else if (_videoNotFromGame.isNotEmpty && gameList.isNotEmpty) {
        querySnapshot = await firebaseFirestore
            .collection('videos')
            .where('game.title', whereNotIn: gameList)
            .startAfterDocument(_videoNotFromGame.last)
            .limit(limit)
            .get();
      } else if (_videoNotFromGame.isEmpty && gameList.isEmpty) {
        querySnapshot = await firebaseFirestore
            .collection('videos')
            .where('game', isNull: false)
            .limit(limit)
            .get();
      } else {
        querySnapshot = await firebaseFirestore
            .collection('videos')
            .where('game', isNull: false)
            .startAfterDocument(_videoNotFromGame.last)
            .limit(limit)
            .get();
      }

      ///List to get last documet
      _videoNotFromGame.addAll(querySnapshot.docs);

      //list that send to infinity list package
      listDocs.addAll(querySnapshot.docs);
      // setState(() {
      //   _hasMore = false;
      // });

      return listDocs;
    } catch (e) {
      debugPrint(e.toString());

      return [];
    }
  }

  Future<List<DocumentSnapshot>> getListVideoGameIsNull({required int limit}) async {
    List<DocumentSnapshot> listDocs = [];

    QuerySnapshot querySnapshot;
    List<String> gameList = await _gameTitle;

    // if (gameList.isEmpty) {
    //   return [];
    // }
    try {
      if (_videoGameIsNull.isEmpty) {
        querySnapshot = await firebaseFirestore
            .collection('videos')
            .where('game', isNull: true)
            .limit(limit)
            .get();
      } else {
        querySnapshot = await firebaseFirestore
            .collection('videos')
            .where('game', isNull: true)
            .startAfterDocument(_videoGameIsNull.last)
            .limit(limit)
            .get();
      }

      ///List to get last documet
      _videoGameIsNull.addAll(querySnapshot.docs);

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
