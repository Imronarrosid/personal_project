part of 'video_from_game_bloc.dart';

sealed class VideoFromGameEvent extends Equatable {
  const VideoFromGameEvent();

  @override
  List<Object> get props => [];
}

class InitVideoFromGame extends VideoFromGameEvent {
  final GameFav game;

  const InitVideoFromGame({required this.game});

  @override
  List<Object> get props => [game];
}
