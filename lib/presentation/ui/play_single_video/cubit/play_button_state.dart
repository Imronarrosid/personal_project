part of 'play_button_cubit.dart';

enum PlayStatus { play, pause, initial }

class PlayButtonState extends Equatable {
  final PlayStatus status;
  const PlayButtonState(this.status);

  @override
  List<Object> get props => [status];
}
