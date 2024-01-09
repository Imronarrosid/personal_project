import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart' as localization;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:personal_project/config/bloc_status_enum.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/data/repository/user_video_paging_repository.dart';
import 'package:personal_project/domain/model/chat_data_models.dart';
import 'package:personal_project/domain/model/following_n_followers_data_model.dart';
import 'package:personal_project/domain/model/game_fav_modal.dart';
import 'package:personal_project/domain/model/profile_data_model.dart';
import 'package:personal_project/domain/model/user.dart';
import 'package:personal_project/domain/model/video_model.dart';
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';
import 'package:personal_project/domain/reporsitory/user_repository.dart';
import 'package:personal_project/domain/reporsitory/video_repository.dart';
import 'package:personal_project/domain/services/firebase/firebase_service.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:personal_project/presentation/shared_components/keep_alive_page.dart';
import 'package:personal_project/presentation/shared_components/not_authenticated_page.dart';
import 'package:personal_project/presentation/ui/add_details/bloc/upload_bloc.dart';
import 'package:personal_project/presentation/ui/auth/bloc/auth_bloc.dart';
import 'package:personal_project/presentation/ui/edit_profile/cubit/edit_bio_cubit.dart';
import 'package:personal_project/presentation/ui/edit_profile/cubit/edit_name_cubit.dart';
import 'package:personal_project/presentation/ui/edit_profile/cubit/edit_user_name_cubit.dart';
import 'package:personal_project/presentation/ui/edit_profile/cubit/game_fav_cubit.dart';
import 'package:personal_project/presentation/ui/profile/bloc/user_video_paging_bloc.dart';
import 'package:personal_project/presentation/ui/profile/cubit/follow_cubit.dart';
import 'package:personal_project/presentation/ui/profile/cubit/profile_cubit.dart';
import 'package:personal_project/presentation/ui/profile/cubit/refresh_profile_cubit.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class ProfilePage extends StatefulWidget {
  /// [payload] need to required if
  ///
  /// to serve other user info
  ///
  /// other user mean is [ProfilePage] that not in [HomePage]
  final ProfilePayload? payload;
  final bool? isForOtherUser;
  const ProfilePage({super.key, this.payload, this.isForOtherUser = false});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<GameFav> gameFavs = [];
  String userBio = '';
  bool isToEditProfile = false;
  bool isToMenu = true;

  String? ui, title, userName, photoURL;

  @override
  void initState() {
    if (widget.payload != null) {
      title = widget.payload!.name;
      userName = '@${widget.payload!.userName}';
      photoURL = widget.payload!.photoURL;
      debugPrint('photo $photoURL');
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('refresh');
    Size size = MediaQuery.of(context).size;
    final authRepository = RepositoryProvider.of<AuthRepository>(context);
    final UserRepository userRepository =
        RepositoryProvider.of<UserRepository>(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ProfileCubit(),
        ),
        BlocProvider(
          create: (context) => FollowCubit(userRepository),
        ),
        BlocProvider(
          create: (context) => RefreshProfileCubit(),
        )
      ],
      child: Builder(builder: (context) {
        return BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            // //execute when first time login
            // if (state.status == AuthStatus.authenticated &&
            //     !widget.isForOtherUser!) {
            //   final UserRepository repository =
            //       RepositoryProvider.of<UserRepository>(context);

            //   final authRepository =
            //       RepositoryProvider.of<AuthRepository>(context);
            //   if (widget.payload == null) {
            //     debugPrint('uidcu ${authRepository.currentUser!.uid}');
            //     futureUserData1 =
            //         repository.getUserData1(authRepository.currentUser!.uid);
            //   }
            // }
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              scrolledUnderElevation: 0,
              elevation: 0,
              title: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if ((state.status == AuthStatus.authenticated &&
                      !widget.isForOtherUser!)) {
                    title = state.user!.name;
                  } else if ((state.status == AuthStatus.notAuthenticated &&
                          !widget.isForOtherUser!) ||
                      (state.status == AuthStatus.loading &&
                          !widget.isForOtherUser!)) {
                    title = LocaleKeys.title_profile.tr();
                  } else if (widget.isForOtherUser!) {
                    title = widget.payload!.name;
                  }
                  return _buildTitle(title);
                },
              ),
              actions: <Widget>[
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return _isShowMenuBtn(authRepository, state)
                        ? IconButton(
                            onPressed: () async {
                              if (isToMenu) {
                                isToMenu = false;
                                await context.push(
                                  APP_PAGE.menu.toPath,
                                );
                              }
                              isToMenu = true;
                            },
                            icon: Icon(MdiIcons.menu))
                        : Container();
                  },
                )
              ],
            ),
            body: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                debugPrint(authState.toString());

                if (_isAuthenticatedButStillLoadingData(
                    authRepository, authState)) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (!_isAuthenticated(authState) && widget.payload == null) {
                  return const NotAuthenticatedPage();
                }

                return _profileBody(size, context, authState, authRepository);

                // if (_isAuthenticated(authState)) {
                //   return FutureBuilder(
                //       future: userRepository
                //           .getUserData(widget.uid ?? authState.uid!),
                //       builder: (context, snapshot) {
                //         var data = snapshot.data;
                //         if (!snapshot.hasData) {
                //           return Scaffold(
                //             backgroundColor: COLOR_white_fff5f5f5,
                //             appBar: AppBar(
                //               backgroundColor: Colors.transparent,
                //               foregroundColor: COLOR_black_ff121212,
                //               elevation: 0,
                //               actions: [
                //                 (_isLogedUser(authState))
                //                     ? IconButton(
                //                         onPressed: () async {
                //                           if (isToMenu) {
                //                             isToMenu = false;
                //                             await context.push(
                //                               APP_PAGE.menu.toPath,
                //                             );
                //                           }
                //                           isToMenu = true;
                //                         },
                //                         icon: Icon(MdiIcons.menu))
                //                     : Container()
                //               ],
                //             ),
                //             body: Container(
                //                 width: size.width,
                //                 height: size.height,
                //                 color: COLOR_white_fff5f5f5,
                //                 alignment: Alignment.center,
                //                 child: const CircularProgressIndicator()),
                //           );
                //         }

                //         return Scaffold(
                //           backgroundColor: COLOR_white_fff5f5f5,
                //           appBar: AppBar(
                //             title: BlocBuilder<EditNameCubit, EditNameState>(
                //               builder: (context, state) {
                //                 if (state.status ==
                //                         EditNameStatus.nameEditSuccess &&
                //                     data!.uid ==
                //                         authRepository.currentUser!.uid) {
                //                   return Text(state.name!);
                //                 }
                //                 return Text(data!.name);
                //               },
                //             ),
                //             actions: [
                //               (_isLogedUser(authState))
                //                   ? IconButton(
                //                       onPressed: () async {
                //                         if (isToMenu) {
                //                           isToMenu = false;
                //                           await context.push(APP_PAGE.menu.toPath,
                //                               extra: data!.uid);
                //                         }
                //                         isToMenu = true;
                //                       },
                //                       icon: Icon(MdiIcons.menu))
                //                   : Container()
                //             ],
                //             backgroundColor: Colors.transparent,
                //             elevation: 0,
                //             foregroundColor: Colors.black,
                //           ),
                //           body: _profileBody(
                //               size, context, data, authState, authRepository),
                //         );
                //       });
                // }
                // return Scaffold(
                //     backgroundColor: COLOR_white_fff5f5f5,
                //     appBar: AppBar(
                //       backgroundColor: COLOR_white_fff5f5f5,
                //       foregroundColor: COLOR_black_ff121212,
                //       elevation: 0,
                //       title: Text(LocaleKeys.title_profile.tr()),
                //     ),
                //     body: const NotAuthenticatedPage());
              },
            ),
          ),
        );
      }),
    );
  }

  bool _isAuthenticatedButStillLoadingData(
      AuthRepository authRepository, AuthState authState) {
    return authRepository.currentUser != null &&
        widget.payload == null &&
        authState.user == null;
  }

  BlocBuilder<EditNameCubit, EditNameState> _buildTitle(String? title) {
    return BlocBuilder<EditNameCubit, EditNameState>(
      builder: (context, state) {
        if (state.status == EditNameStatus.nameEditSuccess &&
            widget.payload == null) {
          title = state.name;
        }
        return Text(
          title ?? LocaleKeys.title_profile.tr(),
          style: Theme.of(context).textTheme.titleLarge,
        );
      },
    );
  }

  SizedBox _profileBody(Size size, BuildContext context, AuthState authState,
      AuthRepository authRepository) {
    final ThemeData theme = Theme.of(context);
    final userRepository = RepositoryProvider.of<UserRepository>(context);
    return SizedBox(
        width: size.width,
        child: DefaultTabController(
          length: 2,
          child: RefreshIndicator(
            notificationPredicate: (notification) {
              // with NestedScrollView local(depth == 2) OverscrollNotification are not sent
              if (notification is OverscrollNotification || Platform.isIOS) {
                return notification.depth == 2;
              }
              return notification.depth == 0;
            },
            onRefresh: () => Future.sync(() {
              setState(() {});
              BlocProvider.of<RefreshProfileCubit>(context).refreshProfile();
            }),
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          topSectionView(authState),
                          _buildUserName(),
                          SizedBox(
                            height: Dimens.DIMENS_8,
                          ),
                          bioSectionView(
                              uid: widget.payload?.uid ?? authState.user!.id),
                          gameFavView(
                              widget.payload?.uid ?? authState.user!.id),
                          SizedBox(
                            height: Dimens.DIMENS_8,
                          ),
                          if ((widget.payload?.uid ?? authState.user!.id) ==
                              authRepository.currentUser?.uid)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: Dimens.DIMENS_12,
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Material(
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(5),
                                      onTap: () => toEditProfile(context),
                                      child: Container(
                                        height: Dimens.DIMENS_34,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Text(
                                          LocaleKeys.label_edit_profile.tr(),
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: Dimens.DIMENS_6,
                                ),
                                Expanded(
                                  child: Container(
                                      height: Dimens.DIMENS_34,
                                      decoration: BoxDecoration(
                                          color: theme.colorScheme.tertiary,
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: Icon(MdiIcons.accountPlus)),
                                ),
                                SizedBox(
                                  width: Dimens.DIMENS_12,
                                ),
                              ],
                            )
                          else
                            Row(
                              children: [
                                SizedBox(
                                  width: Dimens.DIMENS_12,
                                ),
                                FutureBuilder<bool>(
                                    future: userRepository
                                        .isFollowing(widget.payload!.uid),
                                    builder: (context,
                                        AsyncSnapshot<bool> snapshot) {
                                      bool? isFollowing = snapshot.data;
                                      if (!snapshot.hasData) {
                                        return Expanded(
                                          child: Container(
                                            height: Dimens.DIMENS_34,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: COLOR_black_ff121212
                                                  .withOpacity(0.5),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: SizedBox(
                                                width: Dimens.DIMENS_18,
                                                height: Dimens.DIMENS_18,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: COLOR_white_fff5f5f5,
                                                )),
                                          ),
                                        );
                                      }

                                      return BlocBuilder<FollowCubit,
                                          FollowState>(
                                        builder: (context, state) {
                                          debugPrint('follow state $state');
                                          if (state.status ==
                                              BlocStatus.following) {
                                            isFollowing = true;
                                          } else if (state.status ==
                                              BlocStatus.notFollowing) {
                                            isFollowing = false;
                                          } else {
                                            isFollowing = isFollowing;
                                          }

                                          return Expanded(
                                            child: Material(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              color: isFollowing!
                                                  ? theme.colorScheme.tertiary
                                                  : theme
                                                      .colorScheme.onTertiary,
                                              child: InkWell(
                                                onTap: () {
                                                  if (isFollowing!) {
                                                    showDialog(
                                                        context: context,
                                                        builder: (_) {
                                                          return AlertDialog(
                                                            title: Text(LocaleKeys
                                                                .message_unfollow
                                                                .tr()),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () {
                                                                  context.pop();
                                                                },
                                                                child: Text(
                                                                    LocaleKeys
                                                                        .label_cancel
                                                                        .tr()),
                                                              ),
                                                              TextButton(
                                                                onPressed: () {
                                                                  BlocProvider.of<FollowCubit>(context).followButtonHandle(
                                                                      currentUserUid: authRepository
                                                                          .currentUser!
                                                                          .uid,
                                                                      uid: widget
                                                                              .payload
                                                                              ?.uid ??
                                                                          authState
                                                                              .user!
                                                                              .id,
                                                                      stateFromDatabase:
                                                                          isFollowing!);
                                                                  context.pop();
                                                                },
                                                                child: Text(
                                                                    LocaleKeys
                                                                        .label_oke
                                                                        .tr()),
                                                              )
                                                            ],
                                                          );
                                                        });
                                                  } else {
                                                    BlocProvider.of<
                                                                FollowCubit>(
                                                            context)
                                                        .followButtonHandle(
                                                            currentUserUid:
                                                                authRepository
                                                                    .currentUser!
                                                                    .uid,
                                                            uid: widget
                                                                .payload!.uid,
                                                            stateFromDatabase:
                                                                isFollowing!);
                                                  }
                                                },
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                child: Container(
                                                  height: Dimens.DIMENS_34,
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                      color: Colors.transparent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  child: Text(
                                                    isFollowing!
                                                        ? LocaleKeys
                                                            .label_following
                                                            .tr()
                                                        : LocaleKeys
                                                            .label_follow
                                                            .tr(),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: theme.colorScheme
                                                            .primary),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }),
                                SizedBox(
                                  width: Dimens.DIMENS_6,
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      User user =
                                          await userRepository.getOtherUserData(
                                              widget.payload!.uid);
                                      types.User otherUser = types.User(
                                          id: widget.payload!.uid,
                                          createdAt: user.createdAt!
                                                  .toDate()
                                                  .millisecondsSinceEpoch ~/
                                              1000,
                                          firstName: user.userName);
                                      if (!mounted) return;

                                      // final navigator = Navigator.of(context);
                                      final room = await FirebaseChatCore
                                          .instance
                                          .createRoom(otherUser);

                                      if (!mounted) return;
                                      context.pop();
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
                                    child: Container(
                                      height: Dimens.DIMENS_34,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          color: theme.colorScheme.tertiary,
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: Text(
                                        LocaleKeys.label_message.tr(),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: Dimens.DIMENS_12,
                                ),
                              ],
                            ),
                          SizedBox(
                            height: Dimens.DIMENS_8,
                          )
                        ]),
                  ),
                  SliverAppBar(
                    toolbarHeight: 0,
                    floating: false,
                    pinned: true,
                    elevation: 0,
                    bottom: TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorWeight: 2,
                      tabs: [
                        Tab(
                          icon: Icon(MdiIcons.folderPlay),
                        ),
                        Tab(
                          icon: Icon(MdiIcons.heart),
                        ),
                      ],
                    ),
                  ),
                ];
              },
              body: TabBarView(
                children: [
                  // Content for Tab 1
                  KeepAlivePage(
                    child: VideoListView(
                      uid: widget.payload?.uid ??
                          authRepository.currentUser!.uid,
                      from: From.user,
                    ),
                  ),
                  // Content for Tab 2
                  KeepAlivePage(
                    child: VideoListView(
                      uid: widget.payload?.uid ??
                          authRepository.currentUser!.uid,
                      from: From.likes,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  bool _isShowMenuBtn(AuthRepository authRepository, AuthState authState) =>
      authRepository.currentUser?.uid == widget.payload?.uid ||
      widget.payload == null;

  bool _isAuthenticated(AuthState authState) =>
      authState.status == AuthStatus.authenticated;

  Future<void> toEditProfile(BuildContext context) async {
    // User user = await futureUserData1!;
    // ProfileData profileData = ProfileData(
    //     name: widget.payload?.name ?? user.name!,
    //     userName: widget.payload?.userName ?? user.userName!,
    //     bio: userBio,
    //     photoUrl: widget.payload?.photoURL ?? user.photo!,
    //     updatedAt: user.updatedAt!,
    //     userNameUpdatedAt: user.userNameUpdatedAt!,
    //     gameFav: gameFavs,
    //     userCreatedAt: user.createdAt!,
    //     gameFavoritesId: []);

    if (!isToEditProfile && mounted) {
      isToEditProfile = true;
      await context.push(
        APP_PAGE.editProfile.toPath,
      );
    }
    isToEditProfile = false;
  }

  Theme gameFavView(String uid) {
    UserRepository repository = RepositoryProvider.of<UserRepository>(context);
    return Theme(
      data: Theme.of(context).copyWith(
        useMaterial3: false,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimens.DIMENS_8),
        child: BlocConsumer<GameFavCubit, GameFavState>(
          listener: (context, state) {
            if (state.sattus == GameFavSattus.succes) {
              gameFavs = state.gameFav!;
            }
          },
          builder: (_, state) {
            return FutureBuilder(
                future: repository.getSelectedGames(uid),
                builder: (context, AsyncSnapshot<List<GameFav>> snapshot) {
                  List<GameFav>? games = snapshot.data;

                  if (!snapshot.hasData) {
                    return Container();
                  }
                  if (snapshot.hasData) {
                    gameFavs = games!;
                  }
                  return BlocBuilder<ProfileCubit, ProfileState>(
                    buildWhen: (previous, current) {
                      if (current is ShowLessBio) {
                        return false;
                      } else if (current is ShowMoreBio) {
                        return false;
                      }
                      return true;
                    },
                    builder: (_, state) {
                      List<Widget> items = [
                        ...List<Widget>.generate(
                          games!.length,
                          (index) => Chip(
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            avatar: CircleAvatar(
                              radius: 10,
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: CachedNetworkImage(
                                  imageUrl: games[index].gameImage!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            label: Text(
                              games[index].gameTitle!,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ).toList(),
                      ];
                      if (state is ShowMoreGameFav) {
                        return Wrap(
                          spacing: 3,
                          runSpacing: Dimens.DIMENS_3,
                          children: [
                            ...items,
                            items.length > 3
                                ? GestureDetector(
                                    onTap: () {
                                      BlocProvider.of<ProfileCubit>(context)
                                          .seeMoreGameFavHandle();
                                    },
                                    child: Chip(
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        label: Text(
                                          LocaleKeys.label_see_less
                                              .tr()
                                              .replaceAll('.', ''),
                                          style: const TextStyle(fontSize: 11),
                                        )),
                                  )
                                : Container()
                          ],
                        );
                      }
                      return Wrap(
                          spacing: 3.0, // gap between adjacent chips
                          runSpacing: Dimens.DIMENS_3,
                          children: items.isEmpty
                              ? []
                              : [
                                  ...items.getRange(0, 3).toList(),
                                  items.length > 3
                                      ? GestureDetector(
                                          onTap: () {
                                            BlocProvider.of<ProfileCubit>(
                                                    context)
                                                .seeMoreGameFavHandle();
                                          },
                                          child: Chip(
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            label: Icon(
                                              Icons.more_horiz,
                                              size: Dimens.DIMENS_20,
                                            ),
                                          ),
                                        )
                                      : Container()
                                ]);
                    },
                  );
                });
          },
        ),
      ),
    );
  }

  BlocConsumer bioSectionView({required String uid}) {
    final repository = RepositoryProvider.of<UserRepository>(context);
    return BlocConsumer<EditBioCubit, EditBioState>(
      listener: (context, state) {
        if (state.status == EditBioStatus.succes) {
          userBio = state.bio!;
        }
      },
      builder: (context, state) {
        return FutureBuilder(
            future: repository.getBio(uid),
            builder: (context, snapshot) {
              String? bio = snapshot.data;
              if (snapshot.hasData) {
                userBio = bio!;
              }
              if (!snapshot.hasData || userBio.isEmpty) {
                return Container();
              }
              return BlocConsumer<EditBioCubit, EditBioState>(
                listener: (context, state) {
                  if (state.status == EditBioStatus.succes) {
                    bio = state.bio;
                  }
                },
                builder: (context, state) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: Dimens.DIMENS_12),
                    child: BlocBuilder<ProfileCubit, ProfileState>(
                      buildWhen: (previous, current) {
                        if (current is ShowLessGameFav) {
                          return false;
                        } else if (current is ShowMoreGameFav) {
                          return false;
                        }
                        return true;
                      },
                      builder: (context, state) {
                        int? maxLines = 5;
                        if (state is ShowMoreBio) {
                          maxLines = null;
                        } else if (state is ShowLessBio) {
                          maxLines = 5;
                        }
                        return LayoutBuilder(builder: (context, constraints) {
                          String text = bio!;
                          final textPainter = TextPainter(
                            text: TextSpan(
                              text: text,
                              style: const TextStyle(fontSize: 14.0),
                            ),
                            textDirection: TextDirection.ltr,
                          );
                          textPainter.layout(maxWidth: double.infinity);
                          final lines = (textPainter.size.height /
                                  textPainter.preferredLineHeight)
                              .ceil();

                          debugPrint('text is overflow  ${lines > 5}');

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Text(
                                  bio!,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: maxLines,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              if (lines > 5)
                                InkWell(
                                  onTap: () =>
                                      BlocProvider.of<ProfileCubit>(context)
                                          .seeMoreBioHandle(),
                                  child: Text(state is ShowLessBio ||
                                          state is ProfileInitial
                                      ? LocaleKeys.label_see_more.tr()
                                      : LocaleKeys.label_see_less.tr()),
                                )
                              else
                                Container(),
                            ],
                          );
                        });
                      },
                    ),
                  );
                },
              );
            });
      },
    );
  }

  /// username,photo ,follwers,folowing,likes
  Row topSectionView(AuthState authState) {
    final repository = RepositoryProvider.of<UserRepository>(context);
    String? uid =
        RepositoryProvider.of<AuthRepository>(context).currentUser?.uid;
    return Row(
      children: [
        SizedBox(
          width: Dimens.DIMENS_12,
        ),
        SizedBox(
          width: 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  // if (state.status == AuthStatus.notAuthenticated &&
                  //     widget.payload == null) {
                  //   return CircleAvatar(
                  //       backgroundColor: COLOR_grey, radius: 35);
                  // }else if(state.status == AuthStatus.authenticated && widget.payload==null){

                  // }
                  // if (state.status == AuthStatus.authenticated &&
                  //     !widget.isForOtherUser!) {
                  //   photoURL = state.user!.photo;
                  // } else if (state.status == AuthStatus.notAuthenticated &&
                  //     !widget.isForOtherUser!) {
                  //   return CircleAvatar(
                  //       backgroundColor: COLOR_grey, radius: 35);
                  // }
                  if (widget.payload != null) {
                    return CircleAvatar(
                      backgroundColor: COLOR_grey,
                      radius: 35,
                      backgroundImage: CachedNetworkImageProvider(
                        widget.payload!.photoURL,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (_) {
                                return Dialog(
                                  elevation: 0,
                                  surfaceTintColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  backgroundColor: Colors.transparent,
                                  child: CachedNetworkImage(
                                    width: 300,
                                    imageUrl: widget.payload!.photoURL,
                                    fit: BoxFit.contain,
                                  ),
                                );
                              });
                        },
                      ),
                    );
                  }

                  return StreamBuilder<String>(
                      stream: repository.getAvatar(widget.payload?.uid ?? uid!),
                      builder: (context, snapshot) {
                        String? avatar = snapshot.data;
                        if (!snapshot.hasData || snapshot.hasError) {
                          return CircleAvatar(
                            backgroundColor: COLOR_grey,
                            radius: 35,
                          );
                        }
                        return CircleAvatar(
                          backgroundColor: COLOR_grey,
                          radius: 35,
                          backgroundImage: CachedNetworkImageProvider(
                            avatar!,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (_) {
                                    return Dialog(
                                      elevation: 0,
                                      surfaceTintColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      backgroundColor: Colors.transparent,
                                      child: CachedNetworkImage(
                                        width: 300,
                                        imageUrl: avatar,
                                        fit: BoxFit.contain,
                                      ),
                                    );
                                  });
                            },
                          ),
                        );
                      });
                },
              ),
            ],
          ),
        ),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return FutureBuilder<int>(
                future: repository
                    .getFollowerCount(widget.payload?.uid ?? state.user!.id),
                builder: (context, AsyncSnapshot<int> snapshot) {
                  int? follwers = snapshot.data;
                  return Expanded(
                    child: InkWell(
                      splashColor: Colors.transparent,
                      overlayColor: const MaterialStatePropertyAll<Color>(
                        Colors.transparent,
                      ),
                      onTap: () {
                        context.push(APP_PAGE.followingNFonllowers.toPath,
                            extra: FollowingNFollowersData(
                                initialIndex: 0,
                                userName: widget.payload?.userName ??
                                    state.user!.userName!,
                                uid: widget.payload?.uid ?? state.user!.id));
                      },
                      child: Column(
                        children: [
                          Text(
                            snapshot.hasData ? follwers.toString() : '0',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w600),
                          ),
                          Text(LocaleKeys.label_followers.tr(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                });
          },
        ),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return FutureBuilder<int>(
                future: repository
                    .getFollowingCount(widget.payload?.uid ?? state.user!.id),
                builder: (context, AsyncSnapshot<int> snapshot) {
                  int? following = snapshot.data;
                  return Expanded(
                    child: InkWell(
                      splashColor: Colors.transparent,
                      overlayColor: const MaterialStatePropertyAll<Color>(
                        Colors.transparent,
                      ),
                      onTap: () {
                        context.push(APP_PAGE.followingNFonllowers.toPath,
                            extra: FollowingNFollowersData(
                                initialIndex: 1,
                                userName: widget.payload?.userName ??
                                    state.user!.userName!,
                                uid: widget.payload?.uid ?? state.user!.id));
                      },
                      child: Column(
                        children: [
                          Text(
                            snapshot.hasData ? following.toString() : '0',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            LocaleKeys.label_following.tr(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                });
          },
        ),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return FutureBuilder<int>(
                future: repository
                    .getLikesCount(widget.payload?.uid ?? state.user!.id),
                builder: (context, AsyncSnapshot<int> snapshot) {
                  int? likes = snapshot.data;

                  return Expanded(
                    child: Column(
                      children: [
                        Text(
                          snapshot.hasData ? likes.toString() : '0',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          LocaleKeys.label_likes.tr(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                });
          },
        ),
        SizedBox(
          width: Dimens.DIMENS_12,
        ),
      ],
    );
  }

  Padding _buildUserName() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimens.DIMENS_12),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state.status == AuthStatus.authenticated &&
              !widget.isForOtherUser!) {
            userName = '@${state.user!.userName}';
          } else if (state.status == AuthStatus.notAuthenticated &&
              !widget.isForOtherUser!) {
            userName = '@${LocaleKeys.label_user_name.tr()}';
          }

          return BlocBuilder<EditUserNameCubit, EditUserNameState>(
            builder: (context, state) {
              if (state.status == EditUserNameStatus.success &&
                  widget.payload == null) {
                return Text(
                  '@${state.newUserName!}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                );
              }
              return Text(
                userName!,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              );
            },
          );
        },
      ),
    );
  }
}

class VideoListView extends StatelessWidget {
  final String uid;
  final From from;
  const VideoListView({super.key, required this.uid, required this.from});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        !(from == From.user)
            ? Container()
            : BlocBuilder<UploadBloc, UploadState>(
                builder: (context, state) {
                  if (state is Uploading) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8)),
                        child: ListTile(
                          minLeadingWidth: 50,
                          leading: SizedBox(
                            width: 50,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.file(
                                  state.thumbnail,
                                  width: 60,
                                  fit: BoxFit.cover,
                                ),
                                StreamBuilder(
                                  stream:
                                      RepositoryProvider.of<VideoRepository>(
                                              context)
                                          .uploadProgressStream,
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return Container();
                                    }
                                    return SizedBox.expand(
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          CircularProgressIndicator(
                                            value: snapshot.data! / 100,
                                            color: COLOR_white_fff5f5f5,
                                          ),
                                          Text(
                                            '${snapshot.data!.toInt()}%',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: COLOR_white_fff5f5f5),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          subtitle: Text(state.caption),
                        ),
                      ),
                    );
                  }
                  return Container();
                },
              ),
        Expanded(
          child: RepositoryProvider(
            create: (context) => UserVideoPagingRepository(),
            child: BlocProvider(
              create: (context) => UserVideoPagingBloc(
                  RepositoryProvider.of<UserVideoPagingRepository>(context))
                ..add(InitUserVideoPaging(uid: uid, from: from)),
              child: BlocBuilder<UserVideoPagingBloc, UserVideoPagingState>(
                builder: (_, state) {
                  if (state is UserVideoPagingInitialed) {
                    return BlocListener<RefreshProfileCubit,
                        RefreshProfileState>(
                      listener: (context, refreshState) {
                        if (refreshState.status == RefreshStatus.refresh) {
                          RepositoryProvider.of<UserVideoPagingRepository>(
                                  context)
                              .clearLikeVideo();
                          RepositoryProvider.of<UserVideoPagingRepository>(
                                  context)
                              .clearUserVideo();
                          state.controller.refresh();
                        }
                      },
                      child: PagedGridView<int, String>(
                        pagingController: state.controller,
                        padding: const EdgeInsets.only(top: 2),
                        builderDelegate: PagedChildBuilderDelegate(
                          noItemsFoundIndicatorBuilder: (context) => Center(
                            child: Text(
                              from == From.user
                                  ? LocaleKeys.message_no_post.tr()
                                  : LocaleKeys.message_no_liked_post.tr(),
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          itemBuilder: (_, item, index) {
                            // var doc = await firebaseFirestore.collection('videos').doc(item).get();
                            // Video video = Video.fromSnap(doc);
                            return AspectRatio(
                              aspectRatio: 16 / 9,
                              child: FutureBuilder(
                                  future: firebaseFirestore
                                      .collection('videos')
                                      .doc(item)
                                      .get(),
                                  builder: (_,
                                      AsyncSnapshot<DocumentSnapshot>
                                          snapshot) {
                                    late Video video;
                                    if (snapshot.data != null) {
                                      video = Video.fromSnap(snapshot.data!);
                                    }

                                    if (!snapshot.hasData) {
                                      return Container();
                                    }
                                    return Container(
                                      color: COLOR_black,
                                      child: GestureDetector(
                                        onTap: () {
                                          context.push(
                                              APP_PAGE.videoItem.toPath,
                                              extra: video);
                                        },
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            CachedNetworkImage(
                                                fit: BoxFit.cover,
                                                imageUrl: video.thumnail),
                                            Align(
                                              alignment: Alignment.bottomLeft,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      '${video.views.length} ',
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
                                    );
                                  }),
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
                      ),
                    );
                  }
                  return const CircularProgressIndicator();
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
