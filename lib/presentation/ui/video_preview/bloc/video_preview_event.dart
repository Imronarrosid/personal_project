part of 'video_preview_bloc.dart';

sealed class VideoPreviewEvent extends Equatable {
  const VideoPreviewEvent();

  @override
  List<Object> get props => [];
}

class InitVideoPlayer extends VideoPreviewEvent {
  final VideoPlayerController controller;

  const InitVideoPlayer({
    required this.controller,
  });

  @override
  List<Object> get props => [controller];
}
class StopVideoPriviewEvent extends VideoPreviewEvent{}
