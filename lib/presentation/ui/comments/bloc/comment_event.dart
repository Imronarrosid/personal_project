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

class UnfocusForm extends CommentEvent {}

class RemoveLocaleCommentEvent extends CommentEvent {}

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
  final String repliedUid;

  const PostReplyEvent({
    required this.postId,
    required this.repliedUid,
    required this.reply,
    required this.commentId,
  });

  @override
  List<Object> get props => [
        postId,
        reply,
        commentId,
        repliedUid,
      ];
}

class StartReply extends CommentEvent {
  final String usernameReplied;
  final String uid;

  const StartReply({
    required this.usernameReplied,
    required this.uid,
  });

  @override
  List<Object> get props => [
        super.props,
        usernameReplied,
        uid,
      ];
}
