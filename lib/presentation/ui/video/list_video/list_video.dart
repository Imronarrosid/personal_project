import 'dart:async';

import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/data/repository/paging_repository.dart';
import 'package:personal_project/domain/model/video_model.dart';
import 'package:personal_project/domain/reporsitory/video_repository.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/shared_components/flutter_toast_func.dart';
import 'package:personal_project/presentation/shared_components/video_player_item.dart';
import 'package:personal_project/presentation/ui/home/cubit/home_cubit.dart';
import 'package:personal_project/presentation/ui/video/list_video/bloc/list_video_player_bloc.dart';
import 'package:personal_project/presentation/ui/video/list_video/bloc/paging_bloc.dart';
import 'package:personal_project/presentation/ui/video/list_video/is_can_scroll_notification.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../utils/debug_mode_print.dart';

class ListVideo extends StatefulWidget {
  final VideoFrom from;
  const ListVideo({
    super.key,
    required this.from,
  });

  @override
  State<ListVideo> createState() => _ListVideoState();
}

class _ListVideoState extends State<ListVideo> {
  final PageController _controller = PageController();
  int resetTrigger = 0;
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    debugModePrint('REbuild');

    return BlocListener<HomeCubit, HomeState>(
      listenWhen: (previous, current) => true,
      listener: (context, state) {
        if (state.isTriggerReset && (_controller.page ?? 0.0) > 0.0) {
          debugModePrint('1234');
          _controller.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.bounceIn);
        }
      },
      child: VisibilityDetector(
        key: const ValueKey('listvideo'),
        onVisibilityChanged: (info) {
          if (info.visibleFraction > 0.5) {
            _focusNode.requestFocus();
          }
        },
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: BlocProvider(
            create: (context) {
              if (widget.from == VideoFrom.following) {
                return VideoPaginBloc(RepositoryProvider.of<PagingRepository>(context))
                  ..add(
                    const InitPagingController(from: VideoFrom.following),
                  );
              } else {
                return VideoPaginBloc(RepositoryProvider.of<PagingRepository>(context))
                  ..add(
                    const InitPagingController(from: VideoFrom.forYou),
                  );
              }
            },
            child: BlocProvider(
              create: (context) => ListVideoPlayerBloc(
                RepositoryProvider.of<PagingRepository>(context),
              ),
              child: RefreshIndicator(
                onRefresh: () {
                  final PagingRepository pagingRepository = RepositoryProvider.of<PagingRepository>(context);

                  pagingRepository.clearAllVideo();

                  return Future.sync(
                    () {
                      // RepositoryProvider.of<PagingRepository>(context).controller!.refresh();
                    },
                  );
                },
                child: BackButtonListener(
                  onBackButtonPressed: () async {
                    _controller.animateToPage(0,
                        duration: const Duration(milliseconds: 300), curve: Curves.bounceIn);
                    return true;
                  },
                  child: KeyboardListener(
                      focusNode: _focusNode,
                      autofocus: true,
                      onKeyEvent: (KeyEvent keyEvent) {
                        debugModePrint('index ${_controller.page}');
                        if (keyEvent.logicalKey == LogicalKeyboardKey.arrowDown) {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInCubic,
                          );
                        } else if (keyEvent.logicalKey == LogicalKeyboardKey.arrowUp) {
                          if (_controller.page!.toInt() > 0) {
                            _controller.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInCubic,
                            );
                          }
                        }
                      },
                      child: NewVideoList()),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // PagedPageView<int, Video> _pageView(
  //     PagingControllerState state, AuthRepository authRepository, BuildContext context) {
  //   return PagedPageView<int, Video>(
  //     pagingController: state.controller!,
  //     pageController: _controller,
  //     scrollDirection: Axis.vertical,
  //     physics: IsCanScrollNotification.instance.value
  //         ? const AlwaysScrollableScrollPhysics()
  //         : const NeverScrollableScrollPhysics(),
  //     builderDelegate: PagedChildBuilderDelegate<Video>(
  //         itemBuilder: (context, item, index) {
  //           return VideoPlayerItem(
  //             index: index,
  //             item: item,
  //             url: item.videoUrl,
  //             auto: true,
  //           );
  //         },
  //         noItemsFoundIndicatorBuilder: (_) {
  //           return BlocBuilder<AuthBloc, AuthState>(
  //             builder: (context, state) {
  //               if (widget.from == VideoFrom.following && authRepository.currentUser != null) {
  //                 return Container(
  //                   width: 400,
  //                   alignment: Alignment.center,
  //                   child: Text(LocaleKeys.label_no_video_from_following.tr()),
  //                 );
  //               } else if (widget.from == VideoFrom.following && authRepository.currentUser == null) {
  //                 return Column(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     SizedBox(
  //                       width: Dimens.DIMENS_250,
  //                       child: Text(
  //                         LocaleKeys.message_log_in_and_follow.tr(),
  //                         textAlign: TextAlign.center,
  //                       ),
  //                     ),
  //                     SizedBox(
  //                       height: Dimens.DIMENS_16,
  //                     ),
  //                     ElevatedButton(
  //                       onPressed: () {
  //                         showAuthBottomSheetFunc(context);
  //                       },
  //                       child: Text(
  //                         LocaleKeys.label_login.tr(),
  //                       ),
  //                     ),
  //                   ],
  //                 );
  //               }

  //               return Center(
  //                 child: Text(
  //                   LocaleKeys.message_no_post.tr(),
  //                 ),
  //               );
  //             },
  //           );
  //         },
  //         newPageProgressIndicatorBuilder: (_) => const Center(child: CircularProgressIndicator()),
  //         newPageErrorIndicatorBuilder: (_) => Text('eror ${state.controller?.error.toString()}'),
  //         firstPageErrorIndicatorBuilder: (_) {
  //           return Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               Text(state.controller!.error.toString()),
  //               IconButton(
  //                   onPressed: () {
  //                     final PagingRepository pagingRepository = RepositoryProvider.of<PagingRepository>(context);

  //                     pagingRepository.refreshPaging();
  //                   },
  //                   icon: const Icon(BootstrapIcons.arrow_clockwise))
  //             ],
  //           );
  //         },
  //         noMoreItemsIndicatorBuilder: (_) => Center(
  //                 child: Text(
  //               LocaleKeys.message_no_new_video.tr(),
  //               style: TextStyle(color: COLOR_white_fff5f5f5),
  //             ))),
  //   );
  // }
}

void showNoMorevideoSnackbar(BuildContext context) {
  final snackBar = SnackBar(
    content: const Text(
      'Tidak ada video baru',
      textAlign: TextAlign.center,
    ),
    backgroundColor: COLOR_black_ff121212.withOpacity(0.4),
    elevation: 0,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

class NewVideoList extends StatefulWidget {
  const NewVideoList({super.key});

  @override
  State<NewVideoList> createState() => _NewVideoListState();
}

class _NewVideoListState extends State<NewVideoList> {
  PageController controller = PageController();

  int previousPageIndex = 0;
  int? viewedIndex;

  bool nomoreItemToasViisible = false;
  @override
  void initState() {
    final PagingRepository pagingRepository = RepositoryProvider.of<PagingRepository>(context);
    final firstVideoPlayerController = pagingRepository.getControllerAtIndex(0);
    if (viewedIndex == null && firstVideoPlayerController.value.isInitialized) {
      context.read<ListVideoPlayerBloc>().add(
            PlayVideo(
              index: 0,
              controller: firstVideoPlayerController,
            ),
          );

      addVideoListener(
        activeIndex: 0,
        videoId: pagingRepository.videos.first.id!,
        currentController: firstVideoPlayerController,
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final PagingRepository pagingRepository = RepositoryProvider.of<PagingRepository>(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<ListVideoPlayerBloc, ListVideoPlayerState>(
          listener: (context, state) {
            debugModePrint('lvpb //');
          },
        ),
      ],
      child: BlocBuilder<ListVideoPlayerBloc, ListVideoPlayerState>(
        // buildWhen: (previous, current) {

        // },

        builder: (context, _) {
          return BlocBuilder<VideoPaginBloc, VideoPagingState>(
            builder: (context, state) {
              if (state is PagingControllerState ||
                  state is PagingInitial ||
                  state is PagingLoadingSate ||
                  state is NoMoreItem) {
                final List<Video> videos = pagingRepository.videos;
                final cachedControllers = pagingRepository.videoPlayerControllers;
                if (videos.isEmpty) {
                  return Center(
                    child: Text(LocaleKeys.message_no_post.tr()),
                  );
                }
                return NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (overscroll) {
                    if (true) {
                      if (previousPageIndex == pagingRepository.videoPlayerControllers.length - 1 &&
                          state is NoMoreItem) {
                        if (!nomoreItemToasViisible) {
                          nomoreItemToasViisible = true;
                          showFlutterToast(msg: LocaleKeys.message_no_new_video.tr());

                          Future.delayed(const Duration(milliseconds: 1200), () {
                            nomoreItemToasViisible = false;
                          });
                        }
                      } else if (previousPageIndex == pagingRepository.videoPlayerControllers.length - 1 &&
                          state is PagingLoadingSate) {
                        if (!nomoreItemToasViisible) {
                          nomoreItemToasViisible = true;
                          showFlutterToast(msg: 'loading more video');

                          Future.delayed(const Duration(milliseconds: 1200), () {
                            nomoreItemToasViisible = false;
                          });
                        }
                      }
                    }

                    return false;
                  },
                  child: ListenableBuilder(
                      listenable: IsCanScrollNotification.instance,
                      builder: (context, child) {
                        return PageView.custom(
                          controller: controller,
                          physics: IsCanScrollNotification.instance.value
                              ? const AlwaysScrollableScrollPhysics()
                              : const NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          onPageChanged: (activeIndex) {
                            if (activeIndex != cachedControllers.length - 1) {
                              nomoreItemToasViisible = false;
                            }
                            debugModePrint('activepage ');
                            CachedVideoPlayerPlusController currentController =
                                pagingRepository.getControllerAtIndex(activeIndex);

                            debugModePrint('activepage  isInitialized ${currentController.value.isInitialized}');
                            if (previousPageIndex < activeIndex) {
                              context.read<VideoPaginBloc>().add(OnNextPage(index: activeIndex));
                              context.read<ListVideoPlayerBloc>().add(DisposeVideoController(
                                  controller: cachedControllers[activeIndex - 1], index: activeIndex - 1));
                            } else if (previousPageIndex > activeIndex &&
                                activeIndex < cachedControllers.length - 1) {
                              context.read<ListVideoPlayerBloc>().add(DisposeVideoController(
                                  controller: cachedControllers[activeIndex + 1], index: activeIndex + 1));
                              context.read<VideoPaginBloc>().add(OnNextPage(index: activeIndex));
                            } else if (activeIndex == pagingRepository.videoPlayerControllers.length - 1) {
                              // context.read<ListVideoPlayerBloc>().add(DisposeVideoController(
                              //     controller: cachedControllers[activeIndex - 1], index: activeIndex - 1));
                            }
                            if (currentController.value.isInitialized) {
                              context
                                  .read<ListVideoPlayerBloc>()
                                  .add(PlayVideo(index: activeIndex, controller: currentController));
                              debugModePrint('activepage play ');
                              addVideoListener(
                                activeIndex: activeIndex,
                                videoId: videos[activeIndex].id!,
                                currentController: currentController,
                              );
                            } else {
                              context
                                  .read<ListVideoPlayerBloc>()
                                  .add(InitVideoPlayer(index: activeIndex, controller: currentController));
                              addVideoListener(
                                activeIndex: activeIndex,
                                videoId: videos[activeIndex].id!,
                                currentController: currentController,
                              );
                            }

                            if (activeIndex > cachedControllers.length - 2) {
                              context.read<VideoPaginBloc>().add(LoadMoreVideo(from: VideoFrom.forYou));
                            }

                            previousPageIndex = activeIndex;
                          },
                          childrenDelegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final Video video = videos[index];
                              return VideoPlayerItem(
                                key: ValueKey(video.id),
                                controller: pagingRepository.getControllerAtIndex(index),
                                index: index,
                                item: video,
                                url: video.videoUrl,
                                auto: true,
                              );
                            },
                            childCount: cachedControllers.length, // Example count, adjust as needed
                          ),
                        );
                      }),
                );
              }

              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          );
        },
      ),
    );
  }

  void addVideoListener(
      {required int activeIndex,
      required String videoId,
      required CachedVideoPlayerPlusController currentController}) {
    currentController.addListener(
      () {
        int duratio = currentController.value.position.inMicroseconds;
        double minDur = 3 / 10 * duratio;

        if (duratio > minDur.toInt() && (viewedIndex == null || viewedIndex != activeIndex)) {
          RepositoryProvider.of<VideoRepository>(context).addViewsCount(videoId);
          debugModePrint('add views activepage $activeIndex');
          viewedIndex = activeIndex;
          // currentController.removeListener(() {});
        }
        if (currentController.value.isBuffering) {
          //TODO:
          //showbuffering indicator
        }
      },
    );
  }
}
