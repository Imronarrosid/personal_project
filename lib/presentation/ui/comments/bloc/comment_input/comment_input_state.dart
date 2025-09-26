part of 'comment_input_bloc.dart';

@freezed
abstract class CommentInputState with _$CommentInputState {
  const factory CommentInputState({
    @Default(CommentInputStatus.initial) CommentInputStatus status,
    @Default('') String text,
    Comment? comment,
    @Default(false) bool isReply,
    String? postId,
    String? repliedUserName,
    String? repliedCommentId,
    String? repliedUserId,
  }) = _CommentInputState;
}

enum CommentInputStatus {
  initial,
  typing,
  uploading,
  success,
  error,
  isReply,
}

extension CommentInputStatusExtension on CommentInputStatus {
  bool get isInitial => this == CommentInputStatus.initial;
  bool get isUploading => this == CommentInputStatus.uploading;
  bool get isSuccess => this == CommentInputStatus.success;
  bool get isError => this == CommentInputStatus.error;
  bool get isTyping => this == CommentInputStatus.typing;
  bool get isReply => this == CommentInputStatus.isReply;
}
