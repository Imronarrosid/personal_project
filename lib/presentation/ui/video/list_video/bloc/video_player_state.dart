part of 'video_player_bloc.dart';

sealed class VideoPlayerState extends Equatable {
  const VideoPlayerState();

  @override
  List<Object> get props => [];
}

final class VideoPlayerInitial extends VideoPlayerState {}

final class VideoPreviewInitial extends VideoPlayerState {}

final class VideoPlayerIntialized extends VideoPlayerState {
  final User ownerData;

  const VideoPlayerIntialized({required this.ownerData});

  @override
  List<Object> get props => [ownerData];
}

final class VideoPlayerError extends VideoPlayerState {}
