part of 'home_cubit.dart';

final class HomeState extends Equatable {
  final int index;
  final bool isTriggerReset;
  const HomeState(
    this.index, {
    this.isTriggerReset = false,
  });

  @override
  List<Object> get props => [
        index,
        isTriggerReset,
      ];
}

final class HomeInitial extends HomeState {
  const HomeInitial(super.index);
  @override
  List<Object> get props => [index, super.props];
}
