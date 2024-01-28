import 'package:flutter/foundation.dart';
import 'package:video_cached_player/video_cached_player.dart';

class VideoPlayerRepository {
  CachedVideoPlayerController? _controller;

  Future<CachedVideoPlayerController?> initVideoPlayer(String url) async {
    try {
      _controller = CachedVideoPlayerController.network(url);
      await _controller!.initialize();

      debugPrint('ctrlll is ' + _controller!.value.isInitialized.toString());
      return _controller;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  CachedVideoPlayerController? get controller => _controller;

  set setController(CachedVideoPlayerController? cachedVideoPlayerController) {
    _controller = cachedVideoPlayerController;
  }
}
