part of 'user_video_paging_bloc.dart';

sealed class UserVideoPagingEvent extends Equatable {
  const UserVideoPagingEvent();

  @override
  List<Object> get props => [];
}

class InitUserVideoPaging extends UserVideoPagingEvent {
  final String uid;
  final From from;

  const InitUserVideoPaging({
    required this.uid,
    required this.from,
  });

  @override
  List<Object> get props => [uid, from];
}

class RemoveItem extends UserVideoPagingEvent {
  final int index;

  const RemoveItem({required this.index});

  @override
  List<Object> get props => [super.props, index];
}
