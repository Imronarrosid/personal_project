import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:personal_project/data/repository/coments_paging_repository.dart';
import 'package:personal_project/domain/model/comment_model.dart';
import 'package:personal_project/utils/debug_mode_print.dart';

part 'comments_state.dart';
part 'comments_event.dart';
part 'comments_bloc.freezed.dart';

class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  final ComentsPagingRepository repository;

  CommentsBloc(this.repository)
      : super(const CommentsState(
          status: CommentsStatus.initial,
        )) {
    on<_LoadCommentsEvent>(_loadComments);
    on<_AddCommentEvent>(_addComment);
    on<_UpdateCommentEvent>(_updateComment);
    on<_LikeCommentEvent>(_likeComment);
  }
  void _likeComment(_LikeCommentEvent event, Emitter<CommentsState> emit) async {
    try {
      emit(
        state.copyWith(
          status: event.isLiked ? CommentsStatus.unliked : CommentsStatus.liked,
        ),
      );

      await repository.likeComment(
        commentId: event.commentId,
        postId: event.postId,
      );
    } catch (e) {
      repository.likeCommentReset(
        postId: event.postId,
        commentId: event.commentId,
      );
      emit(
        state.copyWith(
          status: !event.isLiked ? CommentsStatus.unliked : CommentsStatus.liked,
        ),
      );
      debugModePrint(e.toString());
    }
  }

  void _updateComment(_UpdateCommentEvent event, Emitter<CommentsState> emit) {
    repository.updateComment(event.comment);
    emit(
      state.copyWith(status: CommentsStatus.updated),
    );
  }

  void _addComment(_AddCommentEvent event, Emitter<CommentsState> emit) {
    repository.insertComment(event.comment);
    emit(
      state.copyWith(status: CommentsStatus.loaded),
    );
  }

  void _loadComments(_LoadCommentsEvent event, Emitter<CommentsState> emit) async {
    emit(
      state.copyWith(status: CommentsStatus.loading),
    );
    await repository.loadComments(event.postId);
    emit(
      state.copyWith(
        status: CommentsStatus.loaded,
        comments: repository.currentLoadedComments,
      ),
    );
  }
}
