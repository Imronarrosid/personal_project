import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:personal_project/domain/model/game_fav_modal.dart';

part 'select_game_state.dart';

class SelectGameCubit extends Cubit<SelectGameState> {
  SelectGameCubit()
      : super(const SelectGameState(status: SelectGameStatus.initial));

  selectGame(GameFav game) {
    emit(SelectGameState(
        status: SelectGameStatus.selected, selectedGame: game));
  }
}
