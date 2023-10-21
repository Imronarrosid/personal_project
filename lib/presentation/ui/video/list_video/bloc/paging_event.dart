part of 'paging_bloc.dart';

sealed class VideoPagingEvent extends Equatable {
  const VideoPagingEvent();

  @override
  List<Object> get props => [];
}

class InitPagingController extends VideoPagingEvent{}

