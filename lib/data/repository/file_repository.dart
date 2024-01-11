import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:personal_project/utils/get_thumbnails.dart';

class FileRepository {
  XFile? exportedVideo;
  final StreamController<int> _fileController =
      StreamController<int>.broadcast();

  Stream<int> get fileSizeStream => _fileController.stream.asBroadcastStream();

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

  String fileMBSize(int bytes) {
    return (bytes / (1024 * 1024)).toStringAsFixed(1);
  }

  Future<int> getCacheSize() async {
    try {
      final Directory appDataDir = await getTemporaryDirectory();
      int appDataSize = 0;

      await for (FileSystemEntity entity in appDataDir.list(recursive: true)) {
        if (entity is File) {
          appDataSize += await entity.length();
          _fileController.add(await entity.length());
        }
      }

      return appDataSize;
    } catch (e) {
      debugPrint('Error getting app data size: $e');
      return 0;
    }
  }

  Future<void> calculateCacheSize() async {
    try {
      final Directory appDataDir = await getTemporaryDirectory();
      int appDataSize = 0;

      await for (FileSystemEntity entity in appDataDir.list(recursive: true)) {
        if (entity is File) {
          appDataSize += await entity.length();
          _fileController.add(appDataSize);
        }
      }
      _fileController.close();
    } catch (e) {
      debugPrint('Error getting app data size: $e');
    }
  }

  Future<void> clearCacheDir() async {
    final cacheDir = await getTemporaryDirectory();

    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
      _fileController.add(0);
    }
    _fileController.close();
  }
}
