part of 'following_n_followers_bloc.dart';

enum FollowingNFollowersStatus { initial, initialized }

final class FollowingNFollowersState extends Equatable {
  final FollowingNFollowersStatus status;
  final PagingController<int, String>? controller;
  const FollowingNFollowersState({required this.status, this.controller});

  @override
  List<Object?> get props => [status, controller];
}
