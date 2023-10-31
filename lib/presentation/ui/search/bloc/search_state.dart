part of 'search_bloc.dart';

class SearchState extends Equatable {
  final List<User> results;

  const SearchState(this.results);

  @override
  List<Object?> get props => [results];
}
