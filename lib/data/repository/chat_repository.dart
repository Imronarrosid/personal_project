import 'dart:io';

import 'package:chatview/chatview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:personal_project/constant/constants.dart';
import 'package:personal_project/data/source/local/local_data.dart';
import 'package:personal_project/domain/model/user.dart';
import 'package:personal_project/domain/services/firebase/firebase_service.dart';
import 'package:personal_project/domain/services/uuid_generator.dart';
import 'package:personal_project/utils/chat_util.dart';
import 'package:personal_project/utils/debug_mode_print.dart';
import 'package:uuid/uuid.dart';

import '../../domain/model/chat_data_models.dart';
import '../../domain/model/chat_payload_model.dart';
import '../../domain/model/room_model.dart';
import '../../utils/audio_utils.dart';
import '../../utils/update_user_last_seen.dart';

class ChatRepository {
  List<String> _followingUidList = [];

  final List<DocumentSnapshot> _docs = [];
  final List<DocumentSnapshot> _chatDocs = [];
  final List<String> _messageIdFromStream = [];

  final List<Message> _messages = [];

  static ChatData? _chatData;

  ChatData? get chatData => _chatData;

  set setChatData(ChatData? chatData) => _chatData = chatData;
  static ChatPayload? _chatPayload;

  ChatPayload? get chatPayload => _chatPayload;
  List<DocumentSnapshot>? get chatDoc => _chatDocs;

  List<Message> get messagesLists => _messages;

  set setChatPayload(ChatPayload? chatData) => _chatPayload = chatData;

  void clearPreviouseData() {
    _docs.clear();
  }

