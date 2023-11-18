import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:personal_project/domain/reporsitory/user_repository.dart';

part 'edit_user_name_state.dart';

class EditUserNameCubit extends Cubit<EditUserNameState> {
  EditUserNameCubit(this.userRepository)
      : super(const EditUserNameState(status: EditUserNameStatus.initial));

  void editUserName(String newUserName) async {
    emit(const EditUserNameState(status: EditUserNameStatus.loading));
    try {
      await userRepository.editUserName(newUserName);
      emit(EditUserNameState(
          status: EditUserNameStatus.success, newUserName: newUserName));
    } catch (e) {
      emit(const EditUserNameState(status: EditUserNameStatus.error));
    }
  }

  final UserRepository userRepository;
}
