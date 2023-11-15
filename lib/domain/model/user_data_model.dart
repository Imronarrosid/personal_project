import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  final String uid;
  final String name;
  final String photoURL;
  final String followers;
  final String following;
  final String likes;
  final Timestamp updatedAt;
  final bool isFollowig;

  UserData({
    required this.name,
    required this.updatedAt,
    required this.uid,
    required this.photoURL,
    required this.followers,
    required this.following,
    required this.isFollowig,
    required this.likes,
  });

  static UserData fromMap(Map<String, dynamic> userData) {
    return UserData(
        uid: userData['uid'],
        name: userData['userName'],
        photoURL: userData['photoUrl'],
        followers: userData['followers'],
        following: userData['following'],
        isFollowig: userData['isFollowing'],
        likes: userData['likes'],
        updatedAt: userData['updatedAt']);
  }
}
