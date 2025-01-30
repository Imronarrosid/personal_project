import 'package:chatview/chatview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:personal_project/utils/debug_mode_print.dart';

import '../services/firebase/firebase_service.dart';
import 'user.dart';

enum RoomType { channel, direct, group }

class Room {
  /// Created room timestamp, in ms.
  final int? createdAt;

  /// Room's unique ID.
  final String id;

  /// Room's image. In case of the [RoomType.direct] - avatar of the second person,
  /// otherwise a custom image [RoomType.group].
  final String? imageUrl;

  /// List of last messages this room has received.
  final List<Message>? lastMessages;

  /// Additional custom metadata or attributes related to the room.
  final Map<String, dynamic>? metadata;

  /// Room's name. In case of the [RoomType.direct] - name of the second person,
  /// otherwise a custom name [RoomType.group].
  final String? name;

  /// [RoomType].
  final RoomType? type;

  /// Updated room timestamp, in ms.
  final int? updatedAt;

  /// List of users which are in the room.
  final List<User> users;
  final List<UnreadedTotal>? unreadedTotal;

  Room({
    this.createdAt,
    required this.id,
    this.imageUrl,
    this.lastMessages,
    this.metadata,
    this.name,
    this.type,
    this.updatedAt,
    required this.users,
    this.unreadedTotal,
  });

  static Room fromSnap(DocumentSnapshot snapshot) {
    final snap = snapshot.data() as Map<String, dynamic>;

    return Room(
      createdAt: snap['createdAt'],
      id: snapshot.id,
      imageUrl: snap['imageUrl'],
      lastMessages: snap['lastMessages'],
      metadata: snap['metadata'],
      name: snap[' name'],
      type: getType(snap['type']),
      updatedAt: snap['updatedAt'],
      users: snap['users'],
      unreadedTotal: snap['unreadedTotal'],
    );
  }

  static Room fromJson(Map<String, dynamic> json) {
    final users = (json['users'] as List<dynamic>)
        .map((e) => User.fromMap(e as Map<String, dynamic>))
        .toList();
    final User otherUser = users.firstWhere((element) {
      return element.id != firebaseAuth.currentUser!.uid;
    });
    final User user = users.firstWhere((element) {
      return element.id == firebaseAuth.currentUser!.uid;
    });
    return Room(
      createdAt: json['createdAt'],
      id: json['id'],
      imageUrl: json['imageUrl'],
      lastMessages: json['lastMessages'],
      metadata: json['metadata'],
      name: json[' name'],
      type: getType(json['type']),
      updatedAt: json['updatedAt'],
      users: users,
      unreadedTotal:
          ((json['unreadedTotal'] as List<dynamic>?)?.map<UnreadedTotal>((e) {
                final element = e as Map<String, dynamic>;
                debugModePrint(element);
                return UnreadedTotal(
                  uid: element['uid'],
                  total: element['total'],
                  messageIds: element['messageIds'] == null
                      ? <String>[]
                      : (element['messageIds'] as List<dynamic>)
                          .map<String>(
                            (id) => id,
                          )
                          .toList(),
                  lastReadedAt: element['lastReadedAt'] ??
                      Timestamp.fromMillisecondsSinceEpoch(json['createdAt']),
                );
              }).toList() ??
              [
                UnreadedTotal.fromJson({
                  'uid': otherUser.id,
                  'total': 0,
                  'messageIds': <String>[],
                  'lastReadedAt':
                      Timestamp.fromMillisecondsSinceEpoch(json['createdAt'])
                }),
                UnreadedTotal.fromJson({
                  'uid': user.id,
                  'total': 0,
                  'messageIds': <String>[],
                  'lastReadedAt':
                      Timestamp.fromMillisecondsSinceEpoch(json['createdAt'])
                }),
              ]),
    );
  }
}

const _$RoomTypeEnumMap = {
  RoomType.channel: 'channel',
  RoomType.direct: 'direct',
  RoomType.group: 'group',
};
RoomType? getType(String type) {
  switch (type) {
    case 'direct':
      return RoomType.direct;
    case 'channel':
      return RoomType.channel;
    case 'group':
      return RoomType.group;
    default:
      return null;
  }
}

class UnreadedTotal {
  final String uid;
  final int total;
  final List<String> messageIds;

  /// Timestamp of last readed message.
  final Timestamp lastReadedAt;

  UnreadedTotal({
    required this.uid,
    required this.total,
    required this.messageIds,
    required this.lastReadedAt,
  });

  static UnreadedTotal fromJson(Map<String, dynamic> json) {
    return UnreadedTotal(
      uid: json['uid'],
      total: json['total'],
      messageIds: json['messageIds'] == null
          ? <String>[]
          : (json['messageIds'] as List<dynamic>)
              .map<String>(
                (e) => e,
              )
              .toList(),
      lastReadedAt: json['lastReadedAt'],
    );
  }

  static Map<String, dynamic> toJson(UnreadedTotal unreadedTotal) {
    return {
      'uid': unreadedTotal.uid,
      'total': unreadedTotal.total,
      'messageIds': unreadedTotal.messageIds,
      'lastReadedAt': unreadedTotal.lastReadedAt
    };
  }
}
