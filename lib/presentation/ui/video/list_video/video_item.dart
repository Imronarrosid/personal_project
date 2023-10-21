import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/data/repository/video_player_repository.dart';
import 'package:personal_project/domain/model/video_model.dart';
import 'package:personal_project/domain/reporsitory/video_repository.dart';
import 'package:personal_project/presentation/assets/images.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:personal_project/presentation/ui/video/list_video/bloc/paging_bloc.dart';
import 'package:personal_project/presentation/ui/video/list_video/bloc/video_player_bloc.dart';
import 'package:video_cached_player/video_cached_player.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoItem extends StatefulWidget {
  final Video videoData;
  const VideoItem({super.key, required this.videoData});

  @override
  State<VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  // late VideoPlayerController _videoPlayerController;

  // @override
  // void initState() {
  //   try {
  //     _videoPlayerController = VideoPlayerController.networkUrl(
  //         Uri.parse(widget.videoData.videoUrl));
  //     debugPrint('InitState');
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    debugPrint('Its Rebuild' + widget.videoData.caption);
    Size size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => VideoPlayerBloc(
          videoPlayerRepository:
              RepositoryProvider.of<VideoPlayerRepository>(context),
          videoRepository: RepositoryProvider.of<VideoRepository>(context))
        ..add(
          InitVideoPlayerEvent(url: widget.videoData.videoUrl),
        ),
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
                      width: state.videoPlayerController!.value.size.width,
                      height: state.videoPlayerController!.value.size.height,
                      child: VisibilityDetector(
                          key: Key(
                              'visible-video-key-${widget.videoData.createdAt}'),
                          onVisibilityChanged: (info) {
                            final controller = state.videoPlayerController!;
                            var visiblePercentage = info.visibleFraction * 100;
                            if (visiblePercentage < 5) {
                              controller.pause();
                              controller.dispose();
                              debugPrint('dispose controller when not needed');
                            } else {
                              // Point the controller is initialized
                              controller.play();
                            }
                          },
                          child:
                              CachedVideoPlayer(state.videoPlayerController!)),
                    ),
                  );
                } else if (state is VideoPlayerInitial) {
                  return const CircularProgressIndicator();
                }
                return Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Tidak dapat menampilkan video',
                        style: TextStyle(color: COLOR_white_fff5f5f5),
                      ),
                      SizedBox(
                        height: Dimens.DIMENS_12,
                      ),
                      FaIcon(
                        FontAwesomeIcons.circleExclamation,
                        color: COLOR_white_fff5f5f5,
                      ),
                      Text(
                        state is VideoPlayerError ? state.error.toString() : '',
                        style: TextStyle(color: COLOR_white_fff5f5f5),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          FutureBuilder(
              future: RepositoryProvider.of<VideoRepository>(context)
                  .getVideoOwnerData(widget.videoData.uid),
              builder: (context, snapshot) {
                var data = snapshot.data;
                return snapshot.hasData
                    ? Positioned(
                        right: Dimens.DIMENS_12,
                        bottom: 0,
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {},
                              child: CircleAvatar(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: CachedNetworkImage(
                                    imageUrl: data!.photo!,
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: Dimens.DIMENS_38,
                            ),
                            Icon(
                              Icons.favorite,
                              color: COLOR_white_fff5f5f5,
                              size: Dimens.DIMENS_38,
                            ),
                            Text(
                              widget.videoData.likes.length.toString(),
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
                        ),
                      )
                    : Container();
              }),
          FutureBuilder(
            future: RepositoryProvider.of<VideoRepository>(context)
                .getVideoOwnerData(widget.videoData.uid),
            builder: (context, snapshot) {
              var data = snapshot.data;
              if (snapshot.hasData) {
                return Positioned(
                  bottom: 0,
                  left: Dimens.DIMENS_12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data!.userName!,
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
}
