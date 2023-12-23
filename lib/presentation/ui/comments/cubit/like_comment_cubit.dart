import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:personal_project/data/repository/coment_repository.dart';

part 'like_comment_state.dart';

class LikeCommentCubit extends Cubit<LikeCommentState> {
  LikeCommentCubit(
    this.repository,
  ) : super(LikeCommentInitial());

  bool? _clientState;
  likeComment(
      {required String postId,
      required String commentId,
      required bool stateFromDatabase,
      required int databaseLikeCount}) async {
    _clientState ??= stateFromDatabase;
    repository.likeComment(id: commentId, postId: postId);

    // _clientState! ? emit(UnilkedComment()) : emit(CommentLiked());
    // _clientState = !_clientState!;

    if (_clientState == true && stateFromDatabase == true) {
      emit(UnilkedComment(likeCount: databaseLikeCount - 1));
      _clientState = false;
    } else if (_clientState == false && stateFromDatabase == true) {
      emit(CommentLiked(likeCount: databaseLikeCount));
      _clientState = true;
    } else if (_clientState == true && stateFromDatabase == false) {
      emit(UnilkedComment(likeCount: databaseLikeCount));
      _clientState = false;
    } else if (_clientState == false && stateFromDatabase == false) {
      emit(CommentLiked(likeCount: databaseLikeCount + 1));
      _clientState = true;
    }
  }

  final CommentRepository repository;
}
