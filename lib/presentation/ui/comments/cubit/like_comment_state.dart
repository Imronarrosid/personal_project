part of 'like_comment_cubit.dart';

sealed class LikeCommentState extends Equatable {
  const LikeCommentState();

  @override
  List<Object> get props => [];
}

final class LikeCommentInitial extends LikeCommentState {}

final class CommentLiked extends LikeCommentState {}

final class UnilkedComment extends LikeCommentState {}
