import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:personal_project/data/repository/coment_repository.dart';

part 'comment_event.dart';
part 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  CommentBloc(this.repository) : super(CommentInitial()) {
    on<AddComentEvent>((event, emit) {
      emit(AddComentState());
    });
    on<PostCommentEvent>((event, emit) {
      repository.postComment( commentText: event.comment, postId: event.postId);
    });
  }
  final CommentRepository repository;
}
