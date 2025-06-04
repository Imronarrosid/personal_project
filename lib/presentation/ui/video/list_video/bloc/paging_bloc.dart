import 'package:bloc/bloc.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:personal_project/data/repository/paging_repository.dart';
import 'package:personal_project/domain/model/video_model.dart';

part 'paging_event.dart';
part 'paging_state.dart';

class VideoPaginBloc extends Bloc<VideoPagingEvent, VideoPagingState> {
  VideoPaginBloc(this.repository) : super(PagingInitial()) {
    on<InitPagingController>((event, emit) async {
      if (repository.controller == null) {
        repository.initPagingController(event.from);
        emit(PagingControllerState(controller: repository.controller));
      }
      if (repository.videoPlayerControllers.isEmpty) {
        await repository.loadVideos();
        final List<Video> videos = repository.videos;

        final List<CachedVideoPlayerPlusController> controllers = repository.videoPlayerControllers;
        if (videos.isNotEmpty && controllers.isNotEmpty) {
          await initControllerAtIndex(0);
          repository.videoPlayerControllers[0].play();
          emit(
            PagingControllerState(
              controller: repository.controller,
              cachedControllers: controllers,
              videos: videos,
            ),
          );
        }
      }
    });

    on<OnNextPage>((event, emit) async {
      repository.videoPlayerControllers[event.index].play();
      if (event.index + 1 < repository.videoPlayerControllers.length) {
        await initControllerAtIndex(event.index + 1);
      }
    });
  }
  final PagingRepository repository;

  Future<void> initControllerAtIndex(int index) async {
    final CachedVideoPlayerPlusController controller = repository.videoPlayerControllers[index];
    if (!controller.value.isInitialized) {
      await controller.initialize();
      controller.setLooping(true);
    }
  }
}
