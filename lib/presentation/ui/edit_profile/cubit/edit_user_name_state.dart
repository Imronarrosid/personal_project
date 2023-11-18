part of 'edit_user_name_cubit.dart';

enum EditUserNameStatus { initial, loading, success, error }

class EditUserNameState extends Equatable {
  final EditUserNameStatus? status;
  const EditUserNameState({this.status});

  @override
  List<Object> get props => [status!];
}

final class EditUserNameInitial extends EditUserNameState {
  const EditUserNameInitial({super.status});
}
