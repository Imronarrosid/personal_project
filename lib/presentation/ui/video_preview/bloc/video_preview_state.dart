part of 'video_preview_bloc.dart';

sealed class VideoPreviewState extends Equatable {
  const VideoPreviewState();
  
  @override
  List<Object> get props => [];
}

final class VideoPreviewInitial extends VideoPreviewState {}
final class VideoPlayerIntialized extends VideoPreviewState {}

