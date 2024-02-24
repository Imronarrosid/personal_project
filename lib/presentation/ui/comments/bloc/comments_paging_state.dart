part of 'comments_paging_bloc.dart';

sealed class CommentsPagingState extends Equatable {
  const CommentsPagingState();

  @override
  List<Object> get props => [];
}

final class CommentsPagingInitial extends CommentsPagingState {}

final class RemoveLocaleComment extends CommentsPagingState {}

final class CommentsPagingInitialized extends CommentsPagingState {
  final PagingController<int, Comment>? controller;

  const CommentsPagingInitialized({required this.controller});

  @override
  List<Object> get props => [controller!];
}
