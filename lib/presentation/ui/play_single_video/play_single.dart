import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/data/repository/coment_repository.dart';
import 'package:personal_project/domain/model/video_model.dart';
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';
import 'package:personal_project/domain/reporsitory/video_repository.dart';
import 'package:personal_project/presentation/assets/images.dart';
import 'package:personal_project/presentation/ui/auth/auth.dart';
import 'package:personal_project/presentation/ui/comments/comments_page.dart';
import 'package:personal_project/presentation/ui/play_single_video/cubit/play_button_cubit.dart';
import 'package:personal_project/presentation/ui/video/list_video/cubit/like_video_cubit.dart';
import 'package:video_cached_player/video_cached_player.dart';
import 'package:video_player/video_player.dart';

class PlaySingleVideoPage extends StatefulWidget {
  final Video videoData;
  const PlaySingleVideoPage({super.key, required this.videoData});

  @override
  State<PlaySingleVideoPage> createState() => _PlaySingleVideoPageState();
}

class _PlaySingleVideoPageState extends State<PlaySingleVideoPage> {
  late CachedVideoPlayerController controller;
  // ignore: non_constant_identifier_names
  final double _IC_LABEL_FONTSIZE = 12;
  bool isViewed = false;

  @override
  void initState() {
    controller = CachedVideoPlayerController.network(widget.videoData.videoUrl);
    controller.initialize().then((value) {
      if (controller.value.isInitialized) {
        controller.play();
        controller.setLooping(true);
        setState(() {});
        _addViews();
      }
    });
    super.initState();
  }

