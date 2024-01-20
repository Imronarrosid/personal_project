part of 'video_player_bloc.dart';

enum VideoPlayerStatus {
  initial,
  initialized,
  playing,
  disposed,
  paused,
  buffering,
  videoDeleted,
  error,
}

class VideoPlayerState extends Equatable {
  final VideoPlayerStatus status;
  final CachedVideoPlayerController? controller;
  final String? error;

  const VideoPlayerState({
    required this.status,
    this.controller,
    this.error,
  });

  @override
  List<Object?> get props => [status, controller, error];
}

final class VideoPlayerInitial extends VideoPlayerState {
  const VideoPlayerInitial({super.status = VideoPlayerStatus.initial});
}
