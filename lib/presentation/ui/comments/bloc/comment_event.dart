part of 'comment_bloc.dart';

sealed class CommentEvent extends Equatable {
  const CommentEvent();

  @override
  List<Object> get props => [];
}

class AddComentEvent extends CommentEvent {}

class PostCommentEvent extends CommentEvent {
  final String comment;

  const PostCommentEvent({required this.comment});

  @override
  List<Object> get props => [comment];
}
