import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:personal_project/domain/model/game_fav_modal.dart';
import 'package:personal_project/domain/model/user.dart';
import 'package:personal_project/domain/model/video_model.dart';
import 'package:personal_project/domain/services/firebase/firebase_service.dart';
import 'package:personal_project/domain/services/uuid_generator.dart';
import 'package:personal_project/domain/usecase/vide_usecase_type.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rxdart/rxdart.dart';

class VideoRepository implements VideoUseCaseType {
  FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  final List<DocumentSnapshot> allDocs = [];

  final List<DocumentSnapshot> allVideoFromGame = [];

  /// list videos each user
  final List<DocumentSnapshot> allUserVideosDocs = [];
  final List<DocumentSnapshot> likedVideosDocs = [];
  final List<DocumentSnapshot> videosByGamesDocs = [];

  StreamController<double> _uploadVideoController = StreamController<double>.broadcast();

  Stream<double> get uploadProgressStream => _uploadVideoController.stream.asBroadcastStream();

  late User videoOwnerData;
  int currentPageIndex = 0;

  // _compressVideo(String videoPath) async {
  //   var comressedVideo = await VideoCompress.compressVideo(videoPath,
  //       quality: VideoQuality.MediumQuality, includeAudio: true);
  //   return comressedVideo != null ? comressedVideo.file : File(videoPath);
  //   // return response;
  // }

  // _getThumnaile(String path) async {
  //   final thumnail = await VideoCompress.getFileThumbnail(path);
  //   return thumnail;
  // }

  Future<String> _uploadToStorage(String id, File videoFile) async {
    Reference ref =
        firebaseStorage.ref().child('videos/${firebaseAuth.currentUser!.uid}').child(id);

    UploadTask uploadTask = ref.putFile(videoFile);

    uploadTask.snapshotEvents.listen((snapshot) {
      double progress = ((snapshot.bytesTransferred / snapshot.totalBytes) * 100);
      _uploadVideoController.add(progress);
    });

    TaskSnapshot snapshot = await uploadTask;
    String downloaUrl = await snapshot.ref.getDownloadURL();

    return downloaUrl;
  }

  _uploadThumnailesToStorage(String id, String thumbnail) async {
    Reference ref =
        firebaseStorage.ref().child('thumbnailes/${firebaseAuth.currentUser!.uid}').child(id);

    UploadTask uploadTask = ref.putFile(File(thumbnail));
    TaskSnapshot snapshot = await uploadTask;
    String downloaUrl = await snapshot.ref.getDownloadURL();

    return downloaUrl;
  }

  //Upload video
  @override
  uploapVideo({
    required String songName,
    required String caption,
    required String videoPath,
    required String thumbnailPath,
    String? category,
    GameFav? game,
  }) async {
    try {
      String uid = firebaseAuth.currentUser!.uid;
      //Get id

      final String uuid = generateUuid();
      String videoUrl = await _uploadToStorage("video_$uuid.mp4", File(videoPath));
      String thumnail = await _uploadThumnailesToStorage("video $uuid", thumbnailPath);

      Video video = Video(
          uid: uid,
          songName: songName,
          caption: caption,
          thumnail: thumnail,
          videoUrl: videoUrl,
          likes: [],
          commentCount: 0,
          shareCount: 0,
          viewsCount: 0,
          likesCount: 0,
          createdAt: FieldValue.serverTimestamp(),
          game: game,
          views: [],
          category: category ?? '');

      await firebaseFirestore.collection('videos').doc().set(video.toJson()).then((_) {
        debugPrint('uploaded');
      });
      _uploadVideoController.close();
      _uploadVideoController = StreamController<double>.broadcast();
    } catch (e) {
      debugPrint(e.toString());
      _uploadVideoController.close();
      rethrow;
    }
  }

