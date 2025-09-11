part of 'comment_input_bloc.dart';

@freezed
class CommentInputEvent with _$CommentInputEvent {
  const factory CommentInputEvent.openIput({
    required String postId,
    @Default(false) bool isReply,
    String? repliedUserName,
    String? repliedCommentId,
    String? repliedUserId,
  }) = _OpenInput;
  const factory CommentInputEvent.textChanged({
    required String text,
  }) = _TextChanged;

  const factory CommentInputEvent.submitComment({
    required String commentMessage,
  }) = _SubmitComment;

  const factory CommentInputEvent.submitReply({
    required String commentMessage,
  }) = _SubmitReply;

  const factory CommentInputEvent.clearInput() = _ClearInput;
}
