part of 'comment_bloc.dart';

sealed class CommentState extends Equatable {
  const CommentState();

  @override
  List<Object> get props => [];
}

final class CommentInitial extends CommentState {}

final class AddComentState extends CommentState {}

final class RefreshComentState extends CommentState {}

final class ComentAddedState extends CommentState {
  final Comment comment;

  const ComentAddedState({required this.comment});

  @override
  List<Object> get props => [comment];
}
