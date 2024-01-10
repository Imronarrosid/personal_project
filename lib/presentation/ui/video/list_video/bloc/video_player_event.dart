part of 'video_player_bloc.dart';

enum VideoEvent {
  initialize,
  play,
  pause,
  delete,
}

final class VideoPlayerEvent extends Equatable {
  final VideoEvent actions;
  final String? videoUrl;
  final String? postId;
  const VideoPlayerEvent({
    required this.actions,
    this.videoUrl,
    this.postId,
  });

  @override
  List<Object?> get props => [
        actions,
        videoUrl,
        postId,
      ];
}
