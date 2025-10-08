part of 'replies_bloc.dart';

@freezed
abstract class RepliesState with _$RepliesState {
  const factory RepliesState({
    @Default(RepliesStatus.initial) RepliesStatus status,
    @Default(<Reply>[]) List<Reply> replies,
    @Default(false) bool isLastReply,
  }) = _RepliesState;
}

enum RepliesStatus {
  initial,
  loading,
  added,
  loaded,
  updated,
  error,
  removed,
  hidden,
  liked,
  unliked,
}

extension RepliesStatusExtension on RepliesStatus {
  bool get isInitial => this == RepliesStatus.initial;
  bool get isAdded => this == RepliesStatus.added;
  bool get isLoading => this == RepliesStatus.loading;
  bool get isLoaded => this == RepliesStatus.loaded;
  bool get isUpdated => this == RepliesStatus.updated;
  bool get isError => this == RepliesStatus.error;
  bool get isRemoved => this == RepliesStatus.removed;
  bool get isHidden => this == RepliesStatus.hidden;
}
