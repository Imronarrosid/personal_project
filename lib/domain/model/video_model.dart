import 'package:cloud_firestore/cloud_firestore.dart';

class Video {
  /// [id] for [Video] document id on firestore
  ///
  /// [id] have value from document id
  ///
  /// no nedd to insert [id] value on uploading video
  ///
  /// firestore will create [id] value
  final String? id;
  final String username,
      uid,
      songName,
      caption,
      thumnail,
      videoUrl,
      game,
      profileImg;
  final dynamic createdAt;
  final List likes, views;
  final int commentCount, shareCount;
  Video(
      {this.id,
      required this.username,
      required this.uid,
      required this.songName,
      required this.caption,
      required this.thumnail,
      required this.videoUrl,
      required this.profileImg,
      required this.game,
      required this.likes,
      required this.views,
      required this.commentCount,
      required this.shareCount,
      required this.createdAt});

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
        "thumnail": thumnail,
        "createdAt": createdAt,
        "views": views,
        "game": game
      };
  static Video fromSnap(DocumentSnapshot snapshot) {
    var snap = snapshot.data() as Map<String, dynamic>;

    return Video(
      username: snap["username"],
      uid: snap["uid"],
      profileImg: snap["profileImg"],
      id: snapshot.id,
      likes: snap["likes"],
      commentCount: snap["commentCount"],
      shareCount: snap["shareCount"],
      songName: snap["songName"],
      caption: snap["caption"],
      videoUrl: snap["videoUrl"],
      thumnail: snap["thumnail"],
      createdAt: snap["creaatedAt"],
      views: snap["views"],
      game: snap['game'],
    );
  }
}
