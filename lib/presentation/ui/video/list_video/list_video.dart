import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:personal_project/domain/model/video_model.dart';
import 'package:personal_project/domain/reporsitory/video_repository.dart';
import 'package:personal_project/presentation/ui/video/list_video/video_item.dart';

class ListVideo extends StatefulWidget {
  const ListVideo({super.key});

  @override
  State<ListVideo> createState() => _ListVideoState();
}

class _ListVideoState extends State<ListVideo> {
  static const _pageSize = 20;

  final PagingController<int, Video> _pagingController =
      PagingController(firstPageKey: 0);

  late VideoRepository videoRepository;

  final PageController _controller = PageController();
  final double snapThreshold = 100.0;
  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      videoRepository = RepositoryProvider.of<VideoRepository>(context);
      _fetchPage(pageKey);
      
    });
    
    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      List<Video> listVideo = [];
      final newItems = await videoRepository.getListVideo(limit: _pageSize);
      final isLastPage = newItems.length < _pageSize;

      debugPrint(newItems.toString());

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
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: PagedPageView<int, Video>(
        pagingController: _pagingController,
        pageController: _controller,
        scrollDirection: Axis.vertical,
        builderDelegate: PagedChildBuilderDelegate<Video>(
          itemBuilder: (context, item, index) => VideoItem(
            videoData: item,
          ),
        ),
      ),
    );
  }
}
