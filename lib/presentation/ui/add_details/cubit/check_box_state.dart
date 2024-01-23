part of 'check_box_cubit.dart';

final class CheckBoxState extends Equatable {
  final BlocStatus status;
  const CheckBoxState({
    required this.status,
  });

  @override
  List<Object> get props => [
        status,
      ];
}

final class CheckBoxInitial extends CheckBoxState {
  const CheckBoxInitial({
    super.status = BlocStatus.initial,
  });
  @override
  List<Object> get props => [
        super.props,
      ];
}
