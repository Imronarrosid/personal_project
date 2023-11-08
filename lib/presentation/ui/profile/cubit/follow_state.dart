part of 'follow_cubit.dart';

sealed class FollowState extends Equatable {
  const FollowState();

  @override
  List<Object> get props => [];
}

final class FollowInitial extends FollowState {}

final class Followed extends FollowState {}

final class UnFollowed extends FollowState {}
