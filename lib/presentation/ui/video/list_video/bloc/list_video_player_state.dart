part of 'list_video_player_bloc.dart';

sealed class ListVideoPlayerState extends Equatable {
  const ListVideoPlayerState();

  @override
  List<Object> get props => [];
}

final class ListVideoPlayerInitial extends ListVideoPlayerState {}

final class VideoState extends ListVideoPlayerState {
  final VideoStatus status;
  final LikeStatus likeStatus;

  /// inidicating which video player index are targeted.
  final int index;

  const VideoState({
    required this.index,
    required this.status,
    this.likeStatus = LikeStatus.initial,
  });

  @override
  List<Object> get props => [
        super.props,
        status,
        likeStatus,
        index,
      ];
}

enum VideoStatus {
  initial,
  loading,
  initialized,
  playing,
  paused,
}

enum LikeStatus {
  initial,
  liked,
  unliked,
  doubleTapLike,
  error,
}

extension VideoPlayerX on VideoStatus {
  bool get isInitialized => this == VideoStatus.initialized;
  bool get playing => this == VideoStatus.playing;
  bool get paused => this == VideoStatus.paused;
  bool get initial => this == VideoStatus.initial;
  bool get loadig => this == VideoStatus.loading;
}

extension LikeStatusX on LikeStatus {
  bool get initial => this == LikeStatus.initial;
  bool get liked => this == LikeStatus.liked;
  bool get unliked => this == LikeStatus.unliked;
  bool get error => this == LikeStatus.error;
  bool get doubleTapLike => this == LikeStatus.doubleTapLike;
}
