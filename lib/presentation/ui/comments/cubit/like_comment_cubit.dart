import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:personal_project/data/repository/coment_repository.dart';

part 'like_comment_state.dart';

class LikeCommentCubit extends Cubit<LikeCommentState> {
  LikeCommentCubit(
    this.repository,
  ) : super(LikeCommentInitial());

   bool? isCommentLiked;
  likeComment(
      {required String postId,
      required String commentId,
      required bool isLiked}) async {
    isCommentLiked ??= isLiked;
    repository.likeComment(id: commentId, postId: postId);

    isCommentLiked! ? emit(UnilkedComment()) : emit(CommentLiked());
    isCommentLiked = !isCommentLiked!;
  }

  final CommentRepository repository;
}
