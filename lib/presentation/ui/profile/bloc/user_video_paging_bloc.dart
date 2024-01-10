import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:personal_project/config/bloc_status_enum.dart';
import 'package:personal_project/data/repository/user_video_paging_repository.dart';

part 'user_video_paging_event.dart';
part 'user_video_paging_state.dart';

class UserVideoPagingBloc
    extends Bloc<UserVideoPagingEvent, UserVideoPagingState> {
  UserVideoPagingBloc(this.repository)
      : super(const UserVideoPagingState(status: BlocStatus.initial)) {
    on<InitUserVideoPaging>((event, emit) {
      repository.initPagingController(event.uid, from: event.from);
      emit(UserVideoPagingState(
          status: BlocStatus.initialized, controller: repository.controller!));
    });

    on<RemoveItem>((event, emit) {
      if (repository.controller != null) {
        repository.controller!.itemList!.removeAt(event.index);
        emit(
          const UserVideoPagingState(
            status: BlocStatus.deleted,
          ),
        );
      }
    });
  }

  final UserVideoPagingRepository repository;
}
