part of 'search_room_bloc.dart';

sealed class SearchRoomEvent extends Equatable {
  const SearchRoomEvent();

  @override
  List<Object> get props => [];
}

final class InitSearchRoom extends SearchRoomEvent {
  const InitSearchRoom();
  @override
  List<Object> get props => [
        super.props,
      ];
}

final class SearchRoom extends SearchRoomEvent {
  final String query;
  const SearchRoom(this.query);
  @override
  List<Object> get props => [
        super.props,
        query,
      ];
}
