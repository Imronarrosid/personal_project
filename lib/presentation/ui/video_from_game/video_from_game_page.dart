import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/data/repository/video_from_game_repostitory.dart';
import 'package:personal_project/domain/model/play_single_data.dart';
import 'package:personal_project/domain/model/video_from_game_data_model.dart';
import 'package:personal_project/domain/model/video_model.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:personal_project/presentation/ui/video_from_game/bloc/video_from_game_bloc.dart';

class VideoFromGamePage extends StatelessWidget {
  final VideoFromGameData data;
  const VideoFromGamePage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => VideoFromGameRepository(),
      child: BlocProvider(
        create: (context) => VideoFromGameBloc(
            RepositoryProvider.of<VideoFromGameRepository>(context))
          ..add(InitVideoFromGame(game: data.game)),
        child: Builder(builder: (context) {
          return Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (_, innerBoxIsScrolled) => [
                SliverAppBar(
                  floating: true,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                ),
                SliverToBoxAdapter(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: Dimens.DIMENS_12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: data.game.gameImage!,
                            width: Dimens.DIMENS_80,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          tileColor: Colors.transparent,
                          title: const Text('Game'),
                          subtitle: Text(
                            data.game.gameTitle!,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverAppBar(
                  toolbarHeight: 0,
                  pinned: true,
                  bottom: PreferredSize(
                    preferredSize: Size(MediaQuery.of(context).size.width, 60),
                    child: Padding(
                      padding: EdgeInsets.all(Dimens.DIMENS_12),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: Dimens.DIMENS_15,
                                vertical: Dimens.DIMENS_6),
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.tertiary,
                                borderRadius: BorderRadius.circular(10)),
                            child: Text(
                                '${LocaleKeys.label_video_about.tr()} ${data.game.gameTitle}')),
                      ),
                    ),
                  ),
                ),
              ],
              body: BlocBuilder<VideoFromGameBloc, VideoFromGameState>(
                builder: (context, state) {
                  if (state.status == VideoFromGameStatus.initialized) {
                    return PagedGridView<int, Video>(
                        padding: EdgeInsets.zero,
                        pagingController: state.controller!,
                        builderDelegate: PagedChildBuilderDelegate(
                            itemBuilder: (_, item, index) {
                          return AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Container(
                                  color: COLOR_black,
                                  child: GestureDetector(
                                    onTap: () {
                                      context.push(
                                        APP_PAGE.videoItem.toPath,
                                        extra: PlaySingleData(
                                          index: index,
                                          videoData: item,
                                        ),
                                      );
                                    },
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        CachedNetworkImage(
                                            fit: BoxFit.cover,
                                            imageUrl: item.thumnail),
                                        Align(
                                          alignment: Alignment.bottomLeft,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: [
                                                Text(
                                                  '${item.views.length} ',
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary),
                                                ),
                                                Text(
                                                  LocaleKeys.label_views.tr(),
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary),
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  )));
                        }),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          childAspectRatio: 9 / 16,
                          crossAxisCount: 3,
                          mainAxisSpacing: 1,
                          crossAxisSpacing: 1,
                        ));
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          );
        }),
      ),
    );
  }
}
