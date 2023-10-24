import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:personal_project/domain/reporsitory/video_repository.dart';

part 'like_video_state.dart';

class LikeVideoCubit extends Cubit<LikeVideoState> {
  LikeVideoCubit(this.repository) : super(LikeVideoInitial());

  bool? _isLiked;
  likeComment({required String postId, required bool isLiked}) async {
    _isLiked ??= isLiked;
    repository.likeVideo(postId);

    _isLiked! ? emit(UnilkedVideo()) : emit(VideoIsLiked());
    _isLiked = !_isLiked!;
  }

  final VideoRepository repository;
}
