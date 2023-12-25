import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:personal_project/domain/model/game_fav_modal.dart';
import 'package:personal_project/domain/model/user.dart';
import 'package:personal_project/domain/reporsitory/search_repository.dart';

part 'search_game_event.dart';
part 'search_game_state.dart';

class SearchGameBloc extends Bloc<SearchGameEvent, SearchState> {
  StreamSubscription? searchSubscription;
  SearchGameBloc(this.repository)
      : super(const SearchState(results: [], status: SearchStatus.initial)) {
    on<SearchGameEvent>((event, emit) async {
      var searchResult = await repository.onSearchGame(event.query);
      if (searchResult.isEmpty && event.query.isNotEmpty) {
        emit(const SearchState(results: [], status: SearchStatus.noItemFound));
      } else {
        debugPrint('search ${searchResult.length}');

        emit(SearchState(results: searchResult, status: SearchStatus.success));
      }

      if (event.query.isEmpty) {
        emit(const SearchState(status: SearchStatus.initial));
      }

      searchSubscription = repository.searchSubscription;
      if (searchSubscription != null) {
        searchSubscription?.cancel();
      }
    });
  }
  final SearchRepository repository;

  @override
  Future<void> close() {
    searchSubscription?.cancel();
    return super.close();
  }
}