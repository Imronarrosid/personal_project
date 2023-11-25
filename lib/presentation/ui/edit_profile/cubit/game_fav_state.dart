part of 'game_fav_cubit.dart';

enum GameFavSattus { initial, loading, error, succes }

class GameFavState extends Equatable {
  final GameFavSattus sattus;
  final List<GameFav>? gameFav;
  const GameFavState({
    required this.sattus,
    this.gameFav,
  });

  @override
  List<Object?> get props => [sattus, gameFav];
}
