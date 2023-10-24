import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:personal_project/domain/reporsitory/video_repository.dart';

part 'like_video_state.dart';

class LikeVideoCubit extends Cubit<LikeVideoState> {
  LikeVideoCubit(this.repository) : super(LikeVideoInitial());

  /// bool to store current like state.
  bool? _isLiked;

  /// isLiked represent bool off previous state
  likeComment(
      {required String postId,
      required bool isLiked,
      required int currentLikeCount}) async {
    _isLiked ??= isLiked;
    repository.likeVideo(postId);

    int result = _isLiked! ? currentLikeCount : currentLikeCount + 1;

    _isLiked!
        ? emit(UnilkedVideo(likeCount: result))
        : emit(VideoIsLiked(likeCount: result));
    _isLiked = !_isLiked!;
  }

  final VideoRepository repository;
}
