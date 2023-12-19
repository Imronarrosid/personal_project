import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:personal_project/domain/reporsitory/user_repository.dart';
import 'package:personal_project/utils/check_if_user_name_is_used.dart';

part 'edit_user_name_state.dart';

class EditUserNameCubit extends Cubit<EditUserNameState> {
  EditUserNameCubit(this.userRepository)
      : super(const EditUserNameState(status: EditUserNameStatus.initial));

  Future<void> editUserName(String newUserName) async {
    emit(const EditUserNameState(status: EditUserNameStatus.loading));
    try {
      bool isAvailable = await isUserNameAvailable(newUserName);
      if (isAvailable) {
        await userRepository.editUserName(newUserName);
        emit(
          EditUserNameState(
            status: EditUserNameStatus.success,
            newUserName: newUserName,
          ),
        );
      } else {
        emit(
          EditUserNameState(
            status: EditUserNameStatus.userNameNotAvailable,
            newUserName: newUserName,
          ),
        );
      }
    } catch (e) {
      emit(const EditUserNameState(status: EditUserNameStatus.error));
    }
  }

  Future<void> checkUserNameAvailability(String username) async {
    emit(const EditUserNameState(status: EditUserNameStatus.loading));
    try {
      bool isAvailable = await isUserNameAvailable(username);
      if (isAvailable) {
        emit(
          EditUserNameState(
            status: EditUserNameStatus.availlable,
            newUserName: username,
          ),
        );
      } else {
        emit(
          EditUserNameState(
            status: EditUserNameStatus.userNameNotAvailable,
            newUserName: username,
          ),
        );
      }
    } catch (e) {}
  }

  final UserRepository userRepository;
}
