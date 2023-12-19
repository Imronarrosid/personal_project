import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as fauth;

/// All possible roles user can have.
enum Role { admin, agent, moderator, user }

/// {@template user}
/// User model
///
/// [User.empty] represents an unauthenticated user.
/// {@endtemplate}
class User extends Equatable {
  /// {@macro user}
  const User(
      {this.createdAt,
      this.userNameUpdatedAt,
      required this.id,
      this.email,
      this.name,
      this.userName,
      this.photo,
      this.role,
      this.updatedAt,
      this.metadata,
      this.searchKey,
      this.lastSeen});

  /// Created user timestamp, in ms.
  final Timestamp? createdAt;

  /// The current user's email address.
  final String? email;

  /// The current user's id.
  final String id;

  /// The current user's name (display name).
  final String? userName;
  final String? name;

  /// Url for the current user's photo.
  final String? photo;

  /// Timestamp when user was last visible, in ms.
  final Timestamp? lastSeen;

  /// Updated user timestamp, in ms.
  final Timestamp? updatedAt;

  final String? searchKey;

  /// Additional custom metadata or attributes related to the user.
  final fauth.UserMetadata? metadata;

  /// User [Role].
  final Role? role;

  final Timestamp? userNameUpdatedAt;

  /// Empty user which represents an unauthenticated user.
  static const empty = User(id: '');

  /// Convenience getter to determine whether the current user is empty.
  bool get isEmpty => this == User.empty;

  /// Convenience getter to determine whether the current user is not empty.
  bool get isNotEmpty => this != User.empty;

  Map<String, dynamic> toJson() => {
        "name": userName,
        "photo": photo,
        "email": email,
        "uid": id,
        "createdAt": createdAt,
        "lastSeen": lastSeen,
        "updatedAt": updatedAt,
        "searchKey": searchKey
      };
  static User fromSnap(DocumentSnapshot snapshot) {
    var snap = snapshot.data() as Map<String, dynamic>;
    return User(
        name: snap['name'],
        userName: snap['userName'],
        photo: snap['photoUrl'],
        email: snap['email'],
        id: snap['uid'],
        createdAt: snap['createdAt'],
        updatedAt: snap['updatedAt'],
        searchKey: snap['searchKey'],
        lastSeen: snap['lastSeen'],
        userNameUpdatedAt: snap['userNameUpdatedAt']);
  }

  @override
  List<Object?> get props => [
        email,
        id,
        name,
        userName,
        photo,
        updatedAt,
        createdAt,
        lastSeen,
        searchKey
      ];
}
