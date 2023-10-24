part of 'like_video_cubit.dart';

sealed class LikeVideoState extends Equatable {
  const LikeVideoState();

  @override
  List<Object> get props => [];
}

final class LikeVideoInitial extends LikeVideoState {}

final class UnilkedVideo extends LikeVideoState {
  final int likeCount;

  const UnilkedVideo({required this.likeCount});

  @override
  List<Object> get props => [likeCount];
}

final class VideoIsLiked extends LikeVideoState {
  final int likeCount;

  const VideoIsLiked({required this.likeCount});

  @override
  List<Object> get props => [likeCount];
}