  Future<void> initSearchFollowingSearch() async {
    try {
      await firebaseFirestore
          .collection('users')
          .doc(firebaseAuth.currentUser!.uid)
          .collection('following')
          .get()
          .then((value) {
        List<String> results = [];
        for (DocumentSnapshot element in value.docs) {
          results.add(element.id);
        }
        _followingUidList = results;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<List<DocumentSnapshot>> allSuggestionRoom(int limit) async {
    try {
      QuerySnapshot querySnapshot;
      List<DocumentSnapshot> listDocs = [];

      if (_docs.isEmpty) {
        querySnapshot = await firebaseFirestore
            .collection('users')
            .where('uid', whereIn: _followingUidList)
            .limit(limit)
            .get();

        debugPrint('empty');
      } else {
        querySnapshot = await firebaseFirestore
            .collection('users')
            .where('uid', whereIn: _followingUidList)
            .limit(limit)
            .startAfterDocument(_docs.last)
            .get();
      }
      debugPrint('get user  ${querySnapshot.docs.length}');

      ///List to get last documet
      _docs.addAll(querySnapshot.docs);

      //list that send to infinity list package
      listDocs.addAll(querySnapshot.docs);

      return listDocs;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  Future<List<User>> searchUserFromFollowing(String query) async {
    try {
      List<User> searchResults = [];
      // bool iscanSearch = false;
      // do {
      //   iscanSearch = false;
      //   if (_followingUidList.isNotEmpty) {
      //     iscanSearch = true;
      //   }
      // } while (_followingUidList.isEmpty);

      if (query.isNotEmpty) {
        // Debounce the search to reduce queries to Firestore
        await firebaseFirestore
            .collection('users')
            .where('uid', whereIn: _followingUidList)
            .where('name', isGreaterThanOrEqualTo: query)
            .where('name', isLessThan: '${query}z')
            .get()
            .then((value) {
          for (var element in value.docs) {
            searchResults.add(
                // User(
                //     id: element['uid'],
                //     name: element['name'],
                //     userName: element['userName'],
                //     photo: element['photoUrl']),
                User.fromSnap(element));
          }
        });
        await firebaseFirestore
            .collection('users')
            .where('uid', whereIn: _followingUidList)
            .where('userName', isGreaterThanOrEqualTo: query)
            .where('userName', isLessThan: '${query}z')
            .get()
            .then((value) {
          for (var element in value.docs) {
            if (!searchResults.contains(User.fromSnap(element))) {
              searchResults.add(User.fromSnap(element));
            }
          }
        });
      }
      return searchResults;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  Future<String> uploadFile(File file, {required String name}) async {
    try {
      final Reference reference =
          firebaseStorage.ref('files/${firebaseAuth.currentUser!.uid}').child('[${DateTime.timestamp()}]$name');
      await reference.putFile(file);
      final uri = await reference.getDownloadURL();
      return uri;
    } catch (e) {
      debugPrint(e.toString());
      return '';
    }
  }

  Future<String> uploadFileWeb(Uint8List data, {required String name}) async {
    try {
      final Reference reference =
          firebaseStorage.ref('files/${firebaseAuth.currentUser!.uid}').child('[${DateTime.timestamp()}]$name');
      await reference.putData(data);
      final uri = await reference.getDownloadURL();
      return uri;
    } catch (e) {
      debugPrint(e.toString());
      return '';
    }
  }

  Future<String> uploadImage(File file, {required String name}) async {
    try {
      final Reference reference = firebaseStorage
          .ref('chat_images/${firebaseAuth.currentUser!.uid}')
          .child('[${DateTime.timestamp()}]$name');
      await reference.putFile(file);
      final uri = await reference.getDownloadURL();
      return uri;
    } catch (e) {
      debugPrint(e.toString());
      return '';
    }
  }

  Future<String> uploadVoice(File file, {required String name}) async {
    try {
      final Reference reference = firebaseStorage
          .ref('chat_voice/${firebaseAuth.currentUser!.uid}')
          .child('[${DateTime.timestamp()}]$name');
      await reference.putFile(file);
      final uri = await reference.getDownloadURL();
      return uri;
    } catch (e) {
      debugPrint(e.toString());
      return '';
    }
  }

  Future<String> uploadImageWeb(Uint8List data, {required String name}) async {
    try {
      final Reference reference = firebaseStorage
          .ref('chat_images/${firebaseAuth.currentUser!.uid}')
          .child('[${DateTime.timestamp()}]$name');
      await reference.putData(data);
      final uri = await reference.getDownloadURL();
      return uri;
    } catch (e) {
      debugPrint(e.toString());
      return '';
    }
  }

  Future<void> onOpenChat({required Room room}) async {
    final Message? message = await _getLastMessage(room);

    if (message == null) return;
    final DocumentReference ref = firebaseFirestore.collection('rooms').doc(room.id);

    final UnreadedTotal otherUnreaded = room.unreadedTotal!.firstWhere(
      (element) {
        return element.uid != firebaseAuth.currentUser!.uid;
      },
    );
    final UnreadedTotal userUnreaded = room.unreadedTotal!.firstWhere(
      (element) {
        return element.uid == firebaseAuth.currentUser!.uid;
      },
    );

    firebaseFirestore.runTransaction(
      (transaction) async {
        transaction.update(ref, {
          'unreadedTotal': [
            {
              'uid': otherUnreaded.uid,
              'total': otherUnreaded.total,
              'lastReadedAt': otherUnreaded.lastReadedAt,
            },
            {
              'uid': userUnreaded.uid,
              'total': 0,
              'lastReadedAt': message!.createdAt,
            }
          ]
        });
      },
    );
  }

  /// Creates a direct chat for 2 people. Add [metadata] for any additional
  /// custom data.
  Future<Room> createRoom(
    User otherUser, {
    Map<String, dynamic>? metadata,
  }) async {
    final fu = firebaseAuth.currentUser;

    if (fu == null) return Future.error('User does not exist');

    // Sort two user ids array to always have the same array for both users,
    // this will make it easy to find the room if exist and make one read only.
    final userIds = [fu.uid, otherUser.id]..sort();

    final roomQuery = await firebaseFirestore
        .collection('rooms')
        .where('type', isEqualTo: RoomType.direct.toShortString())
        .where('userIds', isEqualTo: userIds)
        .limit(1)
        .get();

    // Check if room already exist.
    if (roomQuery.docs.isNotEmpty) {
      final room = (await processRoomsQuery(
        fu,
        firebaseFirestore,
        roomQuery,
        'users',
      ))
          .first;

      return room;
    }

    // To support old chats created without sorted array,
    // try to check the room by reversing user ids array.
    final oldRoomQuery = await firebaseFirestore
        .collection('rooms')
        .where('type', isEqualTo: RoomType.direct.toShortString())
        .where('userIds', isEqualTo: userIds.reversed.toList())
        .limit(1)
        .get();

    // Check if room already exist.
    if (oldRoomQuery.docs.isNotEmpty) {
      final room = (await processRoomsQuery(
        fu,
        firebaseFirestore,
        oldRoomQuery,
        'users',
      ))
          .first;

      return room;
    }

    final currentUser = await fetchUser(
      firebaseFirestore,
      fu.uid,
      'users',
    );

    final users = [User.fromMap(currentUser), otherUser];

    // Create new room with sorted user ids array.
    final room = await firebaseFirestore.collection('rooms').add({
      'createdAt': FieldValue.serverTimestamp(),
      'imageUrl': null,
      'metadata': metadata,
      'name': null,
      'type': RoomType.direct.toShortString(),
      'updatedAt': FieldValue.serverTimestamp(),
      'userIds': userIds,
      'userRoles': null,
    });

    return Room(
      id: room.id,
      metadata: metadata,
      type: RoomType.direct,
      users: users,
    );
  }

  /// Returns a stream of changes in a room from Firebase.
  Stream<Room> room(String roomId) {
    final fu = firebaseAuth.currentUser;

    if (fu == null) return const Stream.empty();

    return firebaseFirestore.collection('rooms').doc(roomId).snapshots().asyncMap(
          (doc) => processRoomDocument(
            doc,
            fu,
            firebaseFirestore,
            'users',
          ),
        );
  }

  Future<void> sendMessage(Message message, String roomId) async {
    try {
      if (firebaseAuth.currentUser == null) return;
      String messageId = uuid.v6();
      final messageMap = message.toJson();
      messageMap['id'] = messageId;
      messageMap['sentBy'] = firebaseAuth.currentUser!.uid;
      messageMap['createdAt'] = FieldValue.serverTimestamp();
      messageMap['updatedAt'] = FieldValue.serverTimestamp();
      messageMap['message_type'] = message.messageType.name;
      messageMap['reply_message'] = message.replyMessage
          .copyWith(
            voiceMessageDuration: message.replyMessage.voiceMessageDuration ?? const Duration(microseconds: 0),
          )
          .toJson();

      messageMap['status'] = messageMap['message_type'] == MessageType.image.name ||
              messageMap['message_type'] == MessageType.voice.name
          ? MessageStatus.pending.name
          : MessageStatus.delivered.name;

      if (message.messageType.isText) {
        messageMap[TEXT] = message.text;
      }

      if (messageMap['message_type'] == MessageType.voice.name) {
        messageMap['voice_message_duration'] = Duration(
          milliseconds: await AudioUtils.getAudioDuration(message.mediaPath) ?? 0,
        ).inMicroseconds;
        LocalData.instance.storeAudioPath(id: messageId, path: message.mediaPath);
      }
      debugModePrint('message $messageMap');
      await firebaseFirestore.collection('rooms/$roomId/messages').doc(messageId).set(messageMap);

      if (messageMap['message_type'] == MessageType.image.name) {
        messageMap[MEDIA_PATH] = await uploadImage(File(messageMap[MEDIA_PATH]), name: Uuid().v6());
        messageMap['status'] = MessageStatus.delivered.name;
        messageMap['updatedAt'] = FieldValue.serverTimestamp();
        await firebaseFirestore.collection('rooms/$roomId/messages').doc(messageId).update(messageMap);
      }

      if (messageMap['message_type'] == MessageType.voice.name) {
        messageMap[MEDIA_PATH] = await uploadVoice(File(messageMap[MEDIA_PATH]), name: Uuid().v6());
        messageMap['status'] = MessageStatus.delivered.name;
        messageMap['updatedAt'] = FieldValue.serverTimestamp();

        await firebaseFirestore.collection('rooms/$roomId/messages').doc(messageId).update(messageMap);
      }

      DocumentReference ref = firebaseFirestore.collection('rooms').doc(roomId);
      firebaseFirestore.runTransaction(
        (transaction) async {
          await transaction.get(ref).then(
            (value) {
              final roomMap = value.data() as Map<String, dynamic>;
              roomMap['id'] = value.id;

              roomMap['users'] =
                  ((value.data() as Map<String, dynamic>)['userIds'] as List).map((e) => {'uid': e}).toList();
              roomMap['createdAt'] = roomMap['createdAt']?.millisecondsSinceEpoch;
              roomMap['updatedAt'] = roomMap['updatedAt']?.millisecondsSinceEpoch;
              final Room room = Room.fromJson(roomMap);
              final UnreadedTotal otherUnreaded = room.unreadedTotal!.firstWhere(
                (element) {
                  return element.uid != firebaseAuth.currentUser!.uid;
                },
              );
              final UnreadedTotal userUnreaded = room.unreadedTotal!.firstWhere(
                (element) {
                  return element.uid == firebaseAuth.currentUser!.uid;
                },
              );

              transaction.update(ref, {
                'updatedAt': FieldValue.serverTimestamp(),
                'unreadedTotal': [
                  {
                    'uid': otherUnreaded.uid,
                    'total': otherUnreaded.total + 1,
                    // 'messageIds': FieldValue.arrayUnion(['fasdf']),
                    'lastReadedAt': otherUnreaded.lastReadedAt,
                  },
                  {
                    'uid': firebaseAuth.currentUser!.uid,
                    'total': userUnreaded.total,
                    // 'messageIds': userUnreaded.messageIds,
                    'lastReadedAt': otherUnreaded.lastReadedAt,
                  }
                ]
              });
            },
          );
        },
      );
      updateUserLastSeen();
    } catch (e) {
      debugModePrint('sendMessage $e');
    }
  }

  Stream<List<Message>> messages(
    Room room, {
    List<Object?>? endAt,
    List<Object?>? endBefore,
    int? limit,
    List<Object?>? startAfter,
    List<Object?>? startAt,
  }) {
    var query = firebaseFirestore.collection('rooms/${room.id}/messages').orderBy('createdAt', descending: true);

    if (endAt != null) {
      query = query.endAt(endAt);
    }

    if (endBefore != null) {
      query = query.endBefore(endBefore);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    if (startAfter != null) {
      query = query.startAfter(startAfter);
    }

    if (startAt != null) {
      query = query.startAt(startAt);
    }

    updateUserLastSeen();

    return query.snapshots().map((snapshot) {
      return snapshot.docs.fold<List<Message>>(
        [],
        (previousValue, doc) {
          final data = doc.data();
          final author = room.users.firstWhere(
            (u) => u.id == (data['authorId'] ?? data['sentBy']),
            orElse: () => User(id: data['authorId'] as String),
          );
          final otherUser = room.users.firstWhere(
            (u) => u.id != (data['authorId'] ?? data['sentBy']),
            orElse: () => User(id: data['authorId'] as String),
          );

          if (data['status'] == MessageStatus.pending.name && data['sentBy'] != firebaseAuth.currentUser!.uid) {
            debugModePrint('skip pending message');
            return [
              ...previousValue,
            ];
          }

          data['sentBy'] = author.id;
          data['createdAt'] = data['createdAt'] == null
              ? DateTime.now()
              : DateTime.fromMillisecondsSinceEpoch(data['createdAt']?.millisecondsSinceEpoch);
          data['updatedAt'] = data['updatedAt'] == null
              ? DateTime.now()
              : DateTime.fromMillisecondsSinceEpoch(data['updatedAt']?.millisecondsSinceEpoch);
          data['id'] = doc.id;
          data['message_type'] = data['type'] ?? data['message_type'];

          if (data['type'] == MessageType.text.name || data['message_type'] == MessageType.text.name) {
            data[TEXT] = data[TEXT];
          }
          if (data['message_type'] == MessageType.image.name) {
            data[MEDIA_PATH] = data['uri'] ?? data[MEDIA_PATH] ?? data['message'];
            data[TEXT] = data['caption'] ?? data[TEXT];
          }

          _processVoiceMessage(data);

          final authorUnreaded = room.unreadedTotal!.firstWhere(
            (element) => element.uid == author.id,
          );
          final otherUserUnreaded = room.unreadedTotal!.firstWhere(
            (element) => element.uid == otherUser.id,
          );

          bool readedByAuthor = data['sentBy'] == otherUser.id &&
              DateTime.fromMillisecondsSinceEpoch(authorUnreaded.lastReadedAt.millisecondsSinceEpoch + 1).isAfter(
                DateTime.fromMillisecondsSinceEpoch(data['createdAt']?.millisecondsSinceEpoch),
              );

          bool readedByOhterUser = data['sentBy'] == author.id &&
              DateTime.fromMillisecondsSinceEpoch(otherUserUnreaded.lastReadedAt.millisecondsSinceEpoch + 1)
                  .isAfter(
                DateTime.fromMillisecondsSinceEpoch(data['createdAt']?.millisecondsSinceEpoch),
              );

          if (doc.metadata.hasPendingWrites) {
            data['status'] = MessageStatus.pending.name;
          } else if (readedByAuthor || readedByOhterUser) {
            data['status'] = MessageStatus.read.name;
          }

          return [...previousValue, Message.fromJson(data)];
        },
      );
      // if (list.isNotEmpty) {
      //   for (var message in list) {
      //     if (message.sentBy != firebaseAuth.currentUser!.uid &&
      //         message.status.name == MessageStatus.delivered.name) {
      //       updateChat(roomId: room.id, messageId: message.id);
      //     }
      //   }
      // }
    });
  }

  void _processVoiceMessage(Map<String, dynamic> data) {
    data[MEDIA_PATH] = data['message'] ?? data[MEDIA_PATH];
    if (data['message_type'] == MessageType.voice.name && kDebugMode && kIsWeb) {
      data[TEXT] = 'Web doesn\'t support voice message yet.';
      data['message_type'] = MessageType.text.name;
    }
    if (data['message_type'] == MessageType.voice.name && data['sentBy'] == firebaseAuth.currentUser!.uid) {
      String? path = LocalData.instance.getAudioPath(data['id']);

      if (path != null && File(path).existsSync()) {
        data[MEDIA_PATH] = path;
      }
    }
  }

  Future<List<PreviewImage>> getMoreImages({required Room room, required Object startAfter}) async {
    try {
      return await firebaseFirestore
          .collection('rooms/${room.id}/messages')
          .where('message_type', isEqualTo: MessageType.image.name)
          .orderBy('createdAt', descending: true)
          .startAfter([startAfter])
          .limit(10)
          .get()
          .then(
            (value) => value.docs.fold<List<PreviewImage>>([], (previousValue, doc) {
              final data = doc.data();

              return [
                ...previousValue,
                PreviewImage(
                  id: doc.id,
                  uri: data[MEDIA_PATH] ?? data['message'],
                  createdAt: data['createdAt'].millisecondsSinceEpoch,
                ),
              ];
            }),
          );
    } catch (e) {
      debugModePrint(e.toString());
      return [];
    }
  }

  Future<List<Message>> initialMessages(
    Room room, {
    List<Object?>? endAt,
    List<Object?>? endBefore,
    int? limit,
    List<Object?>? startAfter,
    List<Object?>? startAt,
  }) async {
    var query = firebaseFirestore.collection('rooms/${room.id}/messages').orderBy('createdAt', descending: true);

    if (endAt != null) {
      query = query.endAt(endAt);
    }

    if (endBefore != null) {
      query = query.endBefore(endBefore);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    if (startAfter != null) {
      query = query.startAfter(startAfter);
    }

    if (startAt != null) {
      query = query.startAt(startAt);
    }

    updateUserLastSeen();

    return await query.get().then((snapshot) {
      final List<Message> list = snapshot.docs.fold<List<Message>>(
        [],
        (previousValue, doc) {
          final data = doc.data();
          final author = room.users.firstWhere(
            (u) => u.id == (data['authorId'] ?? data['sentBy']),
            orElse: () => User(id: data['authorId'] as String),
          );
          final otherUser = room.users.firstWhere(
            (u) => u.id != (data['authorId'] ?? data['sentBy']),
            orElse: () => User(id: data['authorId'] as String),
          );

          data['sentBy'] = author.id;
          data['createdAt'] = data['createdAt'] == null
              ? DateTime.now()
              : DateTime.fromMillisecondsSinceEpoch(data['createdAt']?.millisecondsSinceEpoch);
          data['updatedAt'] = data['updatedAt'] == null
              ? DateTime.now()
              : DateTime.fromMillisecondsSinceEpoch(data['updatedAt']?.millisecondsSinceEpoch);
          data['id'] = doc.id;
          data['message_type'] = data['type'] ?? data['message_type'];

          if (data['type'] == MessageType.text.name || data['message_type'] == MessageType.text.name) {
            data[TEXT] = data[TEXT];
          }
          if (data['message_type'] == MessageType.image.name) {
            data[MEDIA_PATH] = data['uri'] ?? data[MEDIA_PATH] ?? data['message'];
            data[TEXT] = data['caption'] ?? data[TEXT];
          }

          _processVoiceMessage(data);

          final authorUnreaded = room.unreadedTotal!.firstWhere(
            (element) => element.uid == author.id,
          );
          final otherUserUnreaded = room.unreadedTotal!.firstWhere(
            (element) => element.uid == otherUser.id,
          );

          bool readedByAuthor = data['sentBy'] == otherUser.id &&
              DateTime.fromMillisecondsSinceEpoch(authorUnreaded.lastReadedAt.millisecondsSinceEpoch + 1).isAfter(
                DateTime.fromMillisecondsSinceEpoch(data['createdAt']?.millisecondsSinceEpoch),
              );

          bool readedByOhterUser = data['sentBy'] == author.id &&
              DateTime.fromMillisecondsSinceEpoch(otherUserUnreaded.lastReadedAt.millisecondsSinceEpoch + 1)
                  .isAfter(
                DateTime.fromMillisecondsSinceEpoch(data['createdAt']?.millisecondsSinceEpoch),
              );

          if (doc.metadata.hasPendingWrites) {
            data['status'] = MessageStatus.pending.name;
          } else if (readedByAuthor || readedByOhterUser) {
            data['status'] = MessageStatus.read.name;
          }
          // else {
          //   data['status'] = MessageStatus.delivered.name;
          // }

          return [...previousValue, Message.fromJson(data)];
        },
      );
      // if (list.isNotEmpty) {
      //   for (var message in list) {
      //     if (message.sentBy != firebaseAuth.currentUser!.uid &&
      //         message.status.name == MessageStatus.delivered.name) {
      //       updateChat(roomId: room.id, messageId: message.id);
      //     }
      //   }
      // }

      if (list.length > 2) {
        _messages.clear();
      }
      list.removeWhere(
        (element) {
          return element.messageType == MessageType.image &&
              element.status == MessageStatus.pending &&
              element.sentBy != firebaseAuth.currentUser!.uid;
        },
      );
      _messages.addAll(list.reversed.toList());
      return list.reversed.toList();
    });
  }

  Future<List<Message>> getMessages(
    Room room, {
    List<Object?>? endAt,
    List<Object?>? endBefore,
    int? limit,
    List<Object?>? startAfter,
    List<Object?>? startAt,
  }) {
    var query = firebaseFirestore.collection('rooms/${room.id}/messages').orderBy('createdAt', descending: false);

    if (endAt != null) {
      query = query.endAt(endAt);
    }

    if (endBefore != null) {
      query = query.endBefore(endBefore);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    if (startAfter != null) {
      query = query.startAfter(startAfter);
    }

    if (startAt != null) {
      query = query.startAt(startAt);
    }

    return query.get().then((snapshot) {
      _chatDocs.addAll(snapshot.docs);
      return snapshot.docs.fold<List<Message>>(
        [],
        (previousValue, doc) {
          final data = doc.data();
          final author = room.users.firstWhere(
            (u) => u.id == (data['authorId'] ?? data['sentBy']),
            orElse: () => User(id: data['authorId'] as String),
          );

          data['sentBy'] = author.id;
          data['createdAt'] = DateTime.fromMillisecondsSinceEpoch(data['createdAt']?.millisecondsSinceEpoch);

          data['id'] = data['id'] ?? doc.id;
          data['updatedAt'] = data['updatedAt'] == null
              ? DateTime.now()
              : DateTime.fromMillisecondsSinceEpoch(data['updatedAt']?.millisecondsSinceEpoch);
          data['message_type'] = data['type'] ?? data['message_type'];
          if (data['type'] == MessageType.text.name || data['message_type'] == MessageType.text.name) {
            data['message'] = data['text'] ?? data['message'];
          }
          if (data['message_type'] == MessageType.image.name) {
            data['message'] = data['uri'] ?? data['message'];
          }
          return [...previousValue, Message.fromJson(data)];
        },
      );
    });
  }

  Stream<List<Room>> rooms({bool orderByUpdatedAt = false}) {
    final fu = firebaseAuth.currentUser;
    try {
      if (fu == null) return const Stream.empty();

      final collection = orderByUpdatedAt
          ? firebaseFirestore
              .collection('rooms')
              .where('userIds', arrayContains: fu.uid)
              .orderBy('updatedAt', descending: true)
          : firebaseFirestore.collection('rooms').where('userIds', arrayContains: fu.uid);

      return collection.snapshots().asyncMap(
            (query) => processRoomsQuery(fu, firebaseFirestore, query, 'users'),
          );
    } catch (e) {
      debugModePrint('rooms $e');
      return Stream.empty();
    }
  }

  Stream<List<Message>> getLastMessages(Room room) {
    final query = firebaseFirestore.collection('rooms/${room.id}/messages').orderBy('createdAt', descending: true);

    updateUserLastSeen();

    return query.limit(1).snapshots().map(
          (snapshot) => snapshot.docs.fold<List<Message>>(
            [],
            (previousValue, doc) {
              final data = doc.data();

              data['id'] = data['id'] ?? doc.id;
              data['createdAt'] = data['createdAt'] == null
                  ? DateTime.now()
                  : DateTime.fromMillisecondsSinceEpoch(data['createdAt']?.millisecondsSinceEpoch);

              // data['updatedAt'] = data['updatedAt'] ?? DateTime.now();
              data['message_type'] = data['type'] ?? data['message_type'];
              if (data['type'] == MessageType.text.name || data['message_type'] == MessageType.text.name) {
                data['message'] = data['text'] ?? data['message'];
              }
              if (data['message_type'] == MessageType.image.name) {
                data['message'] = data['uri'] ?? data['message'];
              }
              return [...previousValue, Message.fromJson(data)];
            },
          ),
        );
  }

  Future<Message?> _getLastMessage(Room room) async {
    try {
      final query = firebaseFirestore.collection('rooms/${room.id}/messages');

      updateUserLastSeen();

      final String uid = room.users.firstWhere((element) => element.id != firebaseAuth.currentUser!.uid).id;

      final result = await query
          .where(
            'sentBy',
            isEqualTo: uid,
          ) // Filter by authorId
          .orderBy('createdAt', descending: true)
          .get();

      if (result.docs.isEmpty) {
        return null;
      }

      final data = result.docs.first.data();

      data['id'] = data['id'] ?? result.docs.first.id;
      data['createdAt'] = data['createdAt'] == null
          ? DateTime.now()
          : DateTime.fromMillisecondsSinceEpoch(data['createdAt']?.millisecondsSinceEpoch);

      return Message.fromJson(data);
    } on Exception catch (e) {
      debugModePrint('getLastMessage $e');
      return null;
    }
  }

  Future<void> deleteMessage({required Room room, required Message message}) async {
    try {
      await firebaseFirestore.collection('rooms/${room.id}/messages').doc(message.id).delete();
    } catch (e) {
      debugModePrint(e.toString());
    }
  }

  Future<void> updateChat({required Room room, required Message message}) async {
    firebaseFirestore.collection('rooms').doc(room.id).collection('messages').doc(message.id).update({
      'status': MessageStatus.read.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    DocumentReference ref = firebaseFirestore.collection('rooms').doc(room.id);
    DocumentReference unreadedRef = firebaseFirestore.collection('rooms').doc(room.id).collection('status').doc();
    firebaseFirestore.runTransaction(
      (transaction) async {
        await transaction.get(ref).then(
          (value) {
            final roomMap = value.data() as Map<String, dynamic>;

            roomMap['users'] =
                ((value.data() as Map<String, dynamic>)['userIds'] as List).map((e) => {'uid': e}).toList();
            roomMap['createdAt'] = roomMap['createdAt']?.millisecondsSinceEpoch;
            roomMap['updatedAt'] = roomMap['updatedAt']?.millisecondsSinceEpoch;
            final Room room = Room.fromJson(roomMap);

            final UnreadedTotal otherUnreaded = room.unreadedTotal!.firstWhere(
              (element) {
                return element.uid != firebaseAuth.currentUser!.uid;
              },
            );
            final UnreadedTotal userUnreaded = room.unreadedTotal!.firstWhere(
              (element) {
                return element.uid == firebaseAuth.currentUser!.uid;
              },
            );
            transaction.update(ref, {
              'id': value.id,
              'updatedAt': FieldValue.serverTimestamp(),
              'unreadedTotal': [
                {
                  'uid': otherUnreaded.uid,
                  'total': otherUnreaded.total,
                  'lastReadedAt': otherUnreaded.lastReadedAt,
                },
                {
                  'uid': firebaseAuth.currentUser!.uid,
                  'total': 0,
                  'lastReadedAt': _messages.last.createdAt,
                }
              ]
            });
          },
        );
      },
    );
  }

  Future<void> setReactions({
    required String roomId,
    required Message message,
    required String reaction,
  }) async {
    DocumentReference ref =
        firebaseFirestore.collection('rooms').doc(roomId).collection('messages').doc(message.id);

    updateUserLastSeen();

    firebaseFirestore.runTransaction(
      (transaction) {
        return transaction.get(ref).then(
          (value) {
            var msgMap = value.data() as Map<String, dynamic>;
            msgMap['createdAt'] = DateTime.fromMillisecondsSinceEpoch(msgMap['createdAt']?.millisecondsSinceEpoch);
            msgMap['updatedAt'] = DateTime.fromMillisecondsSinceEpoch(msgMap['updatedAt']?.millisecondsSinceEpoch);

            final Message messageObj = Message.fromJson(msgMap);
            final List<String> reactedUseerIds = messageObj.reaction.reactedUserIds;
            var reactions = messageObj.reaction.reactions;

            int userIndex = reactedUseerIds.indexOf(message.sentBy);
            if (reactedUseerIds.contains(firebaseAuth.currentUser!.uid) && userIndex != -1) {
              reactedUseerIds.remove(firebaseAuth.currentUser!.uid);
              reactions.removeAt(userIndex);
            }
            transaction.update(ref, {
              'id': value.id,
              'updatedAt': FieldValue.serverTimestamp(),
              'reaction': {
                'reactedUserIds': FieldValue.arrayUnion([firebaseAuth.currentUser!.uid]),
                'reactions': [...reactions, reaction],
              }
            });
          },
        );
      },
    );
  }

  Future<void> doubleTapReactions({
    required String roomId,
    required Message message,
    required String reaction,
  }) async {
    DocumentReference ref =
        firebaseFirestore.collection('rooms').doc(roomId).collection('messages').doc(message.id);
    firebaseFirestore.runTransaction(
      (transaction) {
        return transaction.get(ref).then(
          (value) {
            var msgMap = value.data() as Map<String, dynamic>;
            msgMap['createdAt'] = DateTime.fromMillisecondsSinceEpoch(msgMap['createdAt']?.millisecondsSinceEpoch);
            msgMap['updatedAt'] = DateTime.fromMillisecondsSinceEpoch(msgMap['updatedAt']?.millisecondsSinceEpoch);
            final Message messageObj = Message.fromJson(msgMap);
            final List<String> reactedUseerIds = messageObj.reaction.reactedUserIds;
            var reactions = messageObj.reaction.reactions;

            int userIndex = reactedUseerIds.indexOf(firebaseAuth.currentUser!.uid);
            if (reactedUseerIds.contains(firebaseAuth.currentUser!.uid)) {
              reactedUseerIds.remove(firebaseAuth.currentUser!.uid);
              reactions.removeAt(userIndex);
              transaction.update(ref, {
                'id': value.id,
                'updatedAt': FieldValue.serverTimestamp(),
                'reaction': {
                  'reactedUserIds': FieldValue.arrayRemove([firebaseAuth.currentUser!.uid]),
                  'reactions': reactions,
                }
              });
            } else {
              transaction.update(ref, {
                'id': value.id,
                'updatedAt': FieldValue.serverTimestamp(),
                'reaction': {
                  'reactedUserIds': FieldValue.arrayUnion([firebaseAuth.currentUser!.uid]),
                  'reactions': [...reactions, reaction],
                }
              });
            }
          },
        );
      },
    );
  }

  Future<void> removeReactions({
    required String roomId,
    required Message message,
  }) async {
    DocumentReference ref =
        firebaseFirestore.collection('rooms').doc(roomId).collection('messages').doc(message.id);
    firebaseFirestore.runTransaction(
      (transaction) {
        return transaction.get(ref).then(
          (value) {
            String currentUserUid = firebaseAuth.currentUser!.uid;
            final Message messageObj = Message.fromJson(value.data() as Map<String, dynamic>);
            final List<String> reactedUseerIds = messageObj.reaction.reactedUserIds;
            var reactions = messageObj.reaction.reactions;

            int userIndex = reactedUseerIds.indexOf(currentUserUid);

            reactedUseerIds.remove(currentUserUid);
            reactions.removeAt(userIndex);
            transaction.update(ref, {
              'id': value.id,
              'updatedAt': FieldValue.serverTimestamp(),
              'reaction': {
                'reactedUserIds': FieldValue.arrayRemove([currentUserUid]),
                'reactions': reactions,
              }
            });
          },
        );
      },
    );
  }
}
