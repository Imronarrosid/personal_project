import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:personal_project/domain/model/files_model.dart';
import 'package:personal_project/utils/get_thumbnails.dart';

class FileRepository {
  XFile? exportedVideo;

  Future<List<String>> getAppCaches() async {
    List<String> paths = [];
    Directory dir = await getApplicationCacheDirectory();

    for (var element in dir.listSync(recursive: true)) {
      debugPrint(element.path);
      if (element.path.endsWith('.mp4')) {
        paths.add(element.path);
      }
    }
    return paths;
  }

  Future<File> getVideoThumnails(String path) async {
    File file = await getTumbnail(path);
    return file;
  }
}
