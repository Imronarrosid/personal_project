part of 'video_player_bloc.dart';

enum VideoEvent {
  initialize,
  play,
  pause,
}

class VideoPlayerEvent extends Equatable {
  final VideoEvent actions;
  final String? videoUrl;
  const VideoPlayerEvent({
    required this.actions,
    this.videoUrl,
  });

  @override
  List<Object?> get props => [actions, videoUrl];
}
