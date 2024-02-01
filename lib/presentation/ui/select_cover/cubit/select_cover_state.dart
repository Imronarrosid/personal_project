part of 'select_cover_cubit.dart';

final class SelectCoverState extends Equatable {
  final BlocStatus status;
  final String? coverPath;
  const SelectCoverState({
    required this.status,
    this.coverPath,
  });

  @override
  List<Object?> get props => [
        status,
        coverPath,
      ];
}

final class SelectCoverInitial extends SelectCoverState {
  const SelectCoverInitial({
    super.status = BlocStatus.initial,
    super.coverPath,
  });

  @override
  List<Object> get props => [super.props];
}
