import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:personal_project/config/bloc_status_enum.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/data/repository/vide_from_categories.dart';
import 'package:personal_project/domain/model/category_model.dart';
import 'package:personal_project/domain/model/play_single_data.dart';
import 'package:personal_project/domain/model/video_model.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:personal_project/presentation/ui/video_from_categories/bloc/vbc_bloc.dart';

class VideoFromCategories extends StatefulWidget {
  final VideoCategory category;
  const VideoFromCategories({
    super.key,
    required this.category,
  });

  @override
  State<VideoFromCategories> createState() => _VideoFromCategoriesState();
}

class _VideoFromCategoriesState extends State<VideoFromCategories> {
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => VBCREpository(),
      child: BlocProvider(
        create: (context) => VbcBloc(
          RepositoryProvider.of<VBCREpository>(
            context,
          ),
        )..add(
            InitVbcEvent(
              category: widget.category,
            ),
          ),
        child: Builder(builder: (context) {
          final VBCREpository repository = RepositoryProvider.of<VBCREpository>(context);
          return Scaffold(
            appBar: AppBar(
              title: _buildTitle(),
            ),
            body: BlocBuilder<VbcBloc, VbcState>(
              builder: (context, state) {
                if (state.status == BlocStatus.loading || repository.controller == null) {
                  return const CircularProgressIndicator();
                }
                return PagedGridView<int, Video>(
                    padding: EdgeInsets.only(top: Dimens.DIMENS_12),
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
                                  CachedNetworkImage(fit: BoxFit.cover, imageUrl: item.thumnail),
                                  Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            '${item.views.length} ',
                                            style: TextStyle(
                                                color: Theme.of(context).colorScheme.primary),
                                          ),
                                          Text(
                                            LocaleKeys.label_views.tr(),
                                            style: TextStyle(
                                                color: Theme.of(context).colorScheme.primary),
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 9 / 16,
                      crossAxisCount: 3,
                      mainAxisSpacing: 1,
                      crossAxisSpacing: 1,
                    ),
                    pagingController: repository.controller!);
              },
            ),
          );
        }),
      ),
    );
  }

  ListTile _buildTitle() {
    if (widget.category.gameFav != null) {
      return ListTile(
        tileColor: Colors.transparent,
        leading: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              8,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              8,
            ),
            child: CachedNetworkImage(
              imageUrl: widget.category.gameFav!.gameImage!,
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(
          widget.category.gameFav!.gameTitle!,
        ),
      );
    }
    return ListTile(
      tileColor: Colors.transparent,
      leading: const SizedBox(
        width: 26,
        height: 26,
        child: Icon(Icons.movie_outlined),
      ),
      title: Text(LocaleKeys.label_entertainment.tr()),
    );
  }
}
