import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'refresh_profile_state.dart';

class RefreshProfileCubit extends Cubit<RefreshProfileState> {
  RefreshProfileCubit()
      : super(const RefreshProfileState(RefreshStatus.initial));
  refreshProfile() {
    emit(const RefreshProfileState(RefreshStatus.refresh));
    emit(const RefreshProfileState(RefreshStatus.initial));
  }
}
