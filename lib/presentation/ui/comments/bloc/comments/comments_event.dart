part of 'comments_bloc.dart';

@freezed
class CommentsEvent with _$CommentsEvent {
  const factory CommentsEvent.loadComments({
    required String postId,
  }) = _LoadCommentsEvent;

  const factory CommentsEvent.addComment({
    required Comment comment,
  }) = _AddCommentEvent;

  const factory CommentsEvent.addReply({
    required String commentId,
    required Comment comment,
  }) = _AddReplyEvent;

  const factory CommentsEvent.removeComment({
    required String commentId,
  }) = _RemoveCommentEvent;

  const factory CommentsEvent.likeComment({
    required String commentId,
    required String postId,
    required bool isLiked,
  }) = _LikeCommentEvent;

  const factory CommentsEvent.updateComment({
    required Comment comment,
  }) = _UpdateCommentEvent;
}
