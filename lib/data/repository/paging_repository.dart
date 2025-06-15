import 'dart:async';
import 'dart:math';

import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:personal_project/domain/model/video_model.dart';
import 'package:personal_project/domain/reporsitory/video_repository.dart';
import 'package:personal_project/domain/services/firebase/firebase_service.dart';
import 'package:personal_project/presentation/ui/video/list_video/bloc/paging_bloc.dart';
import 'package:personal_project/utils/debug_mode_print.dart';

class PagingRepository {
  PagingController<int, Video>? controller;
  VideoRepository videoRepository = VideoRepository();
  final int _pageSize = 4;
  bool isLastPage = false;

  final List<DocumentSnapshot> _videoFromFollowing = [];
  final List<DocumentSnapshot> _videoFromGame = [];
  final List<DocumentSnapshot> _videoNotFromGame = [];
  final List<DocumentSnapshot> _videoGameIsNull = [];

  List<String> _gameTitleList = [];
  late Future<List<String>> _followingUid;

  final List<CachedVideoPlayerPlusController> _videoPlayerControllers = [];
  final List<Video> _videos = [];

  List<CachedVideoPlayerPlusController> get videoPlayerControllers => _videoPlayerControllers;

  List<Video> get videos => _videos;

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

  void initPagingController(VideoFrom from) async {
    _gameTitleList = await _getGameTitleList();
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
        List<DocumentSnapshot> thirdList = await getListVideoGameIsNull(limit: _pageSize - newItems.length);
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
    List<String> gameList = [];
    if (_gameTitleList.isEmpty) {
      gameList = await _getGameTitleList();
      _gameTitleList = gameList;
    } else {
      gameList = _gameTitleList;
    }
    if (gameList.isEmpty) {
      return [];
    }
    try {
      if (_videoFromGame.isEmpty) {
        querySnapshot =
            await firebaseFirestore.collection('videos').where('game.title', whereIn: gameList).limit(limit).get();
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
    List<String> gameList = [];
    if (_gameTitleList.isEmpty) {
      gameList = await _getGameTitleList();
      _gameTitleList = gameList;
    } else {
      gameList = _gameTitleList;
    }
    if (gameList.isEmpty) {
      return [];
    }
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
            .startAfterDocument(_videoNotFromGame.last)
            .where('game.title', whereNotIn: gameList)
            .limit(limit)
            .get();
      } else if (_videoNotFromGame.isEmpty && gameList.isEmpty) {
        querySnapshot =
            await firebaseFirestore.collection('videos').where('game', isNull: false).limit(limit).get();
      } else {
        querySnapshot = await firebaseFirestore
            .collection('videos')
            .startAfterDocument(_videoNotFromGame.last)
            .where('game', isNull: false)
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
    List<String> gameList = [];
    if (_gameTitleList.isEmpty) {
      gameList = await _getGameTitleList();
      _gameTitleList = gameList;
    } else {
      gameList = _gameTitleList;
    }
    try {
      if (_videoGameIsNull.isEmpty) {
        querySnapshot =
            await firebaseFirestore.collection('videos').where('game', isNull: true).limit(limit).get();
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

  Future<List<Video>?> getVideos({
    required VideoFrom from,
  }) async {
    try {
      List<Video> listVideo = [];
      List<DocumentSnapshot> newItems = [];
      if (from == VideoFrom.following) {
        newItems = await getListVideoFromFollowing(limit: _pageSize);
      } else {
        Random random = Random();
        // int limit1 = random.nextInt(3) + 1;
        // newItems = await getListVideoByGame(limit: limit1);
        List<DocumentSnapshot> thirdList = await getRestVideos(_pageSize - newItems.length);
        _videoFromGame.addAll(thirdList);
        newItems.addAll(thirdList);
      }

      listVideo = newItems.map((e) => Video.fromSnap(e)).toList();

      return listVideo;
    } catch (error) {
      controller!.error = error;
      return null;
    }
  }

  Future<List<Video>> loadVideos() async {
    if (isLastPage) return [];
    final List<Video>? newVideos = await getVideos(from: VideoFrom.forYou);

    if ((newVideos?.length ?? 0) < _pageSize) {
      isLastPage = true;
      return [];
    }

    debugModePrint('Videos loaded: ${newVideos?.length ?? 0}');

    List<String> likedVideos = [];

    final String uid = firebaseAuth.currentUser?.uid ?? '';
    if (newVideos != null) {
      _videos.addAll(newVideos);
      final likesDoc = await firebaseFirestore
          .collection('likes')
          .where('postId', whereIn: newVideos.map((e) => e.id).toList())
          .where('uid', isEqualTo: uid)
          .get();

      if (likesDoc.docs.isNotEmpty) {
        for (var element in likesDoc.docs) {
          likedVideos.add(element['uid']);
        }
      }

      for (var video in newVideos) {
        CachedVideoPlayerPlusController controller = CachedVideoPlayerPlusController.networkUrl(
          Uri.parse(video.videoUrl),
        );
        video.isLiked = likedVideos.contains(uid);
        _videoPlayerControllers.add(controller);
      }
      debugModePrint('VideosConteroller loaded: ${_videoPlayerControllers.length ?? 0}');
    }
    return newVideos ?? [];
  }

  Future<void> loadInitialVideo() async {
    if (_videos.isEmpty) {
      await loadVideos();
      await _videoPlayerControllers.first.initialize();
      _videoPlayerControllers.first.setLooping(true);
      _videoPlayerControllers[1].initialize();
      _videoPlayerControllers[1].setLooping(true);
    }
  }

  void likeVideo(
    String video,
  ) {
    Video videoItem = _videos.firstWhere((element) => element.id! == video);
    bool? isLiked = videoItem.isLiked;
    int count = videoItem.likesCount;

    videoItem.isLiked = !isLiked;
    videoItem.likesCount = isLiked ? count - 1 : count + 1;
  }

  void replaceControllerAtIndex(int index, CachedVideoPlayerPlusController newController) {
    _videoPlayerControllers.removeAt(index);
    _videoPlayerControllers.insert(index, newController);
  }

  CachedVideoPlayerPlusController setUpVideoController(String url) {
    return CachedVideoPlayerPlusController.networkUrl(
      Uri.parse(url),
    );
  }

  CachedVideoPlayerPlusController getControllerAtIndex(int index) {
    return _videoPlayerControllers[index];
  }

  Future<List<DocumentSnapshot>> getRestVideos(int limit) async {
    List<DocumentSnapshot> listDocs = [];

    QuerySnapshot querySnapshot;

    try {
      if (_videoFromGame.isEmpty) {
        querySnapshot = await firebaseFirestore.collection('videos').limit(limit).get();
      } else {
        querySnapshot = await firebaseFirestore
            .collection('videos')
            .orderBy('createdAt', descending: true)
            .startAfterDocument(_videoFromGame.last)
            .limit(limit)
            .get();
      }

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
}
