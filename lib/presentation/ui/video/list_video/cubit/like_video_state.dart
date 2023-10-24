part of 'like_video_cubit.dart';

sealed class LikeVideoState extends Equatable {
  const LikeVideoState();

  @override
  List<Object> get props => [];
}

final class LikeVideoInitial extends LikeVideoState {}

final class UnilkedVideo extends LikeVideoState {}

final class VideoIsLiked extends LikeVideoState {}