  Future<List<DocumentSnapshot>> getListVideo({required int limit}) async {
    List<DocumentSnapshot> listDocs = [];

    QuerySnapshot querySnapshot;
    try {
      if (allDocs.isEmpty) {
        querySnapshot = await firebaseFirestore
            .collection('videos')
            .orderBy('createdAt', descending: true)
            .limit(limit)
            .get();
      } else {
        querySnapshot = await firebaseFirestore
            .collection('videos')
            .orderBy('createdAt', descending: true)
            .startAfterDocument(allDocs.last)
            .limit(limit)
            .get();
      }

      ///List to get last documet
      allDocs.addAll(querySnapshot.docs);

      //list that send to infinity list package
      listDocs.addAll(querySnapshot.docs);
      // setState(() {
      //   _hasMore = false;
      // });
      for (var element in querySnapshot.docs) {
        debugPrint(Video.fromSnap(element).videoUrl);
      }

      if (querySnapshot.docs.isEmpty && querySnapshot.metadata.isFromCache) {
        throw ErrorDescription('Error');
      }
      return listDocs;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<List<Video>> getVideoSuggestion(int limit) async {
    try {
      final List<Video> videos = [];
      final QuerySnapshot querySnapshot = await firebaseFirestore
          .collection('videos')
          .orderBy('likesCount', descending: true)
          .limit(limit)
          .get();

      debugPrint(querySnapshot.docs.toString());
      for (var element in querySnapshot.docs) {
        videos.add(Video.fromSnap(element));
      }
      return videos;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  Future<List<DocumentSnapshot>> getListVideoFromGame(
      {required int limit, required GameFav game}) async {
    List<DocumentSnapshot> listDocs = [];

    QuerySnapshot querySnapshot;
    try {
      if (allVideoFromGame.isEmpty) {
        querySnapshot = await firebaseFirestore
            .collection('videos')
            .where('game', isEqualTo: {
              'icon': game.gameImage,
              'title': game.gameTitle,
            })
            .orderBy('createdAt', descending: true)
            .limit(limit)
            .get();
      } else {
        querySnapshot = await firebaseFirestore
            .collection('videos')
            .where('game', isEqualTo: {
              'icon': game.gameImage,
              'title': game.gameTitle,
            })
            .orderBy('createdAt', descending: true)
            .startAfterDocument(allVideoFromGame.last)
            .limit(limit)
            .get();
      }

      ///List to get last documet
      allVideoFromGame.addAll(querySnapshot.docs);

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

  Future<void> deleteVideo(
    String postId,
    String videoUrl,
    String thumbnailUrl,
  ) async {
    try {
      await firebaseFirestore.collection('videos').doc(postId).delete();
      Reference videoRef = firebaseStorage.refFromURL(videoUrl);
      Reference thumnailRef = firebaseStorage.refFromURL(thumbnailUrl);
      videoRef.delete();
      thumnailRef.delete();
    } catch (e) {
      rethrow;
    }
  }

  Stream<Video>? videoStream(String postId) {
    try {
      const Duration debounceTime = Duration(seconds: 5);
      Stream<Video> debouncedStream = firebaseFirestore
          .collection('videos')
          .doc(postId)
          .snapshots()
          .map(
            (event) => Video.fromSnap(event),
          )
          .debounceTime(debounceTime)
          .asBroadcastStream();
      return debouncedStream;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<User> getVideoOwnerData(String uid) async {
    DocumentSnapshot docs = await firebaseFirestore.collection('users').doc(uid).get();
    videoOwnerData = User(
        id: docs['uid'], name: docs['name'], userName: docs['userName'], photo: docs['photoUrl']);
    return videoOwnerData;
  }

  Future<void> likeVideo(String id) async {
    try {
      DocumentSnapshot doc = await firebaseFirestore.collection('videos').doc(id).get();

      var uid = firebaseAuth.currentUser!.uid;
      // if ((doc.data()! as dynamic)['likes'].contains(uid)) {
      //   await firebaseFirestore.collection('videos').doc(id).update({
      //     'likes': FieldValue.arrayRemove([uid])
      //   });

      //   await firebaseFirestore.collection('users').doc(uid).collection('likes').doc(id).delete();
      // } else {
      //   await firebaseFirestore.collection('videos').doc(id).update({
      //     'likes': FieldValue.arrayUnion([uid])
      //   });
      // }

      DocumentReference documentReference = firebaseFirestore.collection('videos').doc(id);
      firebaseFirestore.runTransaction((transaction) {
        return transaction.get(documentReference).then((value) {
          if ((value.data() as Map<String, dynamic>).containsKey('likesCount')) {
            int currentCount = (value.data() as Map<String, dynamic>)['likesCount'];
            if ((doc.data()! as dynamic)['likes'].contains(uid)) {
              transaction.update(documentReference, {'likesCount': currentCount - 1});
              transaction.update(documentReference, {
                'likes': FieldValue.arrayRemove([uid])
              });
              firebaseFirestore.collection('users').doc(uid).collection('likes').doc(id).delete();
            } else {
              transaction.update(documentReference, {
                'likes': FieldValue.arrayUnion([uid])
              });
              transaction.update(documentReference, {'likesCount': currentCount + 1});
              firebaseFirestore
                  .collection('users')
                  .doc(uid)
                  .collection('likes')
                  .doc(id)
                  .set({'postId': id, 'likedAt': FieldValue.serverTimestamp()});
            }
          } else {
            final List<dynamic> likes = (value.data() as Map<String, dynamic>)['likes'];
            int currentCount = likes.length;
            Video video = Video.fromSnap(value);
            if ((doc.data()! as dynamic)['likes'].contains(uid)) {
              transaction
                  .set(documentReference, {...video.toJson(), 'likesCount': currentCount - 1});
            } else {
              transaction
                  .set(documentReference, {...video.toJson(), 'likesCount': currentCount + 1});
            }
          }
        });
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// double tap to like if video is liked will do nothing.
  Future<void> doubleTaplikeVideo(String id) async {
    DocumentSnapshot doc = await firebaseFirestore.collection('videos').doc(id).get();

    var uid = firebaseAuth.currentUser!.uid;
    if ((doc.data()! as dynamic)['likes'].contains(uid)) {
      // do nothing
    } else {
      await firebaseFirestore.collection('videos').doc(id).update({
        'likes': FieldValue.arrayUnion([uid])
      });
    }
  }

  Future<List<DocumentSnapshot>> getUserVideo({required String uid, required int limit}) async {
    List<DocumentSnapshot> listDocs = [];

    debugPrint('get user video $uid');

    QuerySnapshot querySnapshot;
    try {
      if (allUserVideosDocs.isEmpty) {
        querySnapshot = await firebaseFirestore
            .collection('videos')
            .where('uid', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .limit(limit)
            .get();
        debugPrint('empty');
      } else {
        querySnapshot = await firebaseFirestore
            .collection('videos')
            .where('uid', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .startAfterDocument(allUserVideosDocs.last)
            .limit(limit)
            .get();
      }
      debugPrint('get user video ${querySnapshot.docs.length}');

      ///List to get last documet
      allUserVideosDocs.addAll(querySnapshot.docs);

      //list that send to infinity list package
      listDocs.addAll(querySnapshot.docs);

      for (var element in querySnapshot.docs) {
        debugPrint(Video.fromSnap(element).videoUrl);
      }
      for (var element in allDocs) {
        debugPrint('_LISTDOCS user video${Video.fromSnap(element).videoUrl}');
      }
      debugPrint('DOCUMENTSNAP user video ${querySnapshot.docs}');
    } catch (e) {
      debugPrint('get video User error$e');
    }
    return listDocs;
  }

  Future<List<DocumentSnapshot>> getLikedVideo({required String uid, required int limit}) async {
    List<DocumentSnapshot> listDocs = [];

    debugPrint('get liked video $uid');

    QuerySnapshot querySnapshot;
    try {
      if (likedVideosDocs.isEmpty) {
        querySnapshot = await firebaseFirestore
            .collection('users')
            .doc(uid)
            .collection('likes')
            .orderBy('likedAt', descending: true)
            .limit(limit)
            .get();
        debugPrint('empty');
      } else {
        querySnapshot = await firebaseFirestore
            .collection('users')
            .doc(uid)
            .collection('likes')
            .orderBy('likedAt', descending: true)
            .startAfterDocument(likedVideosDocs.last)
            .limit(limit)
            .get();
      }
      debugPrint('get user video ${querySnapshot.docs.length}');

      ///List to get last documet
      likedVideosDocs.addAll(querySnapshot.docs);

      //list that send to infinity list package
      listDocs.addAll(querySnapshot.docs);
    } catch (e) {
      debugPrint('get video User error$e');
    }
    return listDocs;
  }

  Future<List<DocumentSnapshot>> getVideoByGames({required String game, required int limit}) async {
    List<DocumentSnapshot> listDocs = [];

    QuerySnapshot querySnapshot;
    try {
      if (likedVideosDocs.isEmpty) {
        querySnapshot = await firebaseFirestore
            .collection('videos')
            .where('games', isEqualTo: game)
            .orderBy('createdAt', descending: true)
            .limit(limit)
            .get();
        debugPrint('empty');
      } else {
        querySnapshot = await firebaseFirestore
            .collection('videos')
            .where('games', isEqualTo: game)
            .orderBy('createdAt', descending: true)
            .startAfterDocument(videosByGamesDocs.last)
            .limit(limit)
            .get();
      }
      debugPrint('get user video ${querySnapshot.docs.length}');

      ///List to get last documet
      likedVideosDocs.addAll(querySnapshot.docs);

      //list that send to infinity list package
      listDocs.addAll(querySnapshot.docs);
    } catch (e) {
      debugPrint('get video User error$e');
    }
    return listDocs;
  }

  Future<void> addViewsCount(String postId) async {
    try {
      DocumentReference documentReference = firebaseFirestore.collection('videos').doc(postId);
      firebaseFirestore.runTransaction((transaction) {
        return transaction.get(documentReference).then((value) {
          if ((value.data() as Map<String, dynamic>).containsKey('viewsCount')) {
            int currentCount = (value.data() as Map<String, dynamic>)['viewsCount'];
            transaction.update(documentReference, {'viewsCount': currentCount + 1});
          } else {
            final List<dynamic> views = (value.data() as Map<String, dynamic>)['views'];
            int currentCount = views.length;
            Video video = Video.fromSnap(value);
            transaction.set(documentReference, {...video.toJson(), 'viewsCount': currentCount + 1});
          }
        });
      });

      Map<String, dynamic> views = {
        'uid': firebaseAuth.currentUser?.uid ?? 'notAuthenticated',
        'viewsAt': Timestamp.now()
      };
      debugPrint('postId $postId');
      await firebaseFirestore.collection('videos').doc(postId).update({
        'views': FieldValue.arrayUnion([views])
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
