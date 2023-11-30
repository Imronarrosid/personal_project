import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'captions_state.dart';

class CaptionsCubit extends Cubit<CaptionsState> {
  CaptionsCubit() : super(const CaptionsState(Captions.seeLess));

  void captionsHandle() {
    if (state.status == Captions.seeLess) {
      emit(const CaptionsState(Captions.seeMore));
    } else {
      emit(const CaptionsState(Captions.seeLess));
    }
  }
}
