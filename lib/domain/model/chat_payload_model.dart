import 'room_model.dart';

class ChatPayload {
  final Room room;
  final String userName;
  final String avatar;
  final String? name;

  ChatPayload({
    required this.room,
    required this.userName,
    required this.avatar,
    this.name,
  });
}
