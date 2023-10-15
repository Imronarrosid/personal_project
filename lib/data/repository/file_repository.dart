import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:personal_project/domain/model/files_model.dart';
import 'package:personal_project/utils/get_thumbnails.dart';

class FileRepository {
  final _paginationController = PaginationController();
  List<Files> filesWithThumbnails = [];
  List<String> videoPaths = [];

  Future<List<Files>> _getPaginatedFilesWithThumbnails(
      int pageNumber, int pageSize) async {
    List<Files> filesWithThumbnails = [];

    try {
      final appDir = await getExternalStorageDirectory();
      debugPrint('appdir: $appDir');
      if (appDir != null) {
        final root = appDir.path;
        List<FileSystemEntity> filess = appDir.listSync().where((entity) {
          debugPrint('pathh' + entity.path);
          return entity.path.endsWith('.mp4');
        }).toList();

        final files = Directory(root).listSync();
        debugPrint('Files: $files');
        debugPrint('Files: ${filess.length}');
        debugPrint('Files: $root');

        final startIndex = (pageNumber - 1) * pageSize;
        final endIndex = startIndex + pageSize;

        for (var i = startIndex; i < endIndex && i < files.length; i++) {
          final file = files[i];
          if (file is File) {
            final fileExtension = file.path.split('.').last.toLowerCase();

            if (fileExtension == 'mp4' ||
                fileExtension == 'mov' ||
                fileExtension == 'avi') {
              final thumbnail = await getTumbnail(file.path);

              filesWithThumbnails.add(Files(
                path: file.path,
                thumbnail: thumbnail.path,
              ));
            }
            // Handle other file types if needed.
          }
        }
      }
    } catch (e) {
      print('Error: $e');
    }

    return filesWithThumbnails;
  }

  Future<void> loadVideos() async {
    // Use the file_picker package to select video files from the device's storage.
    FilePickerResult? files = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: true,
    );

    if (files != null) {
      for (var file in files.files) {
        videoPaths.add(file.path!);
      }
    }
  }

  /////////////////////////////

  Future<List<File>> listAllVideoFiles() async {
    final List<File> videoFiles = [];

    final directories = await _getStorageDirectories();
    debugPrint('Directories $directories');
    for (final directory in directories) {
      await _listVideoFiles(directory, videoFiles);
    }

    return videoFiles;
  }

  Future<List<Directory>> _getStorageDirectories() async {
    final List<Directory> directories = [];
    final externalDir = await getExternalStorageDirectories();

    if (externalDir != null) {
      directories.addAll(externalDir);
    }

    // You can add more directory sources here if needed

    return directories;
  }

  Future<void> _listVideoFiles(
      Directory directory, List<File> videoFiles) async {
    final files = directory.listSync();
    debugPrint('directory$directory');
    for (var file in files) {
      if (file is File && _isVideoFile(file.path)) {
        videoFiles.add(file);
      } else if (file is Directory) {
        await _listVideoFiles(file, videoFiles);
      }
    }
  }

  bool _isVideoFile(String path) {
    final videoExtensions = [
      '.mp4',
      '.avi',
      '.mkv',
      '.mov',
      '.wmv',
      '.flv'
    ]; // Add more extensions if needed
    final lowerCasePath = path.toLowerCase();
    return videoExtensions.any((ext) => lowerCasePath.endsWith(ext));
  }
}

class PaginationController {
  int _pageNumber = 1;
  int _pageSize = 10;
  bool _hasMoreData = true;

  int get pageNumber => _pageNumber;
  int get pageSize => _pageSize;
  bool get hasMoreData => _hasMoreData;

  void loadMore() {
    _pageNumber++;
  }

  void reset() {
    _pageNumber = 1;
    _hasMoreData = true;
  }
}
