import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_project/domain/model/game_fav_modal.dart';
import 'package:personal_project/domain/model/video_model.dart';
import 'package:personal_project/domain/services/uuid_generator.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/services/firebase/firebase_service.dart';
import '../../domain/services/firebase/image_picker.dart';

class UploadRepository extends ChangeNotifier {
  static UploadRepository instance = UploadRepository();

  bool _isUploaing = false;
  bool get isUploading => _isUploaing;

  XFile? _videFile;
  XFile? get pickedVideo => _videFile;

  Video? _videoOnUploading;
  Video? get videoOnUploading => _videoOnUploading;

  File? _thubnailOnUploading;
  File? get thubnailOnUploading => _thubnailOnUploading;

  XFile? _exportedFile;

  XFile? get exportedVideo => _exportedFile;

  StreamController<double> _uploadVideoController =
      StreamController<double>.broadcast();

  Stream<double> get uploadProgressStream =>
      _uploadVideoController.stream.asBroadcastStream();

  void storeExportedVideo(XFile file) {
    _exportedFile = file;
    notifyListeners();
  }

  void pickVideoOnGalery(BuildContext context) async {
    Future<XFile?> video = pickVideoFromGalery();

    XFile? pickVideo = await video;

    _videFile = pickVideo;
    if (pickVideo != null && context.mounted) {
      debugPrint('picked');
      context.go(APP_PAGE.upload.toPath + APP_PAGE.videoEditor.toPath,
          extra: pickVideo);
    } else if (pickVideo == null && context.mounted) {
      context.pop();
    }
    notifyListeners();
  }

  void pickVideoFromComputer(BuildContext context) async {
    Future<XFile?> video = pickVideoFromGalery();

    XFile? pickVideo = await video;

    _videFile = pickVideo;
    if (pickVideo != null && context.mounted) {
      debugPrint('picked');
      context.go(APP_PAGE.upload.toPath + APP_PAGE.videoEditor.toPath,
          extra: pickVideo);
    }
    notifyListeners();
  }

  void pickVideo(XFile video) {
    _videFile = video;
    notifyListeners();
  }

  void openCamera(BuildContext context) async {
    Future<XFile?> video = pickVideoFromCamera();

    XFile? pickVideo = await video;
    _videFile = pickVideo;
    if (pickVideo != null && context.mounted) {
      debugPrint('picked');
      context.go(APP_PAGE.upload.toPath + APP_PAGE.videoEditor.toPath,
          extra: pickVideo);
    } else if (pickVideo == null && context.mounted) {
      context.pop();
    }
    notifyListeners();
  }

  Future<String> _uploadToStorage(String id, File videoFile) async {
    Reference ref = firebaseStorage
        .ref()
        .child('videos/${firebaseAuth.currentUser!.uid}')
        .child(id);
    _saveUploadingUrl(ref.fullPath);

    UploadTask uploadTask = ref.putFile(videoFile);

    uploadTask.snapshotEvents.listen((snapshot) {
      double progress =
          ((snapshot.bytesTransferred / snapshot.totalBytes) * 100);
      _uploadVideoController.add(progress);
    });

    TaskSnapshot snapshot = await uploadTask;
    String downloaUrl = await snapshot.ref.getDownloadURL();

    return downloaUrl;
  }

  _uploadThumnailesToStorage(String id, String thumbnail) async {
    Reference ref = firebaseStorage
        .ref()
        .child('thumbnailes/${firebaseAuth.currentUser!.uid}')
        .child(id);
    _thubnailOnUploading = File(thumbnail);
    UploadTask uploadTask = ref.putFile(File(thumbnail));
    TaskSnapshot snapshot = await uploadTask;
    String downloaUrl = await snapshot.ref.getDownloadURL();

    return downloaUrl;
  }

  uploapVideo({
    required String songName,
    required String caption,
    required String videoPath,
    required String thumbnailPath,
    String? category,
    GameFav? game,
    String? uploadingUrl,
  }) async {
    try {
      String uid = firebaseAuth.currentUser!.uid;
      //Get id

      Video video = Video(
          uid: uid,
          songName: songName,
          caption: caption,
          thumnail: '',
          videoUrl: '',
          likes: [],
          commentCount: 0,
          shareCount: 0,
          viewsCount: 0,
          likesCount: 0,
          createdAt: FieldValue.serverTimestamp(),
          game: game,
          views: [],
          category: category ?? '');

      _videoOnUploading = video;
      _thubnailOnUploading = File(thumbnailPath);
      _saveUploadingThumbnail(thumbnailPath);
      _isUploaing = true;
      notifyListeners();

      final String uuid = generateUuid();
      String videoUrl = await _uploadToStorage(
          uploadingUrl ?? "video_$uuid.mp4", File(videoPath));
      String thumnail =
          await _uploadThumnailesToStorage("video $uuid", thumbnailPath);

      video = Video(
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

      await firebaseFirestore
          .collection('videos')
          .doc()
          .set(video.toJson())
          .then((_) {
        debugPrint('uploaded');
      });
      _isUploaing = false;
      notifyListeners();
      _uploadVideoController.close();
      _uploadVideoController = StreamController<double>.broadcast();
    } catch (e) {
      debugPrint(e.toString());
      _uploadVideoController.close();
      _uploadVideoController = StreamController<double>.broadcast();
      _isUploaing = false;
      notifyListeners();
      rethrow;
    }
  }

  void removeExportedFile() {
    _exportedFile = null;
    notifyListeners();
  }

  void removePickedFile() {
    _videFile = null;
    notifyListeners();
  }

  Future<void> _saveUploadingUrl(String filePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('uploadingPath', filePath);
  }

  Future<void> _saveUploadingThumbnail(String data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('uploadingThumbnail', data);
  }

  Future<Map<String, dynamic>?> getUploadProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? filePath = prefs.getString('uploadingPath');
    double? progress = prefs.getDouble('uploadProgress');
    if (filePath != null && progress != null) {
      return {'filePath': filePath, 'progress': progress};
    }
    return null;
  }

  Future<void> clearUploadProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('uploadingPath');
    await prefs.remove('uploadProgress');
  }

  Future<bool> isCategoryExist(String category) async {
    final docs = await firebaseFirestore
        .collection('videos')
        .where('category', isEqualTo: category)
        .limit(1)
        .get();
    if (docs.docs.isNotEmpty) {
      return true;
    }
    return false;
  }

  Future<String> getGameAvatar(String title) async {
    return firebaseFirestore
        .collection('gameFavorites')
        .where('title', isEqualTo: title)
        .get()
        .then((value) => value.docs.first['icon']);
  }
}
