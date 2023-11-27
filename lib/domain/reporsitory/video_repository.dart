import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:personal_project/domain/model/user.dart';
import 'package:personal_project/domain/model/video_model.dart';
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';
import 'package:personal_project/domain/services/firebase/firebase_service.dart';
import 'package:personal_project/domain/usecase/vide_usecase_type.dart';
import 'package:video_compress/video_compress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class VideoRepository implements VideoUseCaseType {
  FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  final List<DocumentSnapshot> allDocs = [];

  /// list videos each user
  final List<DocumentSnapshot> allUserVideosDocs = [];
  final List<DocumentSnapshot> likedVideosDocs = [];
  late User videoOwnerData;
  int currentPageIndex = 0;

  _compressVideo(String videoPath) async {
    var comressedVideo = await VideoCompress.compressVideo(videoPath,
        quality: VideoQuality.MediumQuality, includeAudio: true);
    return comressedVideo != null ? comressedVideo.file : File(videoPath);
    // return response;
  }

  _getThumnaile(String path) async {
    final thumnail = await VideoCompress.getFileThumbnail(path);
    return thumnail;
  }

  _uploadToStorage(String id, File videoFile) async {
    Reference ref = firebaseStorage
        .ref()
        .child('videos')
        .child('video${FieldValue.serverTimestamp()}');

    UploadTask uploadTask = ref.putFile(videoFile);
    TaskSnapshot snapshot = await uploadTask;
    String downloaUrl = await snapshot.ref.getDownloadURL();
    return downloaUrl;
  }

  _uploadThumnailesToStorage(String id, String videoPath) async {
    Reference ref = firebaseStorage.ref().child('thumnailes').child(id);

    UploadTask uploadTask = ref.putFile(await _getThumnaile(videoPath));
    TaskSnapshot snapshot = await uploadTask;
    if (snapshot.state == TaskState.success) {}
    String downloaUrl = await snapshot.ref.getDownloadURL();
    return downloaUrl;
  }

  //Upload video
  @override
  uploapVideo({required String songName, caption, videoPath}) async {
    var postId = 'post${FieldValue.serverTimestamp()}';
    try {
      String uid = firebaseAuth.currentUser!.uid;
      DocumentSnapshot userDoc =
          await firebaseFirestore.collection('users').doc(uid).get();
      //Get id
      var allDocs = await firebaseFirestore.collection('videos').get();
      int len = allDocs.docs.length;
      String videoUrl =
          await _uploadToStorage("video $len", await _compressVideo(videoPath));
      String thumnail =
          await _uploadThumnailesToStorage("video $len", videoPath);

      Video video = Video(
          username: (userDoc.data()! as Map<String, dynamic>)['name'],
          uid: uid,
          id: postId,
          songName: songName,
          caption: caption,
          thumnail: thumnail,
          videoUrl: videoUrl,
          profileImg: (userDoc.data()! as Map<String, dynamic>)['photo'],
          likes: [],
          commentCount: 0,
          shareCount: 0,
          createdAt: FieldValue.serverTimestamp());

      await firebaseFirestore
          .collection('videos')
          .doc()
          .set(video.toJson())
          .then((_) {
        debugPrint('uploaded');
      });
    } catch (e) {
      debugPrint(e.toString());
      throw Exception(e.toString());
      // Get.snackbar('Upload video error', e.toString());
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
      for (var element in allDocs) {
        debugPrint('_LISTDOCS' + Video.fromSnap(element).videoUrl);
      }
      debugPrint('DOCUMENTSNAP ${querySnapshot.docs}');
    } catch (e) {
      debugPrint(e.toString());
    }
    return listDocs;
  }

  Future<User> getVideoOwnerData(String uid) async {
    DocumentSnapshot docs =
        await firebaseFirestore.collection('users').doc(uid).get();
    videoOwnerData =
        User(id: docs['uid'], userName: docs['userName'], photo: docs['photo']);
    return videoOwnerData;
  }

  Future<void> likeVideo(String id) async {
    DocumentSnapshot doc =
        await firebaseFirestore.collection('videos').doc(id).get();

    var uid = firebaseAuth.currentUser!.uid;
    if ((doc.data()! as dynamic)['likes'].contains(uid)) {
      await firebaseFirestore.collection('videos').doc(id).update({
        'likes': FieldValue.arrayRemove([uid])
      });

      await firebaseFirestore
          .collection('users')
          .doc(uid)
          .collection('likes')
          .doc(id)
          .delete();
    } else {
      await firebaseFirestore.collection('videos').doc(id).update({
        'likes': FieldValue.arrayUnion([uid])
      });
      await firebaseFirestore
          .collection('users')
          .doc(uid)
          .collection('likes')
          .doc(id)
          .set({'postId': id, 'likedAt': FieldValue.serverTimestamp()});
    }
  }

  /// double tap to like if video is liked will do nothing.
  Future<void> doubleTaplikeVideo(String id) async {
    DocumentSnapshot doc =
        await firebaseFirestore.collection('videos').doc(id).get();

    var uid = firebaseAuth.currentUser!.uid;
    if ((doc.data()! as dynamic)['likes'].contains(uid)) {
      // do nothing
    } else {
      await firebaseFirestore.collection('videos').doc(id).update({
        'likes': FieldValue.arrayUnion([uid])
      });
    }
  }

  Future<List<DocumentSnapshot>> getUserVideo(
      {required String uid, required int limit}) async {
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
        debugPrint('_LISTDOCS user video' + Video.fromSnap(element).videoUrl);
      }
      debugPrint('DOCUMENTSNAP user video ${querySnapshot.docs}');
    } catch (e) {
      debugPrint('get video User error' + e.toString());
    }
    return listDocs;
  }

  Future<List<DocumentSnapshot>> getLikedVideo(
      {required String uid, required int limit}) async {
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

      for (var element in querySnapshot.docs) {
        debugPrint(Video.fromSnap(element).videoUrl);
      }
      for (var element in allDocs) {
        debugPrint('_LISTDOCS liked video' + Video.fromSnap(element).videoUrl);
      }
      debugPrint('DOCUMENTSNAP liked video ${querySnapshot.docs}');
    } catch (e) {
      debugPrint('get video User error' + e.toString());
    }
    return listDocs;
  }
}
