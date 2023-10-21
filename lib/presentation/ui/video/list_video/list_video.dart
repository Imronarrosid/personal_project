import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/data/repository/paging_repository.dart';
import 'package:personal_project/data/repository/video_player_repository.dart';
import 'package:personal_project/domain/model/video_model.dart';
import 'package:personal_project/domain/reporsitory/video_repository.dart';
import 'package:personal_project/presentation/shared_components/custom_snackbar.dart';
import 'package:personal_project/presentation/shared_components/keep_alive_page.dart';
import 'package:personal_project/presentation/ui/video/list_video/bloc/paging_bloc.dart';
import 'package:personal_project/presentation/ui/video/list_video/video_item.dart';
import 'package:video_cached_player/video_cached_player.dart';

class ListVideo extends StatefulWidget {
  const ListVideo({super.key});

  @override
  State<ListVideo> createState() => _ListVideoState();
}

class _ListVideoState extends State<ListVideo> {
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    debugPrint('REbuild');

    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: RepositoryProvider(
        create: (context) => PagingRepository(),
        child: BlocProvider(
          create: (context) =>
              VideoPaginBloc(RepositoryProvider.of<PagingRepository>(context))
                ..add(InitPagingController()),
          child: BlocBuilder<VideoPaginBloc, VideoPagingState>(
            builder: (context, state) {
              // No more video still swhowing last loaded video.
              if (state is PagingControllerState) {
                return RefreshIndicator(
                  onRefresh: () {
                    final PagingRepository pagingRepository =
                        RepositoryProvider.of<PagingRepository>(context);

                    // Clear current loaded video on refresh
                    pagingRepository.currentLoadedVideo.clear();

                    //Store current loaded video to paging repository.
                    for (var video in pagingRepository.controller!.itemList!) {
                      pagingRepository.currentLoadedVideo.add(video);
                    }

                    return Future.sync(
                      () {
                        RepositoryProvider.of<PagingRepository>(context)
                            .controller!
                            .refresh();
                      },
                    );
                  },
                  child: PagedPageView<int, Video>(
                    pagingController: state.controller!,
                    pageController: _controller,
                    scrollDirection: Axis.vertical,
                    physics: const BouncingScrollPhysics(),
                    builderDelegate: PagedChildBuilderDelegate<Video>(
                        itemBuilder: (context, item, index) {
                          return RepositoryProvider(
                            create: (context) => VideoPlayerRepository(),
                            child: VideoItem(
                              videoData: item,
                            ),
                          );
                        },
                        newPageProgressIndicatorBuilder: (_) =>
                            CircularProgressIndicator(),
                        newPageErrorIndicatorBuilder: (_) => Text('eror'),
                        noMoreItemsIndicatorBuilder: (_) =>
                            Text('Tidak Ada video lagi')),
                  ),
                );
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
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
