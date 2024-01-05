import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:personal_project/data/repository/chat_repository.dart';
import 'package:personal_project/domain/model/user.dart';

part 'search_room_event.dart';
part 'search_room_state.dart';

class SearchRoomBloc extends Bloc<SearchRoomEvent, SearchRoomState> {
  SearchRoomBloc(this.repository)
      : super(const SearchRoomState(status: SearchRoomStatus.loading)) {
    on<InitSearchRoom>((event, emit) async {
      emit(const SearchRoomState(status: SearchRoomStatus.loading));
      await repository.initSearchFollowingSearch();
      emit(const SearchRoomState(status: SearchRoomStatus.initial));
    });
    on<SearchRoom>((event, emit) async {
      emit(const SearchRoomState(status: SearchRoomStatus.loading));
      try {
        List<User> results =
            await repository.searchUserFromFollowing(event.query);

        if (results.isNotEmpty) {
          emit(
            SearchRoomState(status: SearchRoomStatus.success, results: results),
          );
        } else {
          emit(const SearchRoomState(status: SearchRoomStatus.noItemFound));
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    });
  }

  final ChatRepository repository;
}
