part of 'edit_user_name_cubit.dart';

enum EditUserNameStatus {
  initial,
  loading,
  success,
  availlable,
  userNameNotAvailable,
  error
}

class EditUserNameState extends Equatable {
  final EditUserNameStatus status;
  final String? newUserName;
  const EditUserNameState({
    required this.status,
    this.newUserName,
  });

  @override
  List<Object?> get props => [status, newUserName];
}

final class EditUserNameInitial extends EditUserNameState {
  const EditUserNameInitial({required super.status});
}
