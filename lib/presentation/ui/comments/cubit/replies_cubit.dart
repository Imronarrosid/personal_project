import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:personal_project/data/repository/replies_repository.dart';
import 'package:personal_project/domain/model/comment_model.dart';
import 'package:personal_project/domain/model/reply_models.dart';

part 'replies_state.dart';

class RepliesCubit extends Cubit<RepliesState> {
  RepliesCubit(this.repository) : super(const RepliesInitial());
  Future<void> addReplies({
    required String postId,
    required String repliedUid,
    required String reply,
    required String commentId,
  }) async {
    try {
      emit(
        const RepliesState(
          status: RepliesStatus.uploading,
        ),
      );
      await repository.addReply(
        repliedUid: repliedUid,
        postId: postId,
        commentId: commentId,
        comment: reply,
      );
      emit(
        const RepliesState(
          status: RepliesStatus.replyadded,
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void clearLocalRelies() {
    repository.clearLocalReplies();
    emit(
      const RepliesState(
        status: RepliesStatus.removeLocaleRelies,
      ),
    );
  }

  void loadReplies({
    required String postId,
    required String commentId,
  }) async {
    emit(const RepliesState(
      status: RepliesStatus.loading,
    ));

    await repository.getListRepliesDocs(postId: postId, limit: 3, commentId: commentId);

    if (repository.replies.isNotEmpty) {
      emit(RepliesState(
        status: RepliesStatus.loadReplies,
        replies: repository.replies,
        isLastReply: repository.isLastReply,
      ));
    } else {
      emit(
        const RepliesState(
          status: RepliesStatus.initial,
        ),
      );
    }
  }

  void hideReplies() {
    emit(
      const RepliesState(
        status: RepliesStatus.initial,
      ),
    );
  }

  final RepliesRepository repository;
}
