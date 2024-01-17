import 'dart:async';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/data/repository/chat_repository.dart';
import 'package:personal_project/domain/model/chat_data_models.dart';
import 'package:personal_project/domain/model/user.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/router/route_utils.dart';

import 'bloc/search_room_bloc.dart';

class SearchRoomPage extends StatefulWidget {
  const SearchRoomPage({super.key});

  @override
  State<SearchRoomPage> createState() => _SearchRoomPageState();
}

class _SearchRoomPageState extends State<SearchRoomPage> {
  final TextEditingController _textEditingController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    final ChatRepository repo = RepositoryProvider.of<ChatRepository>(context);
    repo.initSearchFollowingSearch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SearchRoomBloc(RepositoryProvider.of<ChatRepository>(context))
            ..add(const InitSearchRoom()),
      child: Builder(builder: (context) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              toolbarHeight: 80,
              title: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  controller: _textEditingController,
                  onChanged: (query) {
                    final searchBloc = BlocProvider.of<SearchRoomBloc>(context);
                    if (_debounce?.isActive ?? false) _debounce?.cancel();
                    _debounce = Timer(const Duration(milliseconds: 500), () {
                      // do something with query
                      searchBloc.add(SearchRoom(query));
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
                      child: const Icon(BootstrapIcons.x),
                    ),
                    suffixIconColor: COLOR_grey,
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ),
            body: BlocBuilder<SearchRoomBloc, SearchRoomState>(
              builder: (context, state) {
                if (state.status == SearchRoomStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.status == SearchRoomStatus.initial ||
                    _textEditingController.text.isEmpty) {
                  return const InitialView();
                }
                if (state.status == SearchRoomStatus.noItemFound) {
                  return Center(
                    child: Text(
                      LocaleKeys.message_not_found
                          .tr(args: [_textEditingController.text]),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: state.results!.length,
                  itemBuilder: (context, index) {
                    final user = state.results![index];
                    return ListTile(
                      tileColor: Colors.transparent,
                      onTap: () async {
                        // debugPrint('photo${result.photo}');
                        // context.push(APP_PAGE.profile.toPath,
                        //     extra: ProfilePayload(
                        //       uid: result.id,
                        //       name: result.name!,
                        //       userName: result.userName!,
                        //       photoURL: result.photo!,
                        //     ));
                        // debugPrint('profile');
                        types.User otherUser = types.User(
                            id: user.id,
                            createdAt: user.createdAt!
                                    .toDate()
                                    .millisecondsSinceEpoch ~/
                                1000,
                            firstName: user.userName);
                        if (!mounted) return;

                        final room = await FirebaseChatCore.instance
                            .createRoom(otherUser);

                        if (!mounted) return;
                        context.push(
                          APP_PAGE.chat.toPath,
                          extra: ChatData(
                            room: room,
                            userName: user.userName!,
                            avatar: user.photo!,
                            name: user.name,
                          ),
                        );
                      },
                      leading: CircleAvatar(
                        backgroundColor: COLOR_grey,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: CachedNetworkImage(
                            imageUrl: user.photo!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      title: Text(user.name!),
                      subtitle: Text(user.userName!),
                    );
                  },
                );
              },
            ),
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}

class InitialView extends StatefulWidget {
  const InitialView({
    super.key,
  });

  @override
  State<InitialView> createState() => _InitialViewState();
}

class _InitialViewState extends State<InitialView> {
  late final PagingController<int, User> _controller;
  final int _pageSize = 4;

  @override
  void initState() {
    initPagingController();

    super.initState();
  }

  void initPagingController() {
    final ChatRepository repository =
        RepositoryProvider.of<ChatRepository>(context);
    repository.clearPreviouseData();
    _controller = PagingController(firstPageKey: 0);
    _controller.addPageRequestListener((pageKey) {
      try {
        _fetchPage(pageKey);
        debugPrint('Fetch data video user:');
      } catch (e) {
        debugPrint('Fetch data video user:$e');
      }
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    final ChatRepository repository =
        RepositoryProvider.of<ChatRepository>(context);
    try {
      List<User> users = [];
      late final List<DocumentSnapshot> newItems;

      newItems = await repository.allSuggestionRoom(_pageSize);

      for (var element in newItems) {
        // listVideo.add(Video.fromSnap(element));
        users.add(User.fromSnap(element));
      }

      final isLastPage = newItems.length < _pageSize;

      if (isLastPage) {
        _controller.appendLastPage(users);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _controller.appendPage(users, nextPageKey);
      }
    } catch (error) {
      _controller.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PagedListView<int, User>(
      pagingController: _controller,
      builderDelegate: PagedChildBuilderDelegate(
        itemBuilder: (context, user, index) {
          return ListTile(
            tileColor: Colors.transparent,
            onTap: () async {
              // debugPrint('photo${result.photo}');
              // context.push(APP_PAGE.profile.toPath,
              //     extra: ProfilePayload(
              //       uid: result.id,
              //       name: result.name!,
              //       userName: result.userName!,
              //       photoURL: result.photo!,
              //     ));
              // debugPrint('profile');
              types.User otherUser = types.User(
                  id: user.id,
                  createdAt:
                      user.createdAt!.toDate().millisecondsSinceEpoch ~/ 1000,
                  firstName: user.userName);
              if (!mounted) return;

              final room =
                  await FirebaseChatCore.instance.createRoom(otherUser);

              if (!mounted) return;
              context.push(
                APP_PAGE.chat.toPath,
                extra: ChatData(
                  room: room,
                  userName: user.userName!,
                  avatar: user.photo!,
                  name: user.name,
                ),
              );
            },
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.tertiary,
              backgroundImage: CachedNetworkImageProvider(
                user.photo!,
              ),
            ),
            title: Text(user.name!),
            subtitle: Text(user.userName!),
          );
        },
      ),
      // child: Container()
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
