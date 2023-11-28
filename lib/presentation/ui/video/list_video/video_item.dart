import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/data/repository/coment_repository.dart';
import 'package:personal_project/data/repository/video_player_repository.dart';
import 'package:personal_project/domain/model/user.dart';
import 'package:personal_project/domain/model/video_model.dart';
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';
import 'package:personal_project/domain/reporsitory/video_repository.dart';
import 'package:personal_project/presentation/assets/images.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:personal_project/presentation/ui/auth/auth.dart';
import 'package:personal_project/presentation/ui/comments/comments_page.dart';
import 'package:personal_project/presentation/ui/video/list_video/bloc/video_player_bloc.dart';
import 'package:personal_project/presentation/ui/video/list_video/cubit/like_video_cubit.dart';
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

  // ignore: non_constant_identifier_names
  final double _IC_LABEL_FONTSIZE = 12;
  bool isViewed = false;

  @override
  Widget build(BuildContext context) {
    debugPrint('Its Rebuild${widget.videoData.caption}');
    var videoData = widget.videoData;
    Size size = MediaQuery.of(context).size;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => VideoPlayerBloc(
              videoPlayerRepository:
                  RepositoryProvider.of<VideoPlayerRepository>(context),
              videoRepository: RepositoryProvider.of<VideoRepository>(context))
            ..add(
              InitVideoPlayerEvent(url: widget.videoData.videoUrl),
            ),
        ),
        BlocProvider(
          create: (context) =>
              LikeVideoCubit(RepositoryProvider.of<VideoRepository>(context)),
        ),
      ],
      child: Builder(builder: (context) {
        return BlocListener<VideoPlayerBloc, VideoPlayerState>(
          listener: (context, state) {
            if (state is VideoPlayerIntialized) {
              debugPrint('vidnitialize');
              addViews(state: state, videoData: videoData);
            }
          },
          child: GestureDetector(
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
                  child: BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
                    buildWhen: (previous, current) {
                      if (current is VideoPaused) {
                        return false;
                      }
                      return true;
                    },
                    builder: (context, state) {
                      if (state is VideoPlayerIntialized) {
                        final CachedVideoPlayerController? controller =
                            state.videoPlayerController;
                        return FittedBox(
                          fit: BoxFit.contain,
                          child: SizedBox(
                            width:
                                state.videoPlayerController!.value.size.width,
                            height:
                                state.videoPlayerController!.value.size.height,
                            child: Stack(
                              children: [
                                VisibilityDetector(
                                  key: Key(
                                      'visible-video-key-//${widget.videoData.createdAt}'),
                                  onVisibilityChanged: (info) {
                                    final CachedVideoPlayerController?
                                        controller =
                                        state.videoPlayerController;
                                    var visiblePercentage =
                                        info.visibleFraction * 100;
                                    if (visiblePercentage < 5) {
                                      if (controller != null) {
                                        controller.pause();
                                      }
                                    } else {
                                      // Point the controller is initialized
                                      if (controller != null) {
                                        controller.play();
                                      }
                                    }
                                  },
                                  child: GestureDetector(
                                      onTap: () {
                                        BlocProvider.of<VideoPlayerBloc>(
                                                context)
                                            .add(PauseVideo());
                                      },
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            bottom: MediaQuery.of(context)
                                                .viewInsets
                                                .bottom),
                                        child: CachedVideoPlayer(
                                            state.videoPlayerController!),
                                      )),
                                ),
                                BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
                                  builder: (context, state) {
                                    if (state is VideoPaused) {
                                      return Align(
                                        alignment: Alignment.center,
                                        child: AnimatedOpacity(
                                          opacity: state.opacity!,
                                          duration: kThemeAnimationDuration,
                                          child: GestureDetector(
                                            onTap: controller!.play,
                                            child: FaIcon(
                                              FontAwesomeIcons.play,
                                              size: state.size,
                                              color: COLOR_white_fff5f5f5,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    return Container();
                                  },
                                ),
                              ],
                            ),
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
                              style: TextStyle(
                                  color: COLOR_white_fff5f5f5,
                                  fontSize: _IC_LABEL_FONTSIZE),
                            ),
                            SizedBox(
                              height: Dimens.DIMENS_12,
                            ),
                            FaIcon(
                              FontAwesomeIcons.circleExclamation,
                              color: COLOR_white_fff5f5f5,
                            ),
                            Text(
                              state is VideoPlayerError
                                  ? state.error.toString()
                                  : '',
                              textAlign: TextAlign.center,
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
                    builder: (_, snapshot) {
                      var data = snapshot.data;
                      return snapshot.hasData
                          ? Positioned(
                              right: Dimens.DIMENS_12,
                              bottom: Dimens.DIMENS_20,
                              child: Column(
                                children: [
                                  _buildProfilePictures(context, data),
                                  SizedBox(
                                    height: Dimens.DIMENS_38,
                                  ),
                                  _buildLikeButton(context, videoData),
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
                                  GestureDetector(
                                    onTap: () {
                                      Fluttertoast.showToast(
                                          msg: "Fitur share belum ada, Maap",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.TOP,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: COLOR_black_ff121212,
                                          textColor: Colors.white,
                                          fontSize: 16.0);
                                    },
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
                _buildUserNameView(context, videoData),
                _buildProgerBarIndicatorView(),
                const Align(
                  alignment: Alignment.center,
                  child: LikeWidget(),
                )
              ]),
            ),
          ),
        );
      }),
    );
  }

  void addViews(
      {required VideoPlayerIntialized state, required Video videoData}) {
    state.videoPlayerController!.addListener(() {
      int duratio = state.videoPlayerController!.value.duration.inSeconds;
      double minDur = 3 / 10 * duratio;

      debugPrint('add views $minDur');

      if (state.videoPlayerController!.value.position.inSeconds >
              minDur.toInt() &&
          !isViewed) {
        RepositoryProvider.of<VideoRepository>(context)
            .addViewsCount(videoData.id);
        debugPrint('add views');
        isViewed = true;
      }
    });
  }

  GestureDetector _buildLikeButton(BuildContext context, Video videoData) {
    return GestureDetector(
      onTap: () {
        int likeCount = int.parse(widget.videoData.likes.length.toString());
        String? uid =
            RepositoryProvider.of<AuthRepository>(context).currentUser?.uid;
        if (uid == null) {
          showAuthBottomSheetFunc(context);
        } else {
          bool isLiked = videoData.likes.contains(uid);
          BlocProvider.of<LikeVideoCubit>(context).likePost(
              postId: videoData.id,
              stateFromDatabase: isLiked,
              databaseLikeCount: likeCount);
        }
      },
      child: BlocBuilder<LikeVideoCubit, LikeVideoState>(
        buildWhen: (previous, current) {
          if (current is ShowDobleTapLikeWidget ||
              current is RemoveDoubleTapLikeWidget) {
            return false;
          }
          return true;
        },
        builder: (context, state) {
          String? uid =
              RepositoryProvider.of<AuthRepository>(context).currentUser?.uid;
          bool isLiked = videoData.likes.contains(uid);
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
    );
  }

  GestureDetector _buildProfilePictures(BuildContext context, User? data) {
    return GestureDetector(
      onTap: () {
        context.push(APP_PAGE.profile.toPath, extra: widget.videoData.uid);
      },
      child: CircleAvatar(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: CachedNetworkImage(
            imageUrl: data!.photo!,
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
      ),
    );
  }

  Align _buildProgerBarIndicatorView() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
        buildWhen: (previous, current) {
          if (current is VideoPaused) {
            return false;
          }
          return true;
        },
        builder: (context, state) {
          if (state is VideoPlayerIntialized) {
            return SizedBox(
              height: 3,
              child: CachedVideoProgressIndicator(
                state.videoPlayerController!,
                padding: EdgeInsets.zero,
                colors: VideoProgressColors(
                    bufferedColor: COLOR_white_fff5f5f5.withOpacity(0.3),
                    playedColor: COLOR_white_fff5f5f5),
                allowScrubbing: true,
              ),
            );
          }
          return Container();
        },
      ),
    );
  }

  FutureBuilder<User> _buildUserNameView(
      BuildContext context, Video videoData) {
    return FutureBuilder(
      future: RepositoryProvider.of<VideoRepository>(context)
          .getVideoOwnerData(widget.videoData.uid),
      builder: (context, snapshot) {
        var data = snapshot.data;
        if (snapshot.hasData) {
          return Positioned(
            bottom: Dimens.DIMENS_20,
            left: Dimens.DIMENS_12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '@${data!.userName!}',
                  style: TextStyle(
                      color: COLOR_white_fff5f5f5, fontSize: Dimens.DIMENS_16),
                ),
                Text(
                  videoData.caption,
                  style: TextStyle(
                      color: COLOR_white_fff5f5f5, fontWeight: FontWeight.w300),
                ),
                SvgPicture.asset(Images.IC_MUSIC)
              ],
            ),
          );
        }
        return Container();
      },
    );
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
