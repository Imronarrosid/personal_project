import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  bool _seeBioMore = true;
  bool _seeGameFavMore = true;

  void seeMoreBioHandle() {
    _seeBioMore ? emit(ShowMoreBio()) : emit(ShowLessBio());

    _seeBioMore = !_seeBioMore;
  }

  void seeMoreGameFavHandle() {
    _seeGameFavMore ? emit(ShowMoreGameFav()) : emit(ShowLessGameFav());

    _seeGameFavMore = !_seeGameFavMore;
  }
}
