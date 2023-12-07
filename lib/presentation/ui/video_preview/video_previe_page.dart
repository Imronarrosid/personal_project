import 'dart:io';
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/presentation/assets/images.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/ui/video_preview/bloc/video_preview_bloc.dart';
import 'package:video_player/video_player.dart';

class VideoPreviewPage extends StatefulWidget {
  final File previewData;
  const VideoPreviewPage({super.key, required this.previewData});

  @override
  State<VideoPreviewPage> createState() => _VideoPreviewPageState();
}

class _VideoPreviewPageState extends State<VideoPreviewPage> {
  late VideoPlayerController _videoPlayerController;
  // ignore: non_constant_identifier_names
  final double _IC_LABEL_FONTSIZE = 12;
  String? _fileMbSize;

  @override
  void initState() {
    _videoPlayerController = VideoPlayerController.file(widget.previewData)
      ..initialize().then((_) {
        if (_videoPlayerController.value.isInitialized) {
          setState(() {});
          _videoPlayerController.setLooping(true);
          _videoPlayerController.play();
        }
      });

    widget.previewData.readAsBytes().then((bytes) {
      _fileMbSize = _fileMBSize(bytes);
      setState(() {});
    });

    super.initState();
  }

  String _fileMBSize(Uint8List bytes) {
    return '${(bytes.lengthInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLOR_black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: _videoPlayerController.value.size.width,
                height: _videoPlayerController.value.size.height,
                child: VideoPlayer(_videoPlayerController),
              ),
            ),
          ),
          Positioned(
            right: Dimens.DIMENS_12,
            bottom: Dimens.DIMENS_20,
            child: Opacity(
              opacity: 0.4,
              child: Column(
                children: [
                  _buildProfilePictures(),
                  SizedBox(
                    height: Dimens.DIMENS_38,
                  ),
                  _buildLikeButton(),
                  Text(
                    '0',
                    style: TextStyle(
                        color: COLOR_white_fff5f5f5,
                        fontSize: _IC_LABEL_FONTSIZE),
                  ),
                  SizedBox(
                    height: Dimens.DIMENS_12,
                  ),
                  Icon(
                    MdiIcons.messageText,
                    color: COLOR_white_fff5f5f5,
                    size: Dimens.DIMENS_28,
                  ),
                  Text(
                    '0',
                    style: TextStyle(
                        color: COLOR_white_fff5f5f5,
                        fontSize: _IC_LABEL_FONTSIZE),
                  ),
                  SizedBox(
                    height: Dimens.DIMENS_12,
                  ),
                  Transform.flip(
                    flipX: true,
                    child: Icon(
                      MdiIcons.reply,
                      color: COLOR_white_fff5f5f5,
                      size: Dimens.DIMENS_34,
                    ),
                  ),
                  SizedBox(
                    height: Dimens.DIMENS_15,
                  ),
                  Container(
                    width: Dimens.DIMENS_34,
                    height: Dimens.DIMENS_34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: COLOR_white_fff5f5f5),
                      borderRadius: BorderRadius.circular(5),
                      color: const Color.fromARGB(255, 27, 26, 26),
                    ),
                    child: Icon(
                      MdiIcons.controller,
                      color: COLOR_white_fff5f5f5,
                      size: Dimens.DIMENS_15,
                    ),
                  )
                ],
              ),
            ),
          ),
          _buildUserNameView(),
          _buildProgerBarIndicatorView(),
          Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Video size: $_fileMbSize',
                  style: TextStyle(
                      color: COLOR_white_fff5f5f5, fontWeight: FontWeight.bold),
                ),
              ))
        ],
      ),
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  Align _buildProgerBarIndicatorView() {
    return Align(
        alignment: Alignment.bottomCenter,
        child: Opacity(
          opacity: 0.4,
          child: SizedBox(
            height: 3,
            child: VideoProgressIndicator(
              _videoPlayerController,
              padding: EdgeInsets.zero,
              colors: VideoProgressColors(
                  bufferedColor: COLOR_white_fff5f5f5.withOpacity(0.3),
                  playedColor: COLOR_white_fff5f5f5),
              allowScrubbing: true,
            ),
          ),
        ));
  }

  Positioned _buildUserNameView() {
    return Positioned(
      bottom: Dimens.DIMENS_20,
      left: Dimens.DIMENS_12,
      child: Opacity(
        opacity: 0.4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '@username',
              style: TextStyle(
                  color: COLOR_white_fff5f5f5, fontSize: Dimens.DIMENS_18),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Caption',
                      style: TextStyle(
                          color: COLOR_white_fff5f5f5,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ),
            Icon(
              MdiIcons.controller,
              color: COLOR_white_fff5f5f5,
            )
          ],
        ),
      ),
    );
  }
}

CircleAvatar _buildProfilePictures() {
  return CircleAvatar(
    child: ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: SvgPicture.asset(
        Images.IC_PERSON_2_OUTLINE,
      ),
    ),
  );
}

Icon _buildLikeButton() {
  return Icon(
    MdiIcons.heart,
    size: Dimens.DIMENS_34,
    color: COLOR_white_fff5f5f5,
  );
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
