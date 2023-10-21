part of 'video_player_bloc.dart';

sealed class VideoPlayerEvent extends Equatable {
  const VideoPlayerEvent();

  @override
  List<Object> get props => [];
}

class InitVideoPlayer extends VideoPlayerEvent {
  final CachedVideoPlayerController controller;
  final String ownerUid;

  const InitVideoPlayer({required this.controller, required this.ownerUid});

  @override
  List<Object> get props => [controller, ownerUid];
}

class PauseVideo extends VideoPlayerEvent {}

class InitVideoPlayerEvent extends VideoPlayerEvent {
  final String url;

  const InitVideoPlayerEvent({required this.url});

  @override
  List<Object> get props => [url];
}
