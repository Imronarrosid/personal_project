import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:personal_project/data/repository/coment_repository.dart';
import 'package:personal_project/domain/model/comment_model.dart';
import 'package:personal_project/domain/model/reply_models.dart';
import 'package:personal_project/domain/services/firebase/firebase_service.dart';

part 'comment_event.dart';
part 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  CommentBloc(this.repository) : super(const CommentState(status: CommentStatus.initial)) {
    on<TapCommentForm>((event, emit) {
      emit(const CommentState(status: CommentStatus.open));
    });
    on<InputComments>((_, emit) {
      emit(
        const CommentState(status: CommentStatus.typing),
      );
    });
    on<StartReply>((event, emit) {
      emit(
        CommentState(
          status: CommentStatus.startReply,
          repliedUsername: event.usernameReplied,
          repliedUid: event.uid,
        ),
      );
    });
    on<UnfocusForm>((event, emit) {
      emit(
        const CommentState(
          status: CommentStatus.initial,
        ),
      );
    });
    on<TapReplyForm>((event, emit) {
      emit(const CommentState(status: CommentStatus.openReplyForm));
    });
    on<TypingReply>((_, emit) {
      emit(
        const CommentState(status: CommentStatus.typingReply),
      );
    });

    on<PostCommentEvent>((event, emit) async {
      emit(
        const CommentState(status: CommentStatus.uploading),
      );
      Comment comment =
          await repository.postComment(commentText: event.comment, postId: event.postId);
      emit(
        CommentState(status: CommentStatus.succes, comment: comment),
      );
    });
    on<RefreshComentEvent>((event, emit) {
      emit(
        const CommentState(status: CommentStatus.refresh),
      );
    });

    on<PostReplyEvent>((event, emit) async {
      emit(
        const CommentState(status: CommentStatus.uploading),
      );
      Reply? reply = await repository.addReply(
        repliedUid: event.repliedUid,
        postId: event.postId,
        commentId: event.commentId,
        comment: event.reply,
      );

      emit(
        CommentState(
          status: CommentStatus.replyAdded,
          reply: reply,
        ),
      );
    });
    on<RemoveLocaleCommentEvent>((event, emit) {
      emit(
        const CommentState(
          status: CommentStatus.removeLocaleComment,
        ),
      );
    });
  }
  final CommentRepository repository;
}
