import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/font_size.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
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
    _videoPlayerController.setLooping(true);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        if (!await _showDialog(context, widget.videoFile)) {
          return false;
        }
        _videoPlayerController.dispose();

        return true;
      },
      child: Scaffold(
        backgroundColor: COLOR_black,
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        persistentFooterButtons: [
          SizedBox.expand(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: ElevatedButton(
                  onPressed: () async {
                    _videoPlayerController.pause();
                    await context.push(APP_PAGE.addDetails.toPath,
                        extra: widget.videoFile);

                    _videoPlayerController.play();
                  },
                  child: Text(
                    LocaleKeys.label_next.tr(),
                    style: TextStyle(
                        color: COLOR_white_fff5f5f5,
                        fontSize: FontSize.FONT_SIZE_16,
                        fontWeight: FontWeight.w500),
                  )),
            ),
          ),
        ],
        body: Container(
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
      ),
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }
}

Future<bool> _showDialog(BuildContext context, File file) async {
  Future<bool> isPop = Future.value(false);
  showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(LocaleKeys.message_delete_video).tr(),
          actions: [
            TextButton(
                onPressed: () async {
                  isPop = Future.value(false);
                  context.pop();
                },
                child: Text(LocaleKeys.label_cancel.tr())),
            TextButton(
                onPressed: () {
                  isPop = Future.value(true);
                  context.pop();
                  context.pop();
                  File(file.path).delete();
                  BlocProvider.of<VideoPreviewBloc>(context)
                      .add(StopVideoPriviewEvent());
                },
                child: Text(LocaleKeys.label_delete.tr()))
          ],
        );
      });

  return isPop;
}
