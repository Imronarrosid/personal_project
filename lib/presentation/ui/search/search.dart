import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/domain/model/play_single_data.dart';
import 'package:personal_project/domain/model/profile_data_model.dart';
import 'package:personal_project/domain/model/user.dart';
import 'package:personal_project/domain/model/video_model.dart';
import 'package:personal_project/domain/reporsitory/search_repository.dart';
import 'package:personal_project/domain/reporsitory/user_repository.dart';
import 'package:personal_project/domain/reporsitory/video_repository.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:personal_project/presentation/ui/search/bloc/search_bloc.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _textEditingController = TextEditingController();
  Timer? _debounce;
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => SearchRepository(),
      child: BlocProvider(
        create: (context) => SearchBloc(RepositoryProvider.of<SearchRepository>(context)),
        child: Builder(builder: (context) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: FocusScope(
              node: FocusScopeNode(),
              child: Scaffold(
                appBar: AppBar(
                    elevation: 0,
                    toolbarHeight: 80,
                    title: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(10)),
                      child: TextField(
                        focusNode: _focusNode,
                        controller: _textEditingController,
                        onChanged: (query) {
                          final searchBloc = BlocProvider.of<SearchBloc>(context);
                          if (_debounce?.isActive ?? false) _debounce?.cancel();
                          _debounce = Timer(const Duration(milliseconds: 500), () {
                            // do something with query
                            searchBloc.add(SearchEvent(query));
                          });
                        },
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          hintText: LocaleKeys.label_search.tr(),
                          contentPadding: const EdgeInsets.all(5),
                          suffixIcon: GestureDetector(
                              onTap: () {
                                _textEditingController.clear();
                              },
                              child: const Icon(Icons.close)),
                          suffixIconColor: COLOR_grey,
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none, borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    )),
                body: BlocBuilder<SearchBloc, SearchState>(
                  builder: (context, state) {
                    if (state.status == SearchStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.status == SearchStatus.noItemFound) {
                      return Center(
                          child: Text(LocaleKeys.message_not_found
                              .tr(args: [_textEditingController.text])));
                    }
                    if (state.status == SearchStatus.success) {
                      return ListView.builder(
                          itemCount: state.results!.length,
                          itemBuilder: (ctx, index) {
                            final result = state.results![index];
                            return ListTile(
                              tileColor: Colors.transparent,
                              onTap: () {
                                debugPrint('photo${result.photo}');
                                context.push(APP_PAGE.profile.toPath,
                                    extra: ProfilePayload(
                                      uid: result.id,
                                      name: result.name!,
                                      userName: result.userName!,
                                      photoURL: result.photo!,
                                    ));
                                if (FocusManager.instance.primaryFocus != null) {
                                  FocusManager.instance.primaryFocus!.unfocus();
                                }
                                debugPrint('profile');
                              },
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).colorScheme.tertiary,
                                backgroundImage: CachedNetworkImageProvider(
                                  result.photo!,
                                ),
                              ),
                              title: Text(result.name!),
                              subtitle: Text(result.userName!),
                            );
                          });
                    }
                    return InitWidget();
                  },
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class InitWidget extends StatelessWidget {
  const InitWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(Dimens.DIMENS_12),
              child: Text(LocaleKeys.label_suggestion.tr()),
            ),
            FutureBuilder(
              future: UserRepository().getUserSuggestion(6),
              builder: (context, snapshot) {
                List<User>? users = snapshot.data;
                if (!snapshot.hasData) {
                  return Container();
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: users!.length,
                  itemBuilder: (_, index) {
                    final User user = users[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(
                          user.photo!,
                        ),
                      ),
                      title: Text(user.userName!),
                      tileColor: Colors.transparent,
                      onTap: () {
                        context.push(
                          APP_PAGE.profile.toPath,
                          extra: ProfilePayload(
                            uid: user.id,
                            name: user.name!,
                            userName: user.userName!,
                            photoURL: user.photo!,
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
            Padding(
              padding: EdgeInsets.all(Dimens.DIMENS_12),
              child: const Text('Video'),
            ),
            FutureBuilder<List<Video>>(
                future: VideoRepository().getVideoSuggestion(12),
                builder: (_, AsyncSnapshot<List<Video>> snapshot) {
                  final List<Video>? videos = snapshot.data;
                  if (snapshot.hasData) {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: videos!.length,
                      itemBuilder: (_, index) {
                        final Video item = videos[index];
                        return AspectRatio(
                          aspectRatio: 9 / 16,
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
                                      errorWidget: (_, __, ___) => Container(),
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
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 9 / 16,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                      ),
                    );
                  }
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                        ),
                      );
                    },
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 6 / 9,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
