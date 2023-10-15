import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoThumbnailItem extends StatelessWidget {
  final String videoPath;

  const VideoThumbnailItem({super.key, required this.videoPath});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Handle click action to play the video here.
        // You can use video_player package to play the video.
        // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => VideoPlayerScreen(videoPath)));
      },
      child: FutureBuilder<Uint8List?>(
        future: VideoThumbnail.thumbnailData(
          video: videoPath,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 100, // Adjust thumbnail width as needed.
          quality: 50, // Adjust quality as needed.
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return Image.memory(snapshot.data!);
          } else {
            return Container(
              width: 100, // Adjust thumbnail width as needed.
              height: 100, // Adjust thumbnail height as needed.
              color: Colors.grey, // Placeholder color.
            );
          }
        },
      ),
    );
  }
}
