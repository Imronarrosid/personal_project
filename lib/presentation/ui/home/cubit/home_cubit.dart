import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeInitial(0));

  changePage(int index, {Object? data}) {
    emit(
      HomeState(index, extra: data),
    );
  }

  void triggerReset(
    int index,
  ) {
    emit(
      HomeState(index, isTriggerReset: true),
    );
  }
}
