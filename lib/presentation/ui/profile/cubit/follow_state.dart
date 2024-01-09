part of 'follow_cubit.dart';

final class FollowState extends Equatable {
  final BlocStatus status;
  const FollowState({required this.status});

  @override
  List<Object> get props => [status];
}
