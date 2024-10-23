import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:personal_project/config/bloc_status_enum.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/data/repository/upload_repository.dart';
import 'package:personal_project/data/repository/vide_from_categories.dart';
import 'package:personal_project/domain/model/category_model.dart';
import 'package:personal_project/domain/model/play_single_data.dart';
import 'package:personal_project/domain/model/video_model.dart';
import 'package:personal_project/domain/reporsitory/user_repository.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/router/app_router.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:personal_project/presentation/shared_components/container_with_max_width.dart';
import 'package:personal_project/presentation/ui/video_from_categories/bloc/vbc_bloc.dart';
import 'package:provider/provider.dart';
import 'package:solar_icons/solar_icons.dart';

class VideoFromCategories extends StatefulWidget {
  final String category;
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
          final VBCREpository repository =
              RepositoryProvider.of<VBCREpository>(context);
          return BackButtonListener(
            onBackButtonPressed: () async {
              AppRouter appRouter =
                  Provider.of<AppRouter>(context, listen: false);
              appRouter.onBackButtonPressed(context);
              return true;
            },
            child: FutureBuilder(
                future:
                    UploadRepository.instance.isCategoryExist(widget.category),
                builder: (context, snap) {
                  bool? isCategoryExist = snap.data;
                  debugPrint('isCategorri exist $isCategoryExist');
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!isCategoryExist!) {
                    return ContainerWidthMaxWidth(
                      maxWidth: 940,
                      child: Scaffold(
                          appBar: AppBar(
                            leading: BackButton(
                              onPressed: () {
                                Provider.of<AppRouter>(context, listen: false)
                                    .onBackButtonPressed(context);
                              },
                            ),
                          ),
                          body: Center(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              width: Dimens.DIMENS_120,
                              height: Dimens.DIMENS_105,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Page not found.",
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: Dimens.DIMENS_6),
                                  const Icon(SolarIconsOutline.sadCircle)
                                ],
                              ),
                            ),
                          )),
                    );
                  }
                  return ContainerWidthMaxWidth(
                    maxWidth: 940,
                    child: Scaffold(
                      appBar: AppBar(
                        leading: BackButton(
                          onPressed: () {
                            AppRouter appRouter =
                                Provider.of<AppRouter>(context, listen: false);
                            appRouter.onBackButtonPressed(context);
                          },
                        ),
                        title: _buildTitle(),
                      ),
                      body: BlocBuilder<VbcBloc, VbcState>(
                        builder: (context, state) {
                          if (state.status == BlocStatus.loading ||
                              repository.controller == null) {
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
                                          String route = GoRouter.of(context)
                                              .routeInformationProvider
                                              .value
                                              .uri
                                              .path;
                                          debugPrint("route $route");
                                          context.go(
                                            '${APP_PAGE.videoItem.toPath}/${item.id}',
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
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      '${item.views.length} ',
                                                      style: TextStyle(
                                                          color:
                                                              COLOR_white_fff5f5f5),
                                                    ),
                                                    Text(
                                                      LocaleKeys.label_views
                                                          .tr(),
                                                      style: TextStyle(
                                                          color:
                                                              COLOR_white_fff5f5f5),
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
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: 9 / 16,
                                crossAxisCount: 3,
                                mainAxisSpacing: 1,
                                crossAxisSpacing: 1,
                              ),
                              pagingController: repository.controller!);
                        },
                      ),
                    ),
                  );
                }),
          );
        }),
      ),
    );
  }

  ListTile _buildTitle() {
    if (widget.category != 'Non Gaming') {
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
            child: FutureBuilder(
                future:
                    UploadRepository.instance.getGameAvatar(widget.category),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container(
                      color: COLOR_black_900,
                    );
                  }
                  return CachedNetworkImage(
                    imageUrl: snapshot.data!,
                    fit: BoxFit.cover,
                  );
                }),
          ),
        ),
        title: Text(
          widget.category,
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
      title: Text(widget.category),
    );
  }
}
