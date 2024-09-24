class MessageModel {
  String sender;
  String msg;

  MessageModel({
    required this.sender,
    required this.msg,
  });

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'msg': msg,
    };
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      sender: json['sender'] as String,
      msg: json['msg'] as String,
    );
  }

  @override
  String toString() => "MessageModel(sender: $sender,msg: $msg)";

  @override
  int get hashCode => Object.hash(sender, msg);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageModel &&
          runtimeType == other.runtimeType &&
          sender == other.sender &&
          msg == other.msg;
}
