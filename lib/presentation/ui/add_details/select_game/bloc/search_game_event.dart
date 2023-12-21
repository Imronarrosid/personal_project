part of 'search_game_bloc.dart';

class SearchGameEvent extends Equatable {
  final String query;

  const SearchGameEvent(this.query);

  @override
  List<Object?> get props => [query];
}
