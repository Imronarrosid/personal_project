part of 'like_comment_cubit.dart';

sealed class LikeCommentState extends Equatable {
  const LikeCommentState();

  @override
  List<Object> get props => [];
}

final class LikeCommentInitial extends LikeCommentState {}

final class CommentLiked extends LikeCommentState {
  final int likeCount;

  const CommentLiked({required this.likeCount});

  @override
  List<Object> get props => [likeCount];
}

final class UnilkedComment extends LikeCommentState {
  final int likeCount;

  const UnilkedComment({required this.likeCount});

  @override
  List<Object> get props => [likeCount];
}
