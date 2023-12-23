part of 'video_from_game_bloc.dart';

enum VideoFromGameStatus { initial, initialized, error, loading }

final class VideoFromGameState extends Equatable {
  final VideoFromGameStatus status;
  final PagingController<int, Video>? controller;
  const VideoFromGameState({
    required this.status,
    this.controller,
  });

  @override
  List<Object?> get props => [status, controller];
}
