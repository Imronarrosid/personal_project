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
  final String category;
  final dynamic createdAt;
  final List likes, views;
  final int commentCount, shareCount, viewsCount;
  int likesCount;
  bool isLiked;
  Video({
    this.id,
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
    required this.createdAt,
    required this.likesCount,
    required this.category,
    this.isLiked = false,
  });

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "profileImg": profileImg,
        "id": id,
        "likes": likes,
        "commentCount": commentCount,
        "shareCount": shareCount,
        "viewsCount": viewsCount,
        "likesCount": likesCount,
        "songName": songName,
        "caption": caption,
        "videoUrl": videoUrl,
        "thumnail": thumnail,
        "createdAt": createdAt,
        "views": views,
        "category": category,
        "isLiked": isLiked,
        "game": game == null ? null : {"title": game?.gameTitle, "icon": game?.gameImage}
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
      likesCount: snap["likesCount"] ?? (snap["likes"] as List).length,
      songName: snap["songName"],
      caption: snap["caption"],
      videoUrl: snap["videoUrl"],
      thumnail: snap["thumnail"],
      createdAt: snap["createdAt"],
      views: snap["views"],
      isLiked: snap['isLiked'] ?? false,
      game:
          snap['game'] != null ? GameFav(gameTitle: snap['game']['title'], gameImage: snap['game']['icon']) : null,
      category: snap["category"] ?? '',
    );
  }

  Video copyWith({
    String? id,
    String? username,
    String? uid,
    String? songName,
    String? caption,
    String? thumnail,
    String? videoUrl,
    String? profileImg,
    GameFav? game,
    String? category,
    dynamic createdAt,
    List? likes,
    List? views,
    int? commentCount,
    int? shareCount,
    int? viewsCount,
    int? likesCount,
    bool? isLiked,
  }) {
    return Video(
      id: id ?? this.id,
      username: username ?? this.username,
      uid: uid ?? this.uid,
      songName: songName ?? this.songName,
      caption: caption ?? this.caption,
      thumnail: thumnail ?? this.thumnail,
      videoUrl: videoUrl ?? this.videoUrl,
      profileImg: profileImg ?? this.profileImg,
      game: game ?? this.game,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      views: views ?? this.views,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      viewsCount: viewsCount ?? this.viewsCount,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
