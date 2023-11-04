part of 'profile_cubit.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

final class ProfileInitial extends ProfileState {}

final class ShowMoreBio extends ProfileState {}

final class ShowLessBio extends ProfileState {}

final class ShowMoreGameFav extends ProfileState {}

final class ShowLessGameFav extends ProfileState {}