  void _addViews() {
    controller.addListener(() {
      int duratio = controller.value.duration.inSeconds;
      double minDur = 3 / 10 * duratio;

      if (controller.value.position.inSeconds > minDur.toInt() && !isViewed) {
        RepositoryProvider.of<VideoRepository>(context)
            .addViewsCount(widget.videoData.id);

        isViewed = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Its Rebuild${widget.videoData.caption}');
    var videoData = widget.videoData;
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                LikeVideoCubit(RepositoryProvider.of<VideoRepository>(context)),
          ),
          BlocProvider(create: (context) => PlayButtonCubit())
        ],
        child: Builder(builder: (context) {
          return GestureDetector(
            onTap: () {
              BlocProvider.of<PlayButtonCubit>(context)
                  .playHandle(controller.value.isPlaying);
              if (controller.value.isPlaying) {
                controller.pause();
              } else {
                controller.play();
              }
            },
            onDoubleTap: () {
              String? uid = RepositoryProvider.of<AuthRepository>(context)
                  .currentUser
                  ?.uid;

              bool isLiked = videoData.likes.contains(uid);
              BlocProvider.of<LikeVideoCubit>(context).doubleTapToLike(
                  postId: videoData.id,
                  dataBaseState: isLiked,
                  databaseLikeCount: videoData.likes.length);
            },
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: Stack(children: [
                Container(
                  width: size.width,
                  height: size.height,
                  alignment: Alignment.center,
                  child: !controller.value.isInitialized
                      ? Container()
                      : FittedBox(
                          fit: BoxFit.contain,
                          child: SizedBox(
                              width: controller.value.isInitialized
                                  ? controller.value.size.width
                                  : 0,
                              height: controller.value.isInitialized
                                  ? controller.value.size.height
                                  : 0,
                              child: CachedVideoPlayer(controller))),
                ),
                FutureBuilder(
                    future: RepositoryProvider.of<VideoRepository>(context)
                        .getVideoOwnerData(widget.videoData.uid),
                    builder: (context, snapshot) {
                      var data = snapshot.data;
                      return snapshot.hasData
                          ? Positioned(
                              right: Dimens.DIMENS_12,
                              bottom: Dimens.DIMENS_20,
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
                                              const Icon(Icons.error),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: Dimens.DIMENS_38,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      int likeCount = int.parse(widget
                                          .videoData.likes.length
                                          .toString());
                                      String? uid =
                                          RepositoryProvider.of<AuthRepository>(
                                                  context)
                                              .currentUser
                                              ?.uid;
                                      if (uid == null) {
                                        showAuthBottomSheetFunc(context);
                                      } else {
                                        bool isLiked =
                                            videoData.likes.contains(uid);
                                        BlocProvider.of<LikeVideoCubit>(context)
                                            .likePost(
                                                postId: videoData.id,
                                                stateFromDatabase: isLiked,
                                                databaseLikeCount: likeCount);
                                      }
                                    },
                                    child: BlocBuilder<LikeVideoCubit,
                                        LikeVideoState>(
                                      buildWhen: (previous, current) {
                                        if (current is ShowDobleTapLikeWidget ||
                                            current
                                                is RemoveDoubleTapLikeWidget) {
                                          return false;
                                        }
                                        return true;
                                      },
                                      builder: (context, state) {
                                        String? uid = RepositoryProvider.of<
                                                AuthRepository>(context)
                                            .currentUser
                                            ?.uid;
                                        bool isLiked =
                                            videoData.likes.contains(uid);
                                        if (state is VideoIsLiked) {
                                          return Icon(
                                            MdiIcons.heart,
                                            size: Dimens.DIMENS_34,
                                            color: Colors.red,
                                          );
                                        } else if (state is UnilkedVideo) {
                                          return Icon(
                                            MdiIcons.heart,
                                            size: Dimens.DIMENS_34,
                                            color: COLOR_white_fff5f5f5,
                                          );
                                        }
                                        return isLiked
                                            ? Icon(
                                                MdiIcons.heart,
                                                size: Dimens.DIMENS_34,
                                                color: Colors.red,
                                              )
                                            : Icon(
                                                MdiIcons.heart,
                                                size: Dimens.DIMENS_34,
                                                color: COLOR_white_fff5f5f5,
                                              );
                                      },
                                    ),
                                  ),
                                  BlocBuilder<LikeVideoCubit, LikeVideoState>(
                                    buildWhen: (previous, current) {
                                      if (current is ShowDobleTapLikeWidget ||
                                          current
                                              is RemoveDoubleTapLikeWidget) {
                                        return false;
                                      }
                                      return true;
                                    },
                                    builder: (context, state) {
                                      if (state is VideoIsLiked) {
                                        debugPrint(
                                            'likeCount${state.likeCount}');
                                        return Text(
                                          state.likeCount.toString(),
                                          style: TextStyle(
                                              color: COLOR_white_fff5f5f5,
                                              fontSize: _IC_LABEL_FONTSIZE),
                                        );
                                      } else if (state is UnilkedVideo) {
                                        return Text(state.likeCount.toString(),
                                            style: TextStyle(
                                                color: COLOR_white_fff5f5f5,
                                                fontSize: _IC_LABEL_FONTSIZE));
                                      }
                                      return Text(
                                        videoData.likes.length.toString(),
                                        style: TextStyle(
                                            color: COLOR_white_fff5f5f5,
                                            fontSize: _IC_LABEL_FONTSIZE),
                                      );
                                    },
                                  ),
                                  SizedBox(
                                    height: Dimens.DIMENS_12,
                                  ),
                                  RepositoryProvider(
                                    create: (context) => CommentRepository(),
                                    child: GestureDetector(
                                      onTap: () {
                                        MediaQuery.of(context)
                                            .viewInsets
                                            .bottom; ///////
                                        showModalBottomSheet(
                                            context: context,
                                            backgroundColor: Colors.transparent,
                                            useSafeArea: true,
                                            isScrollControlled: true,
                                            builder: (context) {
                                              debugPrint(
                                                  'bottomInset${MediaQuery.of(context).viewInsets.bottom}');
                                              return CommentBottomSheet(
                                                postId: widget.videoData.id,
                                              );
                                            });
                                      },
                                      child: Icon(
                                        MdiIcons.messageText,
                                        color: COLOR_white_fff5f5f5,
                                        size: Dimens.DIMENS_28,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    videoData.commentCount.toString(),
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
                                      border: Border.all(
                                          color: COLOR_white_fff5f5f5),
                                      borderRadius: BorderRadius.circular(5),
                                      color:
                                          const Color.fromARGB(255, 27, 26, 26),
                                    ),
                                    child: FaIcon(
                                      FontAwesomeIcons.gamepad,
                                      color: COLOR_white_fff5f5f5,
                                      size: Dimens.DIMENS_15,
                                    ),
                                  )
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
                        left: Dimens.DIMENS_12,
                        bottom: Dimens.DIMENS_20,
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
                              videoData.caption,
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
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    height: 3,
                    child: CachedVideoProgressIndicator(
                      controller,
                      padding: EdgeInsets.zero,
                      colors: VideoProgressColors(
                          bufferedColor: COLOR_white_fff5f5f5.withOpacity(0.3),
                          playedColor: COLOR_white_fff5f5f5),
                      allowScrubbing: true,
                    ),
                  ),
                ),
                const Align(
                  alignment: Alignment.center,
                  child: LikeWidget(),
                ),
                BlocBuilder<PlayButtonCubit, PlayButtonState>(
                  builder: (context, state) {
                    return state.status == PlayStatus.pause
                        ? Align(
                            alignment: Alignment.center,
                            child: AnimatedOpacity(
                              opacity: state.status == PlayStatus.play ? 0 : 1,
                              duration: kThemeAnimationDuration,
                              child: GestureDetector(
                                onTap: () {
                                  BlocProvider.of<PlayButtonCubit>(context)
                                      .playHandle(controller.value.isPlaying);
                                  if (controller.value.isPlaying) {
                                    controller.pause();
                                  } else {
                                    controller.play();
                                  }
                                  debugPrint('playy');
                                },
                                child: FaIcon(
                                  FontAwesomeIcons.play,
                                  size: state.status == PlayStatus.pause
                                      ? Dimens.DIMENS_34
                                      : Dimens.DIMENS_18,
                                  color: COLOR_white_fff5f5f5,
                                ),
                              ),
                            ),
                          )
                        : Container();
                  },
                )
              ]),
            ),
          );
        }),
      ),
    );
  }

  @override
  void dispose() {
    controller.removeListener(() {});
    controller.dispose();
    super.dispose();
  }
}

class LikeWidget extends StatelessWidget {
  const LikeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LikeVideoCubit, LikeVideoState>(
      buildWhen: (previous, current) {
        if (current is VideoIsLiked) {
          return true;
        }
        return true;
      },
      builder: (context, state) {
        if (state is ShowDobleTapLikeWidget) {
          return AnimatedOpacity(
            opacity: state.isVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Icon(
              MdiIcons.heart,
              color: Colors.red,
              size: state.isVisible ? 80 : 50,
            ),
          );
        }
        return Container();
      },
    );
  }
}
