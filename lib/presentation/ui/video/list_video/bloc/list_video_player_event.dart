part of 'list_video_player_bloc.dart';

sealed class ListVideoPlayerEvent extends Equatable {
  final int index;
  const ListVideoPlayerEvent({
    required this.index,
  });

  @override
  List<Object> get props => [
        index,
      ];
}

class InitVideoPlayer extends ListVideoPlayerEvent {
  final CachedVideoPlayerPlusController controller;

  const InitVideoPlayer({
    required this.controller,
    required super.index,
  });

  @override
  List<Object> get props => [
        super.props,
        controller,
      ];
}

class PlayVideo extends ListVideoPlayerEvent {
  final CachedVideoPlayerPlusController controller;

  const PlayVideo({
    required this.controller,
    required super.index,
  });

  @override
  List<Object> get props => [
        super.props,
        controller,
      ];
}

class PauseVideo extends ListVideoPlayerEvent {
  final CachedVideoPlayerPlusController controller;

  const PauseVideo({
    required this.controller,
    required super.index,
  });

  @override
  List<Object> get props => [
        super.props,
        controller,
      ];
}

class RemovePreviousePauseIcon extends ListVideoPlayerEvent {
  final CachedVideoPlayerPlusController controller;

  const RemovePreviousePauseIcon({
    required this.controller,
    required super.index,
  });

  @override
  List<Object> get props => [
        super.props,
        controller,
      ];
}

class DisposeVideoController extends ListVideoPlayerEvent {
  final CachedVideoPlayerPlusController controller;

  const DisposeVideoController({
    required this.controller,
    required super.index,
  });

  @override
  List<Object> get props => [
        super.props,
        controller,
      ];
}

class LikeVideo extends ListVideoPlayerEvent {
  final Video video;

  const LikeVideo({required this.video, required super.index});

  @override
  List<Object> get props => [
        super.props,
        video,
      ];
}

class DoubleTapLikeVideo extends ListVideoPlayerEvent {
  final Video video;

  const DoubleTapLikeVideo({required this.video, required super.index});

  @override
  List<Object> get props => [
        super.props,
        video,
      ];
}
