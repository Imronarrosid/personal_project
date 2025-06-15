part of 'paging_bloc.dart';

sealed class VideoPagingState extends Equatable {
  const VideoPagingState();

  @override
  List<Object?> get props => [];
}

final class PagingInitial extends VideoPagingState {}

class PagingControllerState extends VideoPagingState {
  final PagingController<int, Video>? controller;
  final List<CachedVideoPlayerPlusController>? cachedControllers;
  final List<Video>? videos;

  const PagingControllerState({
    this.videos,
    this.controller,
    this.cachedControllers,
  });

  @override
  List<Object?> get props => [
        controller,
        cachedControllers,
        videos,
      ];
}

class PagingLoadingSate extends VideoPagingState {
  const PagingLoadingSate();

  @override
  List<Object?> get props => [
        super.props,
      ];
}
class NoMoreItem extends VideoPagingState {
  const NoMoreItem();

  @override
  List<Object?> get props => [
        super.props,
      ];
}
