part of 'edit_name_cubit.dart';

enum EditNameStatus { initial, editProccess, nameEditSuccess, editError }

class EditNameState extends Equatable {
  final EditNameStatus? status;
  final String? name;
  const EditNameState({this.name, this.status});

  @override
  List<Object> get props => [status!];
}

final class EditNameInitial extends EditNameState {
  const EditNameInitial({super.status});
}
