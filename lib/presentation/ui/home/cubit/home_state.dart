part of 'home_cubit.dart';

sealed class HomeState extends Equatable {
  final int index;
  const HomeState(this.index);

  @override
  List<Object> get props => [index];
}

final class HomeInitial extends HomeState {
  const HomeInitial(super.index);
  @override
  List<Object> get props => [index];
}


