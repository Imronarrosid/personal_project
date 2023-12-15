import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:personal_project/domain/model/game_fav_modal.dart';

class ProfileData {
  final String name;
  final String userName;
  final String bio;
  final String photoUrl;
  final Timestamp updatedAt;
  final Timestamp userNameUpdatedAt;
  final List<String> gameFavoritesId;
  final List<GameFav> gameFav;

  ProfileData(
      {required this.userName,
      required this.photoUrl,
      required this.name,
      required this.updatedAt,
      required this.bio,
      required this.userNameUpdatedAt,
      required this.gameFav,
      required this.gameFavoritesId});
}

class ProfilePayload {
  final String uid, name, userName, photoURL;
  final Timestamp? nameUpdatedAt, userNameUpdatedAt;

  ProfilePayload({
    required this.uid,
    required this.name,
    required this.userName,
    required this.photoURL,
    this.nameUpdatedAt,
    this.userNameUpdatedAt,
  });
}
