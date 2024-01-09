import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:personal_project/data/repository/following_n_followers_repository.dart';

part 'following_n_followers_event.dart';
part 'following_n_followers_state.dart';

class FollowingNFollowersBloc
    extends Bloc<FollowingNFollowersEvent, FollowingNFollowersState> {
  FollowingNFollowersBloc(this.repository)
      : super(const FollowingNFollowersState(
            status: FollowingNFollowersStatus.initial)) {
    on<InitFollowingNFollowersPaging>((event, emit) {
      repository.initPagingController(event.uid, tabFor: event.tabFor);
      emit(FollowingNFollowersState(
          status: FollowingNFollowersStatus.initialized,
          controller: repository.controller));
    });
  }

  final FollowingNFollowersRepository repository;
  @override
  Future<void> close() {
    if (repository.controller != null) {
      repository.controller!.dispose();
    }
    return super.close();
  }
}
