part of 'video_size_cubit.dart';

sealed class VideoSizeState extends Equatable {
  const VideoSizeState();

  @override
  List<Object> get props => [];
}

final class VideoSizeInitial extends VideoSizeState {}

final class VideoSizeChanged extends VideoSizeState {
  final double size;

  const VideoSizeChanged({required this.size});
  @override
  List<Object> get props => [
        super.props,
        size,
      ];
}
