import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import 'package:flutter/material.dart';
import 'package:personal_project/domain/model/message_model.dart';
import 'package:personal_project/domain/services/firebase/firebase_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/v4.dart';
import 'package:uuid/v8.dart';

class MabarChatRepository {
  final DatabaseReference _db = firebaseRealTimeDatabse.ref();

  User? firebaseUser = FirebaseAuth.instance.currentUser;
  int _joinedRoom = 0;
  int get joinedRoom => _joinedRoom;
  bool _isJoined = false;

  List<types.Message> mabarMessages = [];
  static StreamController<List<types.Message>> messagesStreamController =
      BehaviorSubject<List<types.Message>>();

  Stream<List<types.Message>> messagesStream = messagesStreamController.stream
      .debounceTime(Duration(milliseconds: 120))
      .asBroadcastStream();

  static StreamController<int> joinedRoomStreamController =
      BehaviorSubject<int>();
  Stream<int> joinedRoomStream = joinedRoomStreamController.stream
      .debounceTime(Duration(milliseconds: 120))
      .asBroadcastStream();

  listenMessageEvent(VoidCallback setState) async {
    // if (messagesStreamController.isClosed) {
    //   messagesStreamController =
    //       StreamController<List<types.Message>>.broadcast();
    //   joinedRoomStreamController = StreamController<int>.broadcast();
    // }

    try {
      final newestChild = _db
          .child('chat_update')
          .orderByChild('createdAt')
          .limitToLast(1)
          .once();

      final resurl = await newestChild;
      final dynamic data = resurl.snapshot.value;
      dynamic mabarKey;
      for (var element in (data as Map<dynamic, dynamic>).entries) {
        mabarKey = element.key;
        break;
      }
      debugPrint('mabar last $data');
      final createdAt = data[mabarKey]['createdAt'];
      _db
          .child('chat_update')
          .orderByChild('createdAt')
          .startAt(createdAt)
          .onChildAdded
          .where((event) {
        final dynamic dataEvent = event.snapshot.value;
        if (dataEvent['createdAt'] > createdAt) {
          return true;
        }
        return false;
      }).listen((data) {
        debugPrint('mabar ' + data.snapshot.value.toString());
        dynamic mabarEvent = data.snapshot.value;
        final type = mabarEvent['type'];

        final types.Message chat;

        switch (type) {
          case types.MessageType.text:
            chat = types.TextMessage(
                author: types.User(
                    id: mabarEvent['author']['id'],
                    firstName: mabarEvent['author']['firstName']),
                id: mabarEvent['id'],
                text: mabarEvent['text'],
                createdAt: mabarEvent['createdAt'],
                updatedAt: mabarEvent['updatedAt'],
                type: types.MessageType.text);
            break;

          default:
            chat = types.TextMessage(
                author: types.User(
                    id: mabarEvent['author']['id'],
                    firstName: mabarEvent['author']['firstName']),
                id: mabarEvent['id'],
                text: mabarEvent['text'],
                createdAt: mabarEvent['createdAt'],
                updatedAt: mabarEvent['updatedAt'],
                type: types.MessageType.text);
        }
        if (!mabarMessages.contains(types.Message.fromJson(chat.toJson()))) {
          mabarMessages.insert(
            0,
            types.Message.fromJson(chat.toJson()),
          );
        }
        messagesStreamController.add(mabarMessages);
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void joinRoom() {
    try {
      final ref = _db.child('joined');
      if (firebaseUser != null && !_isJoined) {
        ref.runTransaction((value) {
          debugPrint('joined $value');
          final dynamic joindata = value;
          if (value == null) {
            return Transaction.abort();
          }
          _isJoined = true;
          return Transaction.success({
            'joined': (joindata['joined'] as int) + 1,
          });
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  leaveRoom() {
    final ref = _db.child('joined');
    if (firebaseUser != null && _isJoined) {
      ref.runTransaction((transaction) {
        final dynamic data = transaction;
        int result = (data['joined'] as int) - 1;
        result = result < 0 ? 0 : result;
        if (transaction == null) {
          return Transaction.abort();
        }
        _isJoined = false;
        return Transaction.success({'joined': result});
      });
    }
    messagesStreamController.close();
    joinedRoomStreamController.close();
  }

  lisentJoinedRoom() {
    try {
      _db.child('joined').onValue.listen((event) {
        if (messagesStreamController.isClosed) {
          messagesStreamController = BehaviorSubject<List<types.Message>>();
          messagesStream = messagesStreamController.stream;
        }
        if (joinedRoomStreamController.isClosed) {
          joinedRoomStreamController = BehaviorSubject<int>();
          joinedRoomStream = joinedRoomStreamController.stream;
        }
        final dynamic data = event.snapshot.value;
        debugPrint('joined ${data.toString()}');
        joinedRoomStreamController.add(data['joined']);
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Sends a message to the Firestore. Accepts any partial message and a
  /// room ID. If arbitraty data is provided in the [partialMessage]
  /// does nothing.
  void sendMabarMessage(dynamic partialMessage, String roomId) async {
    if (firebaseUser == null) return;

    types.Message? message;

    if (partialMessage is types.PartialCustom) {
      message = types.CustomMessage.fromPartial(
        author: types.User(id: firebaseUser!.uid),
        id: '',
        partialCustom: partialMessage,
      );
    } else if (partialMessage is types.PartialFile) {
      message = types.FileMessage.fromPartial(
        author: types.User(id: firebaseUser!.uid),
        id: '',
        partialFile: partialMessage,
      );
    } else if (partialMessage is types.PartialImage) {
      message = types.ImageMessage.fromPartial(
        author: types.User(id: firebaseUser!.uid),
        id: '',
        partialImage: partialMessage,
      );
    } else if (partialMessage is types.PartialText) {
      message = types.TextMessage.fromPartial(
        author: types.User(id: firebaseUser!.uid),
        id: '',
        partialText: partialMessage,
      );
    }

    if (message != null) {
      String username;

      firestore.DocumentSnapshot snap = await firebaseFirestore
          .collection('userNames')
          .doc(firebaseUser!.uid)
          .get();

      username = snap['userName'];
      final messageMap = message.toJson();
      // messageMap.removeWhere((key, value) => key == 'author' || key == 'id');
      messageMap['authorId'] = firebaseUser!.uid;
      messageMap['createdAt'] = ServerValue.timestamp;
      messageMap['updatedAt'] = ServerValue.timestamp;
      messageMap['author'] =
          types.User(id: firebaseUser!.uid, firstName: username).toJson();
      messageMap['id'] = const Uuid().v4();
      _db.child('chat_update').child(messageMap['id']).set(messageMap);
    }
  }

  Alignment setMessageAlignment(String senderName, String userName) {
    switch (senderName == userName) {
      case true:
        return Alignment.topRight;
      case false:
        return Alignment.topLeft;
    }
  }
}
