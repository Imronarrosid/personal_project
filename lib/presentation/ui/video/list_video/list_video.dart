import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/data/repository/paging_repository.dart';
import 'package:personal_project/domain/model/video_model.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/shared_components/video_player_item.dart';
import 'package:personal_project/presentation/ui/video/list_video/bloc/paging_bloc.dart';

class ListVideo extends StatelessWidget {
  ListVideo({super.key});

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

                    pagingRepository.clearAllVideo();

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
                          return VideoPlayerItem(
                            item: item,
                            url: item.videoUrl,
                            auto: true,
                          );
                        },
                        noItemsFoundIndicatorBuilder: (_) => Center(
                            child: Text(LocaleKeys.message_no_post.tr())),
                        newPageProgressIndicatorBuilder: (_) =>
                            const Center(child: CircularProgressIndicator()),
                        newPageErrorIndicatorBuilder: (_) => const Text('eror'),
                        noMoreItemsIndicatorBuilder: (_) => Center(
                                child: Text(
                              'Tidak Ada video baru lagi',
                              style: TextStyle(color: COLOR_white_fff5f5f5),
                            ))),
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
