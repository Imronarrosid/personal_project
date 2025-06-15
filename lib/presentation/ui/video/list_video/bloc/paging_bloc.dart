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
      // final List<Video> videos = repository.videos;

      // final List<CachedVideoPlayerPlusController> controllers = repository.videoPlayerControllers;

      // if (videos.isNotEmpty && controllers.isNotEmpty) {
      //   emit(
      //     PagingControllerState(
      //       controller: repository.controller,
      //       cachedControllers: controllers,
      //       videos: videos,
      //     ),
      //   );
      // }
    });

    on<LoadMoreVideo>(
      (event, emit) async {
        emit(PagingLoadingSate());
        List<Video> newVideos = await repository.loadVideos();
        final List<Video> videos = repository.videos;

        final List<CachedVideoPlayerPlusController> controllers = repository.videoPlayerControllers;

        if (videos.isNotEmpty && controllers.isNotEmpty) {
          emit(
            PagingControllerState(
              controller: repository.controller,
              cachedControllers: controllers,
              videos: videos,
            ),
          );
        }
        if (newVideos.isEmpty) {
          emit(const NoMoreItem());
        }
      },
    );

    on<OnNextPage>((event, emit) async {
      // repository.videoPlayerControllers[event.index].play();
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
