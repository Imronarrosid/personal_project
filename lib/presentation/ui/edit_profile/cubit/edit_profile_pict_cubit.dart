import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:personal_project/domain/reporsitory/user_repository.dart';

part 'edit_profile_pict_state.dart';

class EditProfilePictCubit extends Cubit<EditProfilePictState> {
  EditProfilePictCubit(this._repository)
      : super(const EditProfilePictState(status: EditProfilePicStatus.initial));

  Future<void> editProfilePict(File imageFile) async {
    try {
      emit(const EditProfilePictState(status: EditProfilePicStatus.loading));
      await _repository.editProfilePict(imageFile);
      emit(EditProfilePictState(
          status: EditProfilePicStatus.success, imageFile: imageFile));
    } catch (e) {
      emit(const EditProfilePictState(status: EditProfilePicStatus.error));
    }
  }

  final UserRepository _repository;
}
