part of 'video_player_bloc.dart';

sealed class VideoPlayerState extends Equatable {
  const VideoPlayerState();

  @override
  List<Object> get props => [];
}

final class VideoPlayerInitial extends VideoPlayerState {}

final class VideoPreviewInitial extends VideoPlayerState {}

final class VideoPlayerIntialized extends VideoPlayerState {
  final User? ownerData;
  final CachedVideoPlayerController? videoPlayerController;
  const VideoPlayerIntialized({this.videoPlayerController, this.ownerData});

  @override
  List<Object> get props => [videoPlayerController!, ownerData!];
}

final class VideoPlayerError extends VideoPlayerState {
  final String? error;

  const VideoPlayerError({this.error});

  @override
  List<Object> get props => [error!];
}

final class VideoPaused extends VideoPlayerState {
  final double? opacity;
  final double? size;

  const VideoPaused({this.size, this.opacity});

  @override
  List<Object> get props => [opacity!, size!];
}
