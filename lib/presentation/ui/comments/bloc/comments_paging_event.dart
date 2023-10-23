part of 'comments_paging_bloc.dart';

sealed class CommentsPagingEvent extends Equatable {
  const CommentsPagingEvent();

  @override
  List<Object> get props => [];
}
class InitCommentsPagingEvent extends CommentsPagingEvent{
  final String postId;

  const InitCommentsPagingEvent({required this.postId});

  @override
  List<Object> get props => [postId];
}
