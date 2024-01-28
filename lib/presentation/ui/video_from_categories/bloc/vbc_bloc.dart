import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:personal_project/config/bloc_status_enum.dart';
import 'package:personal_project/data/repository/vide_from_categories.dart';
import 'package:personal_project/domain/model/category_model.dart';

part 'vbc_event.dart';
part 'vbc_state.dart';

class VbcBloc extends Bloc<VbcEvent, VbcState> {
  VbcBloc(this.repository) : super(const VbcInitial()) {
    on<InitVbcEvent>((event, emit) {
      emit(
        const VbcState(
          status: BlocStatus.loading,
        ),
      );
      repository.initPagingController(event.category);
      emit(const VbcState(status: BlocStatus.initialized));
    });
  }
  final VBCREpository repository;
}
