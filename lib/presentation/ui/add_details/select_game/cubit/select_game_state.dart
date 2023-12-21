part of 'select_game_cubit.dart';

enum SelectGameStatus { initial, selected }

final class SelectGameState extends Equatable {
  final SelectGameStatus status;
  final GameFav? selectedGame;
  const SelectGameState({required this.status, this.selectedGame});

  @override
  List<Object?> get props => [status, selectedGame];
}
