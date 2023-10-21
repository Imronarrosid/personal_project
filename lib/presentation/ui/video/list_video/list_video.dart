import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/data/repository/paging_repository.dart';
import 'package:personal_project/domain/model/video_model.dart';
import 'package:personal_project/domain/reporsitory/video_repository.dart';
import 'package:personal_project/presentation/shared_components/custom_snackbar.dart';
import 'package:personal_project/presentation/shared_components/keep_alive_page.dart';
import 'package:personal_project/presentation/ui/video/list_video/bloc/paging_bloc.dart';
import 'package:personal_project/presentation/ui/video/list_video/video_item.dart';

class ListVideo extends StatefulWidget {
  const ListVideo({super.key});

  @override
  State<ListVideo> createState() => _ListVideoState();
}

class _ListVideoState extends State<ListVideo> {
  static const _pageSize = 1;
  int currentIndex = 0;
  late final PagingController<int, Video> _pagingController;

  late VideoRepository videoRepository;

  final PageController _controller = PageController();
  final double snapThreshold = 100.0;

  // @override
  // void initState() {
  //   // _pagingController.addPageRequestListener((pageKey) {
  //   //   videoRepository = RepositoryProvider.of<VideoRepository>(context);
  //   //   try {
  //   //     _fetchPage(pageKey);
  //   //   } catch (e) {
  //   //     debugPrint('Fetch data:$e');
  //   //   }
  //   // });
  //   debugPrint('Fetch data:');

  //   super.initState();
  // }

  Future<void> _fetchPage(int pageKey) async {
    try {
      List<Video> listVideo = [];
      final newItems = await videoRepository.getListVideo(limit: _pageSize);
      final isLastPage = newItems.length < _pageSize;

      debugPrint('new items' + newItems.toString());

      for (var element in newItems) {
        listVideo.add(Video.fromSnap(element));
      }
      if (isLastPage) {
        _pagingController.appendLastPage(listVideo);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(listVideo, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void initState() {
    videoRepository = RepositoryProvider.of<VideoRepository>(context);
    _pagingController =
        PagingController(firstPageKey: videoRepository.currentPageIndex);
    _pagingController.addPageRequestListener((pageKey) {
      debugPrint(videoRepository.currentPageIndex.toString());
      try {
        _fetchPage(pageKey);
      } catch (e) {
        debugPrint('Fetch data:$e');
      }
    });

    super.initState();
  }

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
                    onPageChanged: (index) =>
                        videoRepository.currentPageIndex = index,
                    scrollDirection: Axis.vertical,
                    physics: const BouncingScrollPhysics(),
                    builderDelegate: PagedChildBuilderDelegate<Video>(
                        itemBuilder: (context, item, index) => KeepAlivePage(
                              child: VideoItem(
                                videoData: item,
                              ),
                            ),
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
    videoRepository.allDocs.clear();
    // videoRepository.currentLoadedVideo
    //     .addAll(_pagingController.value.itemList!);
    // for (var element in _pagingController.value.itemList!) {
    //   debugPrint(element.caption);
    // }
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
