part of 'following_n_followers_bloc.dart';

sealed class FollowingNFollowersEvent extends Equatable {
  const FollowingNFollowersEvent();

  @override
  List<Object> get props => [];
}

class InitFollowingNFollowersPaging extends FollowingNFollowersEvent {
  final String uid;
  final TabFor tabFor;

  const InitFollowingNFollowersPaging({
    required this.uid,
    required this.tabFor,
  });
  @override
  List<Object> get props => [uid];
}
