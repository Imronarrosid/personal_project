import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:personal_project/domain/reporsitory/user_repository.dart';
import 'package:personal_project/presentation/ui/edit_profile/edit_page/edit_game_fav_page.dart';

part 'edit_name_state.dart';

class EditNameCubit extends Cubit<EditNameState> {
  EditNameCubit(this.repository)
      : super(const EditNameState(status: EditNameStatus.initial));

  void editName(String newName) async {
    try {
      emit(const EditNameState(status: EditNameStatus.editProccess));
      debugPrint('edit name loading');
      await repository.editName(newName);
      emit(
        EditNameState(status: EditNameStatus.nameEditSuccess, name: newName),
      );
    } catch (e) {
      emit(const EditNameState(status: EditNameStatus.editError));
      debugPrint(e.toString());
    }
  }

  final UserRepository repository;
}
