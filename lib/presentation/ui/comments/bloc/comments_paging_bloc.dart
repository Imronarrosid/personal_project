import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:personal_project/data/repository/coments_paging_repository.dart';
import 'package:personal_project/domain/model/comment_model.dart';

part 'comments_paging_event.dart';
part 'comments_paging_state.dart';

class CommentsPagingBloc
    extends Bloc<CommentsPagingEvent, CommentsPagingState> {
  CommentsPagingBloc(this.repository) : super(CommentsPagingInitial()) {
    on<InitCommentsPagingEvent>((event, emit) {
      if (repository.controller == null) {
        repository.initPagingController(event.postId);

        emit(CommentsPagingInitialized(controller: repository.controller));
      }
    });
  }
  @override
  Future<void> close() {
    if (repository.controller != null) {
      repository.controller!.dispose();
    }
    return super.close();
  }

  final ComentsPagingRepository repository;
}
