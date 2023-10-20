import 'package:video_player/video_player.dart';

class VideoPlayerRepository {
  VideoPlayerController? _controller;

  initVideoPlayer(String url) async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(url));

    await _controller!.initialize();

    return _controller;
  }

  VideoPlayerController? get controller => _controller;
}
