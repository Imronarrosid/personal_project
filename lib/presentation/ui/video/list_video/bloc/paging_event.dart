part of 'paging_bloc.dart';

enum VideoFrom { forYou, following }

sealed class VideoPagingEvent extends Equatable {
  const VideoPagingEvent();

  @override
  List<Object> get props => [];
}

class InitPagingController extends VideoPagingEvent {
  final VideoFrom from;

  const InitPagingController({required this.from});

  @override
  List<Object> get props => [super.props, from];
}
