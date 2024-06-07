part of 'home_cubit.dart';

final class HomeState extends Equatable {
  final int index;
  final bool isTriggerReset;
  final Object? extra;
  const HomeState(
    this.index, {
    this.extra,
    this.isTriggerReset = false,
  });

  @override
  List<Object?> get props => [
        index,
        isTriggerReset,
        extra,
      ];
}

final class HomeInitial extends HomeState {
  const HomeInitial(super.index);
  @override
  List<Object> get props => [index, super.props];
}
