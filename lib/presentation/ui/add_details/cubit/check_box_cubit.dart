import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:personal_project/config/bloc_status_enum.dart';

part 'check_box_state.dart';

class CheckBoxCubit extends Cubit<CheckBoxState> {
  CheckBoxCubit() : super(const CheckBoxInitial());

  checkBoxHandle() {
    state.status == BlocStatus.initial
        ? emit(const CheckBoxState(status: BlocStatus.active))
        : emit(const CheckBoxState(status: BlocStatus.initial));
  }
}
