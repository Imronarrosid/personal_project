import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:personal_project/data/repository/video_from_game_repostitory.dart';
import 'package:personal_project/domain/model/game_fav_modal.dart';
import 'package:personal_project/domain/model/video_model.dart';

part 'video_from_game_event.dart';
part 'video_from_game_state.dart';

class VideoFromGameBloc extends Bloc<VideoFromGameEvent, VideoFromGameState> {
  VideoFromGameBloc(this.repository)
      : super(const VideoFromGameState(status: VideoFromGameStatus.initial)) {
    on<InitVideoFromGame>((event, emit) {
      repository.initPagingController(event.game);
      emit(VideoFromGameState(
          status: VideoFromGameStatus.initialized,
          controller: repository.controller));
    });
  }
  final VideoFromGameRepository repository;

  @override
  Future<void> close() {
    if (repository.controller != null) {
      repository.controller!.dispose();
    }
    return super.close();
  }
}
