part of 'comment_bloc.dart';

sealed class CommentEvent extends Equatable {
  const CommentEvent();

  @override
  List<Object> get props => [];
}

class TapCommentForm extends CommentEvent {}

class InputComments extends CommentEvent {}

class TapReplyForm extends CommentEvent {}

class TypingReply extends CommentEvent {}

class RefreshComentEvent extends CommentEvent {}

class PostCommentEvent extends CommentEvent {
  final String postId;
  final String comment;

  const PostCommentEvent({required this.postId, required this.comment});

  @override
  List<Object> get props => [postId, comment];
}

class PostReplyEvent extends CommentEvent {
  final String postId;
  final String reply;
  final String commentId;

  const PostReplyEvent({
    required this.postId,
    required this.reply,
    required this.commentId,
  });

  @override
  List<Object> get props => [
        postId,
        reply,
        commentId,
      ];
}

final class InitReply extends CommentEvent {
  final String commentId;
  final Comment comment;

  const InitReply({
    required this.commentId,
    required this.comment,
  });

  @override
  List<Object> get props => [
        super.props,
        commentId,
        comment,
      ];
}
