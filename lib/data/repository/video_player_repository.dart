import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/foundation.dart';

class VideoPlayerRepository {
  CachedVideoPlayerPlusController? _controller;

  Future<CachedVideoPlayerPlusController?> initVideoPlayer(String url) async {
    try {
      if (kIsWeb) {
        _controller = CachedVideoPlayerPlusController.networkUrl(
              Uri.parse(url),
              httpHeaders: {
                'Cache-Control': 'max-age=3600',
              },
              invalidateCacheIfOlderThan: const Duration(
                minutes: 5,
              ),
            );
      } else {
        _controller = CachedVideoPlayerPlusController.networkUrl(
              Uri.parse(url),
              invalidateCacheIfOlderThan: const Duration(
                minutes: 5,
              ),
            );
      }
      await _controller!.initialize();

      debugPrint('ctrlll is ' + _controller!.value.isInitialized.toString());
      return _controller;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  CachedVideoPlayerPlusController? get controller => _controller;

  set setController(
      CachedVideoPlayerPlusController? cachedVideoPlayerController) {
    _controller = cachedVideoPlayerController;
  }
}
