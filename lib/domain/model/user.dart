import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

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
      required this.id,
      this.email,
      this.userName,
      this.photo,
      this.role,
      this.updatedAt,
      this.metadata,
      this.searchKey,
      this.lastSeen});

  /// Created user timestamp, in ms.
  final int? createdAt;

  /// The current user's email address.
  final String? email;

  /// The current user's id.
  final String id;

  /// The current user's name (display name).
  final String? userName;

  /// Url for the current user's photo.
  final String? photo;

  /// Timestamp when user was last visible, in ms.
  final int? lastSeen;

  /// Updated user timestamp, in ms.
  final int? updatedAt;

  final String? searchKey;

  /// Additional custom metadata or attributes related to the user.
  final Map<String, dynamic>? metadata;

  /// User [Role].
  final Role? role;

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
        userName: snap['userName'],
        photo: snap['photoUrl'],
        email: snap['email'],
        id: snap['uid'],
        createdAt: snap['createdAt'],
        updatedAt: snap['updatedAt'],
        searchKey: snap['searchKey'],
        lastSeen: snap['lastSeen']);
  }

  @override
  List<Object?> get props =>
      [email, id, userName, photo, updatedAt, createdAt, lastSeen, searchKey];
}
