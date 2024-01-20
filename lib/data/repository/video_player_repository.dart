import 'package:video_cached_player/video_cached_player.dart';

class VideoPlayerRepository {
  CachedVideoPlayerController? _controller;

  initVideoPlayer(String url) async {
    try {
      _controller = CachedVideoPlayerController.network(url);

      await _controller!.initialize();

      return _controller;
    } catch (e) {
      rethrow;
    }
  }

  CachedVideoPlayerController? get controller => _controller;

  set setController(CachedVideoPlayerController? cachedVideoPlayerController) {
    _controller = cachedVideoPlayerController;
  }
}
