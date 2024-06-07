import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'desktop_comments_event.dart';
part 'desktop_comments_state.dart';

class DesktopCommentsBloc
    extends Bloc<DesktopCommentsEvent, DesktopCommentsState> {
  DesktopCommentsBloc()
      : super(const DesktopCommentsInitial(
          DesktopCommentsStatus.initial,
        )) {
    on<OpenDesktopComments>((event, emit) {
      emit(
        DesktopCommentsState(DesktopCommentsStatus.opened,
            postId: event.postId),
      );
    });
    on<CloseDesktopComments>((event, emit) {
      emit(
        const DesktopCommentsState(
          DesktopCommentsStatus.initial,
        ),
      );
    });
  }
}
