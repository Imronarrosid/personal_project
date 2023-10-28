part of 'user_video_paging_bloc.dart';

sealed class UserVideoPagingEvent extends Equatable {
  const UserVideoPagingEvent();

  @override
  List<Object> get props => [];
}

class InitUserVideoPaging extends UserVideoPagingEvent {
  final String uid;

  const InitUserVideoPaging({required this.uid});

  @override
  List<Object> get props => [uid];
}
