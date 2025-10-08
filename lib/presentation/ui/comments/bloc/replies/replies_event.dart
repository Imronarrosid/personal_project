part of 'replies_bloc.dart';

@freezed
class RepliesEvent with _$RepliesEvent {
  const factory RepliesEvent.loadReplies({
    required String postId,
    required String commentId,
  }) = _LoadRepliesEvent;

  const factory RepliesEvent.hideReplies() = _HideRepliesEvent;

  const factory RepliesEvent.addReply({
    required String commentId,
    required Reply reply,
  }) = _AddReplyEvent;

  const factory RepliesEvent.removeReply({
    required String commentId,
    required String replyId,
  }) = _RemoveReplyEvent;

  const factory RepliesEvent.likeReply({
    required String replyId,
    required String postId,
    required String commentId,
    required bool isLiked,
  }) = _LikeReplyEvent;

  const factory RepliesEvent.updateReply({
    required Reply reply,
  }) = _UpdateReplyEvent;
}