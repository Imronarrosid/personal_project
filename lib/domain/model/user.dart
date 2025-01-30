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
  const User({
    this.createdAt,
    this.userNameUpdatedAt,
    required this.id,
    this.email,
    this.name,
    this.userName,
    this.photo,
    this.role,
    this.nameUpdatedAt,
    this.metadata,
    this.searchKey,
    this.lastSeen,
    this.updatedAt,
    this.isTyping,
    this.isOnline,
    this.lastTyping,
  });

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
  final Timestamp? nameUpdatedAt;

  final String? searchKey;

  final Timestamp? updatedAt;

  /// Additional custom metadata or attributes related to the user.
  final fauth.UserMetadata? metadata;

  /// User [Role].
  final Role? role;

  final Timestamp? userNameUpdatedAt;

  final bool? isTyping;
  final bool? isOnline;
  final Timestamp? lastTyping;

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
        "nameUpdatedAt": nameUpdatedAt,
        "searchKey": searchKey,
        "updatedAt": updatedAt,
        "isTyping": isTyping,
        "lastTyping": lastTyping,
        "isOnline": isOnline,
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
      nameUpdatedAt: snap['nameUpdatedAt'],
      searchKey: snap['searchKey'],
      lastSeen: snap['lastSeen'],
      userNameUpdatedAt: snap['userNameUpdatedAt'],
      updatedAt: snap['updatedAt'],
      isTyping: snap['isTyping'],
      lastTyping: snap['lastTyping'],
      isOnline: snap['isOnline'],
    );
  }

  static User fromMap(Map<String, dynamic> map) {
    return User(
      name: map['name'],
      userName: map['userName'],
      photo: map['photoUrl'],
      email: map['email'],
      id: map['uid'],
      createdAt:map['createdAt']!=null? Timestamp.fromMillisecondsSinceEpoch(map['createdAt']):null,
      nameUpdatedAt: map['nameUpdatedAt'],
      searchKey: map['searchKey'],
      lastSeen: map['lastSeen'] != null
          ? Timestamp.fromMillisecondsSinceEpoch(map['lastSeen'])
          : null,
      userNameUpdatedAt: map['userNameUpdatedAt'],
      updatedAt: Timestamp.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      isTyping: map['isTyping']??false,
      lastTyping: map['lastTyping'],
      isOnline: map['isOnline']??false,
    );
  }

  @override
  List<Object?> get props => [
        email,
        id,
        name,
        userName,
        photo,
        nameUpdatedAt,
        createdAt,
        lastSeen,
        searchKey,
        nameUpdatedAt,
        userNameUpdatedAt,
        updatedAt,
        isTyping,
        lastTyping,
      ];
}
