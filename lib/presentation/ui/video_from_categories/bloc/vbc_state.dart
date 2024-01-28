part of 'vbc_bloc.dart';

final class VbcState extends Equatable {
  final BlocStatus status;
  const VbcState({
    required this.status,
  });

  @override
  List<Object> get props => [status];
}

final class VbcInitial extends VbcState {
  const VbcInitial({
    super.status = BlocStatus.initial,
  });

  @override
  List<Object> get props => [
        super.props,
      ];
}
