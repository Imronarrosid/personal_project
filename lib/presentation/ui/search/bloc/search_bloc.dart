import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:personal_project/domain/model/user.dart';
import 'package:personal_project/domain/reporsitory/search_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  StreamSubscription? searchSubscription;
  SearchBloc(this.repository) : super(const SearchState([])) {
    on<SearchEvent>((event, emit) async {
      if (event.query.isEmpty) {
        emit(const SearchState([]));
      } else {
        var searchResult = await repository.onSearchChanged(event.query);
        debugPrint('search ${searchResult.length}');

        emit(SearchState(searchResult));
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
