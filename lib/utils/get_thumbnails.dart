import 'dart:io';

import 'package:get_thumbnail_video/video_thumbnail.dart';

Future<File> getTumbnail(String path) async {
  final thumbnailFile = await VideoThumbnail.thumbnailFile(video: path);
  return File(thumbnailFile.path);
}
