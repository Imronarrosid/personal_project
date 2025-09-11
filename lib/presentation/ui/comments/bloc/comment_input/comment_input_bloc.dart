import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:personal_project/data/repository/coment_repository.dart';
import 'package:personal_project/domain/model/comment_model.dart';
import 'package:personal_project/domain/model/reply_models.dart';
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';

part 'comment_input_state.dart';
part 'comment_input_event.dart';
part 'comment_input_bloc.freezed.dart';

class CommentInputBloc extends Bloc<CommentInputEvent, CommentInputState> {
  final CommentRepository commentRepository;
  final AuthRepository authRepository;
  CommentInputBloc(this.commentRepository, this.authRepository) : super(CommentInputState()) {
    on<_OpenInput>((event, emit) {
      emit(
        state.copyWith(
          status: CommentInputStatus.typing,
          isReply: event.isReply,
          text: '',
          repliedCommentId: event.repliedCommentId,
          repliedUserId: event.repliedUserId,
          repliedUserName: event.repliedUserName,
          comment: null,
        ),
      );
    });
    on<_SubmitComment>((event, emit) async {
      final comment = Comment(
        comment: event.commentMessage,
        datePublished: Timestamp.now(),
        uid: authRepository.currentUserData.id,
        repliesCount: 0,
        authorUserName: authRepository.currentUserData.userName!,
        avatar: authRepository.currentUserData.photo,
        status: Status.uploading,
      );
      emit(
        state.copyWith(
          status: CommentInputStatus.uploading,
          comment: comment,
        ),
      );
      await commentRepository.postComment(
        commentText: event.commentMessage,
        postId: state.postId!,
      );
      emit(
        state.copyWith(
          status: CommentInputStatus.success,
          comment: comment.copyWith(
            status: Status.uploaded,
          ),
        ),
      );
    });
    on<_SubmitReply>((event, emit) async {
      final reply = Reply(
        repliedUserId: state.repliedUserId!,
        repliedUserName: state.repliedUserName,
        comment: event.commentMessage,
        datePublished: Timestamp.now(),
        uid: authRepository.currentUserData.id,
        repliesCount: 0,
        authorUserName: commentRepository.authRepository.currentUserData.userName!,
        avatar: authRepository.currentUserData.photo,
      );
      emit(
        state.copyWith(
          status: CommentInputStatus.uploading,
          comment: reply,
        ),
      );
      await commentRepository.addReply(
        comment: event.commentMessage,
        postId: state.postId!,
        commentId: state.repliedCommentId!,
        repliedUid: state.repliedUserId!,
      );
      emit(
        state.copyWith(
          status: CommentInputStatus.success,
          comment: reply,
        ),
      );
    });
    on<_TextChanged>((event, emit) {
      emit(
        state.copyWith(
          text: event.text,
          status: CommentInputStatus.typing,
        ),
      );
    });
  }
}
