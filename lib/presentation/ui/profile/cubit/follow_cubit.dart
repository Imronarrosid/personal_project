import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:personal_project/domain/reporsitory/user_repository.dart';

part 'follow_state.dart';

class FollowCubit extends Cubit<FollowState> {
  FollowCubit(this.repository) : super(FollowInitial());

  bool? _clientState;
  void followButtonHandle(
      {required String currentUserUid,
      required String uid,
      required bool stateFromDatabase}) {
    repository.followUser(currentUserUid: currentUserUid, uid: uid);

    _clientState ??= stateFromDatabase;

    if (_clientState == true && stateFromDatabase == true) {
      // emit(UnilkedVideo(likeCount: databaseLikeCount - 1));
      emit(UnFollowed());
      _clientState = false;
    } else if (_clientState == false && stateFromDatabase == true) {
      emit(Followed());
      _clientState = true;
    } else if (_clientState == true && stateFromDatabase == false) {
      emit(UnFollowed());
      _clientState = false;
    } else if (_clientState == false && stateFromDatabase == false) {
      emit(Followed());
      _clientState = true;
    }
  }

  final UserRepository repository;
}
