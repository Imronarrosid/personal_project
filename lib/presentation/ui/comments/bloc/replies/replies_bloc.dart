import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:personal_project/data/repository/replies_repository.dart';
import 'package:personal_project/domain/model/comment_model.dart';
import 'package:personal_project/domain/model/reply_models.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/utils/debug_mode_print.dart';

part 'replies_state.dart';
part 'replies_event.dart';
part 'replies_bloc.freezed.dart';

class RepliesBloc extends Bloc<RepliesEvent, RepliesState> {
  final RepliesRepository replyRepository;
  RepliesBloc(this.replyRepository) : super(const RepliesState()) {
    on<_LoadRepliesEvent>(_loadRepliesEvent);
    on<_AddReplyEvent>(_addReply);
    on<_HideRepliesEvent>(_hideReply);
    on<_LikeReplyEvent>(_likeReply);
  }

  Future<void> _likeReply(_LikeReplyEvent event, emit) async {
    try {
      emit(
        state.copyWith(
          status: event.isLiked ? RepliesStatus.unliked : RepliesStatus.liked,
        ),
      );

      await replyRepository.likeReply(
        commentId: event.commentId,
        postId: event.postId,
        replyId: event.replyId,
      );
    } catch (e) {
      replyRepository.likeReplyReset(
        postId: event.postId,
        replyId: event.replyId,
      );
      emit(
        state.copyWith(
          status: RepliesStatus.error,
          errorMessage: LocaleKeys.message_failed_to_like.tr(),
        ),
      );
      debugModePrint('like reply error ${e.toString()}');
    }
  }

  FutureOr<void> _hideReply(event, emit) {
    emit(
      state.copyWith(
        status: RepliesStatus.hidden,
      ),
    );
  }

  FutureOr<void> _addReply(event, emit) {
    replyRepository.addReply(
      reply: event.reply,
    );
    emit(
      state.copyWith(
        status: RepliesStatus.added,
        replies: replyRepository.replies,
      ),
    );
  }

  Future<void> _loadRepliesEvent(event, emit) async {
    emit(
      state.copyWith(
        status: RepliesStatus.loading,
      ),
    );
    await replyRepository.loadReplies(
      postId: event.postId,
      commentId: event.commentId,
    );
    emit(
      state.copyWith(
        status: RepliesStatus.loaded,
        isLastReply: replyRepository.isLastReply,
        replies: replyRepository.replies,
      ),
    );
  }
}
