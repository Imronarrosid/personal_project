part of 'comments_bloc.dart';

@freezed
abstract class CommentsState with _$CommentsState {
  const factory CommentsState({
    @Default(CommentsStatus.initial) CommentsStatus status,
    @Default(<Comment>[]) List<Comment> comments,
  }) = _CommentsState;
}

enum CommentsStatus {
  initial,
  loading,
  loaded,
  updated,
  liked,
  unliked,
  error,
  removed,
}

extension CommentsStatusExtension on CommentsStatus {
  bool get isInitial => this == CommentsStatus.initial;
  bool get isLoading => this == CommentsStatus.loading;
  bool get isLoaded => this == CommentsStatus.loaded;
  bool get isUpdated => this == CommentsStatus.updated;
  bool get isError => this == CommentsStatus.error;
  bool get isRemoved => this == CommentsStatus.removed;
  bool get isLiked => this == CommentsStatus.liked;
  bool get isUnliked => this == CommentsStatus.unliked;
}
