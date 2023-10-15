import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:personal_project/domain/model/preview_model.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:video_player/video_player.dart';

Future<File> pickVideo() async {
  // final status =
  //     await Permission.storage.request();
  // if (status.isGranted && mounted) {
  //   // Permission is granted, you can now access files on the external storage.
  //   // You can use the code provided in the previous answer to list video files.
  //   showFileBottomSheet(context);
  // }
  final ImagePicker picker = ImagePicker();

  final XFile? galleryVideo =
      await picker.pickVideo(source: ImageSource.gallery);

  return File(galleryVideo!.path);
}

// Future toPickVideo(BuildContext context, {required File video}) async {
//   if (await isMoreThan3minutes(video)) {
//     /// show dialog duration more than 3 minutes 
//     /// 
    
//     // if dialog true 
//     // to preview page

//   } else if (!await isMoreThan3minutes(video) && context.mounted) {
//     await context.push(APP_PAGE.videoPreview.toPath,
//         extra: PreviewData(file: video, isFromCamera: false));
//         toPickVideo(context, video: await pickVideo());
//   }
// }

Future<bool> isMoreThan3minutes(File videoFile) async {
  bool isMoreThan3minutes = false;

  late VideoPlayerController _controller;
  _controller = VideoPlayerController.file(videoFile);

  await _controller.initialize();
  // Video duration is available in milliseconds
  int videoDurationMilliseconds = _controller.value.duration.inMilliseconds;

  // Convert video duration to minutes
  double videoDurationMinutes = videoDurationMilliseconds / 60000.0;

  // Check if the video duration is not more than 3 minutes
  if (videoDurationMinutes < 3.0) {
    isMoreThan3minutes = false;
    // GoRouter.of(context).push(APP_PAGE.videoPreview.toPath, extra: videoFile);
    print('Video duration is not more than 3 minutes.');
  } else {
    isMoreThan3minutes = true;
    print('Video duration is more than 3 minutes.');
  }

  return isMoreThan3minutes;
}
