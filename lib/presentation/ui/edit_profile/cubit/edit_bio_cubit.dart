import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:personal_project/domain/reporsitory/user_repository.dart';

part 'edit_bio_state.dart';

class EditBioCubit extends Cubit<EditBioState> {
  EditBioCubit(this._repository)
      : super(const EditBioState(status: EditBioStatus.initial));
  Future<void> editBio(String bio) async {
    try {
      emit(const EditBioState(status: EditBioStatus.loading));
      await _repository.editBio(bio);
      emit(EditBioState(status: EditBioStatus.succes, bio: bio));
    } catch (e) {
      emit(const EditBioState(status: EditBioStatus.error));
    }
  }

  final UserRepository _repository;
}
