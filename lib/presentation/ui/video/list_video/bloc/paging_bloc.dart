import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:personal_project/data/repository/paging_repository.dart';
import 'package:personal_project/domain/model/video_model.dart';

part 'paging_event.dart';
part 'paging_state.dart';

class VideoPaginBloc extends Bloc<VideoPagingEvent, VideoPagingState> {
  VideoPaginBloc(this.repository) : super(PagingInitial()) {
    on<InitPagingController>((event, emit) async {
      if (repository.controller == null) {
        repository.initPagingController();
        emit(PagingControllerState(controller: repository.controller));
      }
    });
  }
  final PagingRepository repository;
}
