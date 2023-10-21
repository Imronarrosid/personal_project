part of 'paging_bloc.dart';

sealed class VideoPagingState extends Equatable {
  const VideoPagingState();

  @override
  List<Object> get props => [];
}

final class PagingInitial extends VideoPagingState {}

class PagingControllerState extends VideoPagingState {
  final PagingController<int, Video>? controller;

  const PagingControllerState({required this.controller});

  @override
  List<Object> get props => [controller!];
}

