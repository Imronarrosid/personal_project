import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:personal_project/domain/model/game_fav_modal.dart';
import 'package:personal_project/domain/model/user.dart';

class ProfileData {
  final String name;
  final String userName;
  final String bio;
  final String photoUrl;
  final Timestamp updatedAt;
  final Timestamp userNameUpdatedAt;
  final Timestamp userCreatedAt;
  final List<String> gameFavoritesId;
  final List<GameFav> gameFav;

  ProfileData({
    required this.userName,
    required this.userCreatedAt,
    required this.photoUrl,
    required this.name,
    required this.updatedAt,
    required this.bio,
    required this.userNameUpdatedAt,
    required this.gameFav,
    required this.gameFavoritesId,
  });
}

class ProfilePayload {
  final bool? isForOtherUser;
  final String? username;
  final User user;

  ProfilePayload({
    required this.user,
    this.username,
    this.isForOtherUser = false,
  });
}
