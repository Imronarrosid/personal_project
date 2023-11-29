part of 'comment_bloc.dart';

sealed class CommentEvent extends Equatable {
  const CommentEvent();

  @override
  List<Object> get props => [];
}

class AddComentEvent extends CommentEvent {}

class RefreshComentEvent extends CommentEvent {}

class PostCommentEvent extends CommentEvent {
  final String postId;
  final String comment;

  const PostCommentEvent({required this.postId, required this.comment});

  @override
  List<Object> get props => [postId, comment];
}
