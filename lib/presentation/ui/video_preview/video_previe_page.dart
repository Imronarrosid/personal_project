import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_project/presentation/ui/video_preview/bloc/video_preview_bloc.dart';
import 'package:video_player/video_player.dart';

class VideoPreviewPage extends StatefulWidget {
  final File videoFile;
  const VideoPreviewPage({super.key, required this.videoFile});

  @override
  State<VideoPreviewPage> createState() => _VideoPreviewPageState();
}

class _VideoPreviewPageState extends State<VideoPreviewPage> {
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    _videoPlayerController = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((value) {
        BlocProvider.of<VideoPreviewBloc>(context)
            .add(InitVideoPlayer(controller: _videoPlayerController));
      });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        _videoPlayerController.dispose();
        BlocProvider.of<VideoPreviewBloc>(context).add(StopVideoPriviewEvent());
        return true;
      },
      child: Container(
        width: size.width,
        height: size.height,
        alignment: Alignment.center,
        child: BlocBuilder<VideoPreviewBloc, VideoPreviewState>(
          builder: (context, state) {
            if (state is VideoPlayerIntialized) {
              debugPrint(state.toString());

              return FittedBox(
                fit: BoxFit
                    .contain, // You can adjust this to control the fit mode
                child: SizedBox(
                  width: _videoPlayerController.value.size.width,
                  height: _videoPlayerController.value.size.height,
                  child: VideoPlayer(_videoPlayerController),
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }
}
