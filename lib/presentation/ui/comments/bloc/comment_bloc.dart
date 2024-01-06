import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:personal_project/data/repository/coment_repository.dart';
import 'package:personal_project/domain/model/comment_model.dart';

part 'comment_event.dart';
part 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  CommentBloc(this.repository)
      : super(const CommentState(status: CommentStatus.initial)) {
    on<TapCommentForm>((event, emit) {
      emit(const CommentState(status: CommentStatus.open));
    });
    on<InputComments>((_, emit) {
      emit(
        const CommentState(status: CommentStatus.typing),
      );
    });

    on<PostCommentEvent>((event, emit) async {
      emit(
        const CommentState(status: CommentStatus.uploading),
      );
      Comment comment = await repository.postComment(
          commentText: event.comment, postId: event.postId);
      emit(
        CommentState(status: CommentStatus.succes, comment: comment),
      );
    });
    on<RefreshComentEvent>((event, emit) {
      emit(
        const CommentState(status: CommentStatus.refresh),
      );
    });
  }
  final CommentRepository repository;
}
