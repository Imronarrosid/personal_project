import 'package:cloud_firestore/cloud_firestore.dart';

class Video {
  final String username,
      uid,
      id,
      songName,
      caption,
      thumnail,
      videoUrl,
      profileImg;
  final List likes;
  final int commentCount, shareCount;
  Video({
    required this.username,
    required this.uid,
    required this.id,
    required this.songName,
    required this.caption,
    required this.thumnail,
    required this.videoUrl,
    required this.profileImg,
    required this.likes,
    required this.commentCount,
    required this.shareCount,
  });

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "profileImg": profileImg,
        "id": id,
        "likes": likes,
        "commentCount": commentCount,
        "shareCount": shareCount,
        "songName": songName,
        "caption": caption,
        "videoUrl": videoUrl,
        "thumnail": thumnail
      };
  static Video fromSnap(DocumentSnapshot snapshot) {
    var snap = snapshot.data() as Map<String, dynamic>;

    return Video(
      username: snap["username"],
      uid: snap["uid"],
      profileImg: snap["profileImg"],
      id: snap["id"],
      likes: snap["likes"],
      commentCount: snap["commentCount"],
      shareCount: snap["shareCount"],
      songName: snap["songName"],
      caption: snap["caption"],
      videoUrl: snap["videoUrl"],
      thumnail: snap["thumnail"],
    );
  }
}
