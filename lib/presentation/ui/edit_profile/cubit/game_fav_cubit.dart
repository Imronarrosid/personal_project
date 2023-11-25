import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:personal_project/domain/model/game_fav_modal.dart';
import 'package:personal_project/domain/reporsitory/user_repository.dart';

part 'game_fav_state.dart';

class GameFavCubit extends Cubit<GameFavState> {
  GameFavCubit(this._repository)
      : super(const GameFavState(sattus: GameFavSattus.initial));

  Future<void> editGameFav(
      List<String> selectedGameTitle, List<GameFav> games) async {
    try {
      emit(const GameFavState(sattus: GameFavSattus.loading));
      await _repository.editGameFav(selectedGameTitle);
      emit(GameFavState(sattus: GameFavSattus.succes, gameFav: games));
    } catch (e) {
      emit(const GameFavState(sattus: GameFavSattus.error));
    }
  }

  final UserRepository _repository;
}
