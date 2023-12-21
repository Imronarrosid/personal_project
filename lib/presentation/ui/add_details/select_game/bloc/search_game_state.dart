part of 'search_game_bloc.dart';

enum SearchStatus { success, initial, noItemFound }

class SearchState extends Equatable {
  final SearchStatus status;
  final List<GameFav>? results;

  const SearchState({this.results, required this.status});

  @override
  List<Object?> get props => [results, status];
}
