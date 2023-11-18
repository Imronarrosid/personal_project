part of 'refresh_profile_cubit.dart';

enum RefreshStatus { initial, refresh }

class RefreshProfileState extends Equatable {
  final RefreshStatus status;
  const RefreshProfileState(this.status);

  @override
  List<Object> get props => [status];
}
