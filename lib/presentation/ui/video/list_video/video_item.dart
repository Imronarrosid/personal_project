import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart' as ezl;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:personal_project/config/bloc_status_enum.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/data/repository/coment_repository.dart';
import 'package:personal_project/data/repository/video_player_repository.dart';
import 'package:personal_project/domain/model/profile_data_model.dart';
import 'package:personal_project/domain/model/user.dart';
import 'package:personal_project/domain/model/video_from_game_data_model.dart';
import 'package:personal_project/domain/model/video_model.dart';
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';
import 'package:personal_project/domain/reporsitory/user_repository.dart';
import 'package:personal_project/domain/reporsitory/video_repository.dart';
import 'package:personal_project/domain/services/firebase/firebase_service.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:personal_project/presentation/shared_components/menu_modal_bottom_sheet.dart';
import 'package:personal_project/presentation/ui/add_details/bloc/upload_bloc.dart';
import 'package:personal_project/presentation/ui/auth/auth.dart';
import 'package:personal_project/presentation/ui/comments/comments_page.dart';
import 'package:personal_project/presentation/ui/profile/bloc/user_video_paging_bloc.dart';
import 'package:personal_project/presentation/ui/profile/cubit/follow_cubit.dart';
import 'package:personal_project/presentation/ui/video/list_video/bloc/video_player_bloc.dart';
import 'package:personal_project/presentation/ui/video/list_video/cubit/captions_cubit.dart';
import 'package:personal_project/presentation/ui/video/list_video/cubit/like_video_cubit.dart';
import 'package:personal_project/utils/number_format.dart';
import 'package:video_cached_player/video_cached_player.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoItem extends StatefulWidget {
  final int index;
  final Video videoData;

  /// if value is true video will auto
  ///
  /// play and pause
  final bool auto;
  final bool? isForLogedUserVideo;
  const VideoItem({
    super.key,
    required this.index,
    required this.videoData,
    this.auto = false,
    this.isForLogedUserVideo = false,
  });

  @override
  State<VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  // ignore: non_constant_identifier_names
  final double _IC_LABEL_FONTSIZE = 12;
  bool isViewed = false;
  bool isActive = true;
  @override
  Widget build(BuildContext context) {
    debugPrint('Its Rebuild${widget.videoData.caption}');
    var videoData = widget.videoData;
    Size size = MediaQuery.of(context).size;
    final AuthRepository authRepository =
        RepositoryProvider.of<AuthRepository>(context);
    final VideoRepository videoRepository =
        RepositoryProvider.of<VideoRepository>(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LikeVideoCubit(videoRepository),
        ),
        BlocProvider(create: ((context) => CaptionsCubit()))
      ],
      child: Builder(builder: (context) {
        return BlocListener<VideoPlayerBloc, VideoPlayerState>(
          listener: (context, state) {
            if (state.status == VideoPlayerStatus.initialized) {
              debugPrint('vidnitialize');

              if (isViewed == false) {
                addViews(state: state, videoData: videoData);
              }
            }
          },
          child: GestureDetector(
            onTap: () {
              final VideoPlayerRepository repo =
                  RepositoryProvider.of<VideoPlayerRepository>(context);
              VideoPlayerBloc bloc = BlocProvider.of<VideoPlayerBloc>(context);
              if (repo.controller != null) {
                if (repo.controller!.value.isPlaying) {
                  bloc.add(const VideoPlayerEvent(actions: VideoEvent.pause));
                } else {
                  bloc.add(const VideoPlayerEvent(actions: VideoEvent.play));
                }
              }
            },
            onDoubleTap: () {
              String? uid = RepositoryProvider.of<AuthRepository>(context)
                  .currentUser
                  ?.uid;

              bool isLiked = videoData.likes.contains(uid);
              BlocProvider.of<LikeVideoCubit>(context).doubleTapToLike(
                  postId: videoData.id!,
                  dataBaseState: isLiked,
                  databaseLikeCount: videoData.likes.length);
            },
            child: BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
              builder: (context, state) {
                if (state.status == VideoPlayerStatus.videoDeleted) {
                  return const Center(
                    child: Text('Video deleted'),
                  );
                }
                return SizedBox(
                  width: size.width,
                  height: size.height,
                  child: Stack(children: [
                    Container(
                      width: size.width,
                      height: size.height,
                      alignment: Alignment.center,
                      child: BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
                        buildWhen: (previous, current) {
                          if (current.status == VideoPlayerStatus.paused ||
                              current.status == VideoPlayerStatus.playing) {
                            return false;
                          }
                          return true;
                        },
                        builder: (context, state) {
                          if (state.status == VideoPlayerStatus.initialized) {
                            return FittedBox(
                              fit: BoxFit.contain,
                              child: SizedBox(
                                width: state.controller!.value.size.width,
                                height: state.controller!.value.size.height,
                                child: Stack(
                                  children: [
                                    VisibilityDetector(
                                      key: Key(
                                          'visible-video-key-//${widget.videoData.createdAt}'),
                                      onVisibilityChanged: (info) {
                                        final CachedVideoPlayerController?
                                            controller = state.controller;
                                        var visiblePercentage =
                                            info.visibleFraction * 100;
                                        if (visiblePercentage < 30 &&
                                            widget.auto &&
                                            isActive) {
                                          if (controller!.value.isInitialized) {
                                            BlocProvider.of<VideoPlayerBloc>(
                                                    context)
                                                .add(const VideoPlayerEvent(
                                                    actions: VideoEvent.pause));
                                          }
                                        } else {
                                          // Point the controller is initialized
                                          if (controller!.value.isInitialized &&
                                              widget.auto &&
                                              isActive) {
                                            BlocProvider.of<VideoPlayerBloc>(
                                                    context)
                                                .add(const VideoPlayerEvent(
                                                    actions: VideoEvent.play));
                                          }
                                        }
                                      },
                                      child:
                                          CachedVideoPlayer(state.controller!),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else if (state is VideoPlayerInitial) {
                            return SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: CachedNetworkImage(
                                imageUrl: videoData.thumnail,
                                fit: BoxFit.fitWidth,
                              ),
                            );
                          }
                          return Column(
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
                                state.status == VideoPlayerStatus.error
                                    ? state.error.toString()
                                    : '',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: COLOR_white_fff5f5f5),
                              ),
                            ],
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
                                  bottom: Dimens.DIMENS_18,
                                  child: Column(
                                    children: [
                                      _buildProfilePictures(context, data),
                                      SizedBox(
                                        height: Dimens.DIMENS_25,
                                      ),
                                      _buildLikeButton(context, videoData),
                                      SizedBox(
                                        height: Dimens.DIMENS_5,
                                      ),
                                      BlocBuilder<LikeVideoCubit,
                                          LikeVideoState>(
                                        buildWhen: (previous, current) {
                                          if (current
                                                  is ShowDobleTapLikeWidget ||
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
                                                fontSize: _IC_LABEL_FONTSIZE,
                                              ),
                                            );
                                          } else if (state is UnilkedVideo) {
                                            return Text(
                                              numberFormat(context.locale,
                                                  state.likeCount),
                                              style: TextStyle(
                                                color: COLOR_white_fff5f5f5,
                                                fontSize: _IC_LABEL_FONTSIZE,
                                              ),
                                            );
                                          }
                                          return Text(
                                            numberFormat(context.locale,
                                                videoData.likes.length),
                                            style: TextStyle(
                                              color: COLOR_white_fff5f5f5,
                                              fontSize: _IC_LABEL_FONTSIZE,
                                            ),
                                          );
                                        },
                                      ),
                                      SizedBox(
                                        height: Dimens.DIMENS_25,
                                      ),
                                      RepositoryProvider(
                                        create: (context) =>
                                            CommentRepository(),
                                        child: GestureDetector(
                                          onTap: () {
                                            showModalBottomSheet(
                                                context: context,
                                                backgroundColor:
                                                    Colors.transparent,
                                                useSafeArea: true,
                                                elevation: 0,
                                                isScrollControlled: true,
                                                builder: (context) {
                                                  return CommentBottomSheet(
                                                    postId:
                                                        widget.videoData.id!,
                                                  );
                                                });
                                          },
                                          child: Icon(
                                            BootstrapIcons.chat_dots_fill,
                                            color: COLOR_white_fff5f5f5,
                                            size: Dimens.DIMENS_28,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: Dimens.DIMENS_5,
                                      ),
                                      Text(
                                        numberFormat(
                                          context.locale,
                                          videoData.commentCount,
                                        ),
                                        style: TextStyle(
                                          color: COLOR_white_fff5f5f5,
                                          fontSize: _IC_LABEL_FONTSIZE,
                                        ),
                                      ),
                                      SizedBox(
                                        height: Dimens.DIMENS_20,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          debugPrint(
                                              'lmnop${LocaleKeys.message_share_featur_not_ready.tr()}');
                                          Fluttertoast.showToast(
                                            msg: LocaleKeys
                                                .message_share_featur_not_ready
                                                .tr(),
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.TOP,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor:
                                                COLOR_black_ff121212,
                                            textColor: Colors.white,
                                            fontSize: 16.0,
                                          );
                                        },
                                        child: Transform.flip(
                                          flipX: true,
                                          child: Icon(
                                            BootstrapIcons.reply_fill,
                                            color: COLOR_white_fff5f5f5,
                                            size: Dimens.DIMENS_34,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: Dimens.DIMENS_25,
                                      ),
                                      _videoMenu(
                                        context,
                                        videoData,
                                        authRepository,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          if (videoData.game != null) {
                                            context.push(
                                                APP_PAGE.videoFromGame.toPath,
                                                extra: VideoFromGameData(
                                                    game: videoData.game!,
                                                    captions: videoData.caption,
                                                    profileImg: data!.photo!));
                                          } else {
                                            Fluttertoast.showToast(
                                                gravity: ToastGravity.TOP,
                                                msg: LocaleKeys.message_no_game
                                                    .tr());
                                          }
                                        },
                                        child: Container(
                                          width: Dimens.DIMENS_30,
                                          height: Dimens.DIMENS_30,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: COLOR_white_fff5f5f5),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: const Color.fromARGB(
                                                255, 27, 26, 26),
                                          ),
                                          child: videoData.game == null
                                              ? Icon(
                                                  MdiIcons.controller,
                                                  color: COLOR_white_fff5f5f5,
                                                  size: Dimens.DIMENS_15,
                                                )
                                              : _buildGameImage(videoData),
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
                    ),
                    BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
                      builder: (context, state) {
                        return Align(
                          alignment: Alignment.center,
                          child: AnimatedOpacity(
                            opacity: state.status == VideoPlayerStatus.paused
                                ? 1
                                : 0,
                            duration: kThemeAnimationDuration,
                            child: GestureDetector(
                              onTap: () {
                                BlocProvider.of<VideoPlayerBloc>(context).add(
                                    const VideoPlayerEvent(
                                        actions: VideoEvent.play));
                              },
                              child: FaIcon(
                                FontAwesomeIcons.play,
                                size: state.status == VideoPlayerStatus.paused
                                    ? Dimens.DIMENS_38
                                    : Dimens.DIMENS_50,
                                color: COLOR_white_fff5f5f5,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ]),
                );
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _videoMenu(
    BuildContext context,
    Video videoData,
    AuthRepository authRepository,
  ) {
    return widget.isForLogedUserVideo!
        ? Padding(
            padding: EdgeInsets.only(bottom: Dimens.DIMENS_25),
            child: GestureDetector(
              onTap: () {
                if (videoData.uid == authRepository.currentUser?.uid &&
                    authRepository.currentUser?.uid != null) {
                  showModalBottomSheetMenu(context, height: 100, menu: [
                    Material(
                      child: ListTile(
                        tileColor: Colors.transparent,
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                    title: Text(
                                        LocaleKeys.message_delete_video.tr()),
                                    actions: [
                                      TextButton(
                                        onPressed: () => context.pop(),
                                        child: Text(
                                          LocaleKeys.label_cancel.tr(),
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.5),
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          BlocProvider.of<VideoPlayerBloc>(
                                                  context)
                                              .add(VideoPlayerEvent(
                                            actions: VideoEvent.delete,
                                            postId: videoData.id,
                                          ));
                                          BlocProvider.of<UploadBloc>(context)
                                              .add(
                                            DeleteVideo(
                                              pagingIndex: widget.index,
                                            ),
                                          );
                                          context.pop();
                                          context.pop();
                                          context.pop();
                                        },
                                        child: Text(
                                          LocaleKeys.label_delete.tr(),
                                        ),
                                      )
                                    ],
                                  ));
                        },
                        leading: const Icon(
                          BootstrapIcons.trash3,
                          size: 20,
                        ),
                        title: Text(LocaleKeys.label_delete_video.tr()),
                      ),
                    )
                  ]);
                }
              },
              child: Icon(
                Icons.more_horiz,
                size: Dimens.DIMENS_34,
              ),
            ))
        : Container();
  }

  @override
  void deactivate() {
    isActive = false;
    super.deactivate();
  }

  ClipRRect _buildGameImage(Video videoData) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: SizedBox.expand(
        child: CachedNetworkImage(
          imageUrl: videoData.game!.gameImage!,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  void addViews({required VideoPlayerState state, required Video videoData}) {
    state.controller!.addListener(() {
      int duratio = state.controller!.value.duration.inSeconds;
      double minDur = 3 / 10 * duratio;

      if (state.controller!.value.position.inSeconds > minDur.toInt() &&
          !isViewed) {
        RepositoryProvider.of<VideoRepository>(context)
            .addViewsCount(videoData.id!);
        debugPrint('add views');
        isViewed = true;
        state.controller!.removeListener(() {});
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
              postId: videoData.id!,
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
        _toProfile(context, data);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: COLOR_white_fff5f5f5),
        ),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: CachedNetworkImage(
              imageUrl: data!.photo!,
              fit: BoxFit.cover,
              width: double.infinity,
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        ),
      ),
    );
  }

  void _toProfile(BuildContext context, User data) {
    context.push(APP_PAGE.profile.toPath,
        extra: ProfilePayload(
            uid: data.id,
            name: data.name!,
            userName: data.userName!,
            photoURL: data.photo!));
  }

  Align _buildProgerBarIndicatorView() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
        buildWhen: (previous, current) {
          if (current.status == VideoPlayerStatus.paused ||
              current.status == VideoPlayerStatus.playing) {
            return false;
          }
          return true;
        },
        builder: (context, state) {
          if (state.status == VideoPlayerStatus.initialized) {
            return SizedBox(
              height: 3,
              child: CachedVideoProgressIndicator(
                state.controller!,
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
    final UserRepository userRepository =
        RepositoryProvider.of<UserRepository>(context);
    return FutureBuilder(
      future: RepositoryProvider.of<VideoRepository>(context)
          .getVideoOwnerData(widget.videoData.uid),
      builder: (context, snapshot) {
        var data = snapshot.data;
        if (snapshot.hasData) {
          return Positioned(
            bottom: Dimens.DIMENS_18,
            left: Dimens.DIMENS_12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _toProfile(context, data);
                      },
                      child: Text(
                        '@${data!.userName!}',
                        style: TextStyle(
                            color: COLOR_white_fff5f5f5, fontSize: 14),
                      ),
                    ),
                    SizedBox(
                      width: Dimens.DIMENS_10,
                    ),
                    data.id == firebaseAuth.currentUser!.uid
                        ? Container()
                        : FutureBuilder<bool>(
                            future: userRepository.isFollowing(data.id),
                            builder: (context, AsyncSnapshot<bool> snapshot) {
                              bool? isFollowing = snapshot.data;
                              if (!snapshot.hasData ||
                                  snapshot.hasError ||
                                  isFollowing!) {
                                return Container();
                              }
                              debugPrint('oioi $isFollowing}');
                              debugPrint('oioi ${data.id}');

                              return BlocProvider(
                                create: (context) => FollowCubit(
                                    RepositoryProvider.of<UserRepository>(
                                        context)),
                                child: BlocBuilder<FollowCubit, FollowState>(
                                  builder: (context, state) {
                                    return InkWell(
                                      onTap: () {
                                        if (firebaseAuth.currentUser == null) {
                                          showAuthBottomSheetFunc(context);
                                        } else {
                                          BlocProvider.of<FollowCubit>(context)
                                              .followButtonHandle(
                                            currentUserUid:
                                                firebaseAuth.currentUser!.uid,
                                            uid: data.id,
                                            stateFromDatabase: isFollowing,
                                          );
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: Dimens.DIMENS_6,
                                          horizontal: Dimens.DIMENS_13,
                                        ),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                              color: state.status ==
                                                          BlocStatus
                                                              .following ||
                                                      isFollowing
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                  : Colors.transparent,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: state.status ==
                                                        BlocStatus.following ||
                                                    isFollowing
                                                ? Colors.transparent
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .onTertiary),
                                        child: Text(
                                          state.status ==
                                                      BlocStatus.following ||
                                                  isFollowing
                                              ? LocaleKeys.label_following.tr()
                                              : LocaleKeys.label_follow.tr(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            })
                  ],
                ),
                Visibility(
                  visible: videoData.caption.isNotEmpty,
                  child: SizedBox(
                    height: Dimens.DIMENS_10,
                  ),
                ),
                BlocBuilder<CaptionsCubit, CaptionsState>(
                  builder: (context, state) {
                    int? maxLines = 2;

                    if (state.status == Captions.seeLess) {
                      maxLines = 2;
                    } else if (state.status == Captions.seeMore) {
                      maxLines = null;
                    }

                    return LayoutBuilder(builder: (context, boxConstraints) {
                      String text = videoData.caption;
                      final textPainter = TextPainter(
                        text: TextSpan(
                          text: text,
                          style: const TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.w400),
                        ),
                        textDirection: TextDirection.ltr,
                      );
                      textPainter.layout(
                          maxWidth: MediaQuery.of(context).size.width * 0.7);
                      final lines = (textPainter.size.height /
                              textPainter.preferredLineHeight)
                          .ceil();
                      return SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              videoData.caption.isEmpty
                                  ? Container()
                                  : Text(
                                      videoData.caption,
                                      maxLines: maxLines,
                                      style: TextStyle(
                                          color: COLOR_white_fff5f5f5,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w400),
                                    ),
                              Visibility(
                                visible: videoData.caption.isNotEmpty ||
                                    videoData.game != null,
                                child: SizedBox(
                                  height: Dimens.DIMENS_10,
                                ),
                              ),
                              lines > 2
                                  ? InkWell(
                                      onTap: () {
                                        BlocProvider.of<CaptionsCubit>(context)
                                            .captionsHandle();
                                      },
                                      child: Text(
                                        maxLines != null
                                            ? LocaleKeys.label_see_more.tr()
                                            : LocaleKeys.label_see_less.tr(),
                                        style: TextStyle(color: COLOR_grey),
                                      ),
                                    )
                                  : Container()
                            ],
                          ),
                        ),
                      );
                    });
                  },
                ),
                videoData.game != null
                    ? GestureDetector(
                        onTap: () {
                          context.push(
                            APP_PAGE.videoFromGame.toPath,
                            extra: VideoFromGameData(
                              game: videoData.game!,
                              captions: videoData.caption,
                              profileImg: data.photo!,
                            ),
                          );
                        },
                        child: SizedBox(
                          width: Dimens.DIMENS_150,
                          height: Dimens.DIMENS_24,
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  BootstrapIcons.controller,
                                  color: COLOR_white_fff5f5f5,
                                  size: 16,
                                ),
                                SizedBox(
                                  width: Dimens.DIMENS_10,
                                ),
                                Text(
                                  videoData.game!.gameTitle!,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 12,
                                    color: COLOR_white_fff5f5f5,
                                  ),
                                ),
                              ]),
                        ),
                      )
                    : Container()
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
