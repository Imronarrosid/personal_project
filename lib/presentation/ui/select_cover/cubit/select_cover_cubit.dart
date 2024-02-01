import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:personal_project/config/bloc_status_enum.dart';

part 'select_cover_state.dart';

class SelectCoverCubit extends Cubit<SelectCoverState> {
  SelectCoverCubit() : super(const SelectCoverInitial());
  selectCover(String cover) {
    emit(
      SelectCoverState(
        status: BlocStatus.selected,
        coverPath: cover,
      ),
    );
  }
}
