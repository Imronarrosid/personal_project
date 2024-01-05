part of 'search_room_bloc.dart';

enum SearchRoomStatus { initial, loading, success,noItemFound}

final class SearchRoomState extends Equatable {
  final SearchRoomStatus status;
  final List<User>? results;
  const SearchRoomState({
    required this.status,
    this.results,
  });

  @override
  List<Object?> get props => [status, results];
}
