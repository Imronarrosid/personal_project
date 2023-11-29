import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:personal_project/data/repository/coment_repository.dart';
import 'package:personal_project/domain/model/comment_model.dart';

part 'comment_event.dart';
part 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  CommentBloc(this.repository) : super(CommentInitial()) {
    on<AddComentEvent>((event, emit) {
      emit(AddComentState());
    });
    on<PostCommentEvent>((event, emit) async {
      Comment comment = await repository.postComment(
          commentText: event.comment, postId: event.postId);
      emit(ComentAddedState(comment: comment));
    });
    on<RefreshComentEvent>((event, emit) {
      emit(RefreshComentState());
    });
  }
  final CommentRepository repository;
}
