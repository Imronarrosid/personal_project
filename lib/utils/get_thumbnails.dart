import 'dart:io';

import 'package:video_compress/video_compress.dart';

Future<File> getTumbnail(String videpath) async {
  final thumbnailFile = await VideoCompress.getFileThumbnail(videpath,
      quality: 50, // default(100)
      position: -1 // default(-1)
      );
  return thumbnailFile;
}
