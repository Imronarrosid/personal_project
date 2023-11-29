part of 'search_bloc.dart';

enum SearchStatus { success, initial, noItemFound }

class SearchState extends Equatable {
  final SearchStatus status;
  final List<User>? results;

  const SearchState({this.results, required this.status});

  @override
  List<Object?> get props => [results, status];
}
