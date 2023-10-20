import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:personal_project/domain/model/video_model.dart';
import 'package:personal_project/domain/reporsitory/video_repository.dart';
import 'package:personal_project/presentation/shared_components/keep_alive_page.dart';
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
      if (videoRepository.allDocs.isEmpty) {
        _pagingController.appendPage(
            videoRepository.currentLoadedVideo, pageKey + newItems.length);
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
      child: RefreshIndicator(
        onRefresh: () => Future.sync(
          () => _pagingController.refresh(),
        ),
        child: PagedPageView<int, Video>(
          pagingController: _pagingController,
          pageController: _controller,
          onPageChanged: (index) => videoRepository.currentPageIndex = index,
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
              noMoreItemsIndicatorBuilder: (_) => Text('Tidak Ada video lagi')),
        ),
      ),
    );
  }

  @override
  void dispose() {
    videoRepository.allDocs.clear();
    videoRepository.currentLoadedVideo
        .addAll(_pagingController.value.itemList!);
    for (var element in _pagingController.value.itemList!) {
      debugPrint(element.caption);
    }
    super.dispose();
  }
}
