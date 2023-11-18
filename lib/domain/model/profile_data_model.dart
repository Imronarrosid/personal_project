import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileData {
  final String name;
  final String userName;
  final String bio;
  final String photoUrl;
  final Timestamp updatedAt;
  final Timestamp userNameUpdatedAt;
  final List<String> gameFavoritesId;

  ProfileData(
      {required this.userName,
      required this.photoUrl,
      required this.name,
      required this.updatedAt,
      required this.bio,
      required this.userNameUpdatedAt,
      required this.gameFavoritesId});
}
