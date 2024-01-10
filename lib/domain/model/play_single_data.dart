import 'video_model.dart';

class PlaySingleData {
  final int index;
  final Video videoData;
  final bool? auto;
  final bool? isForLogedUserVideo;

  PlaySingleData({
    required this.index,
    required this.videoData,
    this.auto = false,
    this.isForLogedUserVideo = false,
  });
}
