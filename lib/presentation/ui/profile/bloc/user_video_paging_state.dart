part of 'user_video_paging_bloc.dart';

sealed class UserVideoPagingState extends Equatable {
  const UserVideoPagingState();

  @override
  List<Object> get props => [];
}

final class UserVideoPagingInitial extends UserVideoPagingState {}

final class UserVideoPagingInitialed extends UserVideoPagingState {
  final PagingController<int, String> controller;

  const UserVideoPagingInitialed({required this.controller});

  @override
  List<Object> get props => [controller];
}
