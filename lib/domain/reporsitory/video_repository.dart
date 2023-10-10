import 'dart:io';

import 'package:personal_project/domain/model/video_model.dart';
import 'package:personal_project/domain/services/firebase/firebase_service.dart';
import 'package:personal_project/domain/usecase/vide_usecase_type.dart';
import 'package:video_compress/video_compress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class VideRepository implements VideoUseCaseType {
  FirebaseStorage firebaseStorage = FirebaseStorage.instance;

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
    Reference ref = firebaseStorage.ref().child('videos').child(id);

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
    try {
      String uid = FirebaseServices.firebaseAuth.currentUser!.uid;
      DocumentSnapshot userDoc = await FirebaseServices.firebaseFirestore
          .collection('user')
          .doc(uid)
          .get();
      //Get id
      var allDocs =
          await FirebaseServices.firebaseFirestore.collection('videos').get();
      int len = allDocs.docs.length;
      String videoUrl =
          await _uploadToStorage("video $len", await _compressVideo(videoPath));
      String thumnail =
          await _uploadThumnailesToStorage("video $len", videoPath);

      Video video = Video(
          username: (userDoc.data()! as Map<String, dynamic>)['username'],
          uid: uid,
          id: "video$len",
          songName: songName,
          caption: caption,
          thumnail: thumnail,
          videoUrl: videoUrl,
          profileImg: (userDoc.data()! as Map<String, dynamic>)['profileImg'],
          likes: [],
          commentCount: 0,
          shareCount: 0);

      await FirebaseServices.firebaseFirestore
          .collection('videos')
          .doc('video$len')
          .set(video.toJson());
    } catch (e) {
      // Get.snackbar('Upload video error', e.toString());
    }
  }
}
