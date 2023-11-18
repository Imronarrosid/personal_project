part of 'edit_user_name_cubit.dart';

enum EditUserNameStatus { initial, loading, success, error }

class EditUserNameState extends Equatable {
  final EditUserNameStatus? status;
  final String? newUserName;
  const EditUserNameState({
    this.status,
    this.newUserName,
  });

  @override
  List<Object> get props => [status!];
}

final class EditUserNameInitial extends EditUserNameState {
  const EditUserNameInitial({super.status});
}
