import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/domain/model/video_model.dart';
import 'package:personal_project/domain/reporsitory/video_repository.dart';
import 'package:personal_project/presentation/assets/images.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:personal_project/presentation/ui/video/list_video/bloc/video_player_bloc.dart';
import 'package:video_player/video_player.dart';

class VideoItem extends StatefulWidget {
  final Video videoData;
  const VideoItem({super.key, required this.videoData});

  @override
  State<VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    _videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoData.videoUrl));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) =>
          VideoPlayerBloc(RepositoryProvider.of<VideoRepository>(context))
            ..add(InitVideoPlayer(
                controller: _videoPlayerController,
                ownerUid: widget.videoData.uid)),
      child: Container(
        padding: EdgeInsets.only(bottom: 10),
        width: size.width,
        height: size.height,
        child: Stack(children: [
          Container(
            width: size.width,
            height: size.height,
            alignment: Alignment.center,
            child: BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
              builder: (context, state) {
                if (state is VideoPlayerIntialized) {
                  return FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                        width: _videoPlayerController.value.size.width,
                        height: _videoPlayerController.value.size.height,
                        child: VideoPlayer(_videoPlayerController)),
                  );
                }
                return Container(
                  width: size.width,
                  height: size.height,
                  alignment: Alignment.center,
                  child: Image.network(
                    widget.videoData.thumnail,
                    width: size.width,
                    fit: BoxFit.contain,
                  ),
                );
              },
            ),
          ),
          BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
            builder: (context, state) {
              if (state is VideoPlayerIntialized) {
                var data = widget.videoData;
                return Positioned(
                    right: Dimens.DIMENS_12,
                    bottom: 0,
                    child: Column(
                      children: [
                        GestureDetector(
                            onTap: () {},
                            child: CircleAvatar(
                              child: Image.network(state.ownerData.photo!),
                            )),
                        SizedBox(
                          height: Dimens.DIMENS_38,
                        ),
                        Icon(
                          Icons.favorite,
                          color: COLOR_white_fff5f5f5,
                          size: Dimens.DIMENS_38,
                        ),
                        Text(
                          data.likes.length.toString(),
                          style: TextStyle(color: COLOR_white_fff5f5f5),
                        ),
                        SizedBox(
                          height: Dimens.DIMENS_12,
                        ),
                        Icon(
                          Icons.message,
                          color: COLOR_white_fff5f5f5,
                          size: Dimens.DIMENS_34,
                        ),
                        Text(
                          '10',
                          style: TextStyle(color: COLOR_white_fff5f5f5),
                        ),
                        SizedBox(
                          height: Dimens.DIMENS_12,
                        ),
                        Icon(
                          Icons.reply,
                          color: COLOR_white_fff5f5f5,
                          size: Dimens.DIMENS_38,
                        ),
                        Text(
                          '10',
                          style: TextStyle(color: COLOR_white_fff5f5f5),
                        ),
                        SizedBox(
                          height: Dimens.DIMENS_38,
                        ),
                        Container()
                      ],
                    ));
              }
              return Container();
            },
          ),
          BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
            builder: (context, state) {
              if (state is VideoPlayerIntialized) {
                return Positioned(
                  bottom: 0,
                  left: Dimens.DIMENS_12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.ownerData.userName!,
                        style: TextStyle(
                            color: COLOR_white_fff5f5f5,
                            fontSize: Dimens.DIMENS_16),
                      ),
                      Text(
                        "Lorem ipsum dolor sit amet",
                        style: TextStyle(
                            color: COLOR_white_fff5f5f5,
                            fontWeight: FontWeight.w300),
                      ),
                      SvgPicture.asset(Images.IC_MUSIC)
                    ],
                  ),
                );
              }
              return Container();
            },
          )
        ]),
      ),
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }
}
