import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:video_player/video_player.dart';

Future<void> pickVideo(BuildContext context) async {
  // final status =
  //     await Permission.storage.request();
  // if (status.isGranted && mounted) {
  //   // Permission is granted, you can now access files on the external storage.
  //   // You can use the code provided in the previous answer to list video files.
  //   showFileBottomSheet(context);
  // }
  final ImagePicker picker = ImagePicker();
  // Show loading indicator
  Timer(const Duration(milliseconds: 1000), () {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const Center(
          child:
              CircularProgressIndicator(), // You can use a custom loading widget
        );
      },
      barrierDismissible: false, // Prevent users from dismissing the dialog
    );
  });
  final XFile? galleryVideo =
      await picker.pickVideo(source: ImageSource.gallery);
  if (context.mounted && galleryVideo != null) {
    context.pop(); // Pop loading indicator
    context.push(APP_PAGE.videoEditor.toPath, extra: galleryVideo);
  } else if (context.mounted && galleryVideo == null) {
    context.pop(); // pop loading indicator
  }
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

  late VideoPlayerController controller;
  controller = VideoPlayerController.file(videoFile);

  await controller.initialize();
  // Video duration is available in milliseconds
  int videoDurationMilliseconds = controller.value.duration.inMilliseconds;

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
