import 'dart:async';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/data/repository/paging_repository.dart';
import 'package:personal_project/domain/model/video_model.dart';
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/shared_components/video_player_item.dart';
import 'package:personal_project/presentation/ui/auth/auth.dart';
import 'package:personal_project/presentation/ui/auth/bloc/auth_bloc.dart';
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
    final AuthRepository authRepository = RepositoryProvider.of<AuthRepository>(context);

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
          child: RepositoryProvider(
            create: (context) => PagingRepository(),
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
              child: BlocBuilder<VideoPaginBloc, VideoPagingState>(
                builder: (context, state) {
                  // No more video still swhowing last loaded video.
                  if (state is PagingControllerState) {
                    return RefreshIndicator(
                      onRefresh: () {
                        final PagingRepository pagingRepository = RepositoryProvider.of<PagingRepository>(context);

                        pagingRepository.clearAllVideo();

                        return Future.sync(
                          () {
                            RepositoryProvider.of<PagingRepository>(context).controller!.refresh();
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
                          child: ListenableBuilder(
                            listenable: IsCanScrollNotification.instance,
                            builder: (context, child) {
                              return NewVideoList();
                              // return _pageView(state, authRepository, context);
                            },
                          ),
                        ),
                      ),
                    );
                  }
                  return Container();
                },
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
  @override
  void initState() {
    final PagingRepository pagingRepository = RepositoryProvider.of<PagingRepository>(context);
    pagingRepository.loadVideos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final PagingRepository pagingRepository = RepositoryProvider.of<PagingRepository>(context);
    return BlocProvider(
      create: (context) => ListVideoPlayerBloc(
        pagingRepository,
      ),
      child: BlocListener<ListVideoPlayerBloc, ListVideoPlayerState>(
        listener: (context, state) {
          debugModePrint('lvpb $state');
        },
        child: BlocBuilder<ListVideoPlayerBloc, ListVideoPlayerState>(
          // buildWhen: (previous, current) {

          // },

          builder: (context, _) {
            return BlocBuilder<VideoPaginBloc, VideoPagingState>(
              builder: (context, state) {
                if (state is PagingControllerState) {
                  final List<Video>? videos = state.videos;
                  if (videos == null) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (videos.isEmpty) {
                    return Center(
                      child: Text(LocaleKeys.message_no_post.tr()),
                    );
                  }
                  return PageView.custom(
                    scrollDirection: Axis.vertical,
                    onPageChanged: (value) {
                      final currentController = state.cachedControllers![value];
                      context.read<VideoPaginBloc>().add(OnNextPage(index: value));

                      if (currentController.value.isInitialized) {
                        context
                            .read<ListVideoPlayerBloc>()
                            .add(PlayVideo(index: value, controller: currentController));
                      } else {
                        context
                            .read<ListVideoPlayerBloc>()
                            .add(InitVideoPlayer(index: value, controller: currentController));
                      }

                      if (value > state.cachedControllers!.length - 2) {
                        context.read<VideoPaginBloc>().add(InitPagingController(from: VideoFrom.forYou));
                      }
                    },
                    childrenDelegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final Video video = videos[index];
                        return VideoPlayerItem(
                          key: ValueKey(video.id),
                          controller: state.cachedControllers![index],
                          index: index,
                          item: video,
                          url: video.videoUrl,
                          auto: true,
                        );
                      },
                      childCount: videos.length, // Example count, adjust as needed
                    ),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
