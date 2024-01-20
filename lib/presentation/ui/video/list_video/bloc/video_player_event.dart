part of 'video_player_bloc.dart';

enum VideoEvent {
  initialize,
  play,
  pause,
  delete,
  dispose,
  showBufferingIndicator,
  removeBufferingIndicator,
}

final class VideoPlayerEvent extends Equatable {
  final VideoEvent actions;
  final String? videoUrl;
  final String? postId;
  final String? thumnailUrl;
  const VideoPlayerEvent({
    required this.actions,
    this.videoUrl,
    this.postId,
    this.thumnailUrl,
  });

  @override
  List<Object?> get props => [
        actions,
        videoUrl,
        postId,
        thumnailUrl,
      ];
}
