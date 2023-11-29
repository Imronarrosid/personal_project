import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'play_button_state.dart';

class PlayButtonCubit extends Cubit<PlayButtonState> {
  PlayButtonCubit() : super(const PlayButtonState(PlayStatus.initial));

  void playHandle(bool isPlayed) {
    if (isPlayed) {
      emit(const PlayButtonState(PlayStatus.pause));
    } else {
      Future.delayed(
        Duration(milliseconds: 200),
        () => emit(const PlayButtonState(PlayStatus.play)),
      );
    }
  }
}
