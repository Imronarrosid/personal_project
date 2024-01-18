import 'package:cloud_firestore/cloud_firestore.dart';

import 'game_fav_modal.dart';

class Video {
  /// [id] for [Video] document id on firestore
  ///
  /// [id] have value from document id
  ///
  /// no nedd to insert [id] value on uploading video
  ///
  /// firestore will create [id] value
  final String? id;
  final String? username;
  final String uid, songName, caption, thumnail, videoUrl;
  final String? profileImg;
  final GameFav? game;
  final dynamic createdAt;
  final List likes, views;
  final int commentCount, shareCount, viewsCount;
  Video(
      {this.id,
      this.username,
      required this.uid,
      required this.songName,
      required this.caption,
      required this.thumnail,
      required this.videoUrl,
      this.profileImg,
      this.game,
      required this.likes,
      required this.views,
      required this.commentCount,
      required this.viewsCount,
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
        "viewsCount": viewsCount,
        "songName": songName,
        "caption": caption,
        "videoUrl": videoUrl,
        "thumnail": thumnail,
        "createdAt": createdAt,
        "views": views,
        "game": game == null
            ? null
            : {"title": game?.gameTitle, "icon": game?.gameImage}
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
      viewsCount: snap["viewsCount"] ?? (snap["views"] as List).length,
      shareCount: snap["shareCount"],
      songName: snap["songName"],
      caption: snap["caption"],
      videoUrl: snap["videoUrl"],
      thumnail: snap["thumnail"],
      createdAt: snap["createdAt"],
      views: snap["views"],
      game: snap['game'] != null
          ? GameFav(
              gameTitle: snap['game']['title'], gameImage: snap['game']['icon'])
          : null,
    );
  }
}
