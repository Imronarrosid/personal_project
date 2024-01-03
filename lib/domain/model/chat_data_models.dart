import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class ChatData {
  final types.Room room;
  final String userName;
  final String avatar;

  ChatData({
    required this.room,
    required this.userName,
    required this.avatar,
  });
}
