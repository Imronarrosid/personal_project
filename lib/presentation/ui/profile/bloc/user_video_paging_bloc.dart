import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:personal_project/data/repository/user_video_paging_repository.dart';

part 'user_video_paging_event.dart';
part 'user_video_paging_state.dart';

class UserVideoPagingBloc
    extends Bloc<UserVideoPagingEvent, UserVideoPagingState> {
  UserVideoPagingBloc(this.repository) : super(UserVideoPagingInitial()) {
    on<InitUserVideoPaging>((event, emit) {
      repository.initPagingController(event.uid,from: event.from);
      emit(UserVideoPagingInitialed(controller: repository.controller!));
    });
  }
  final UserVideoPagingRepository repository;
}
