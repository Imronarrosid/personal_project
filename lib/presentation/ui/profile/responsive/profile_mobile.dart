import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart' as localization;
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:personal_project/config/bloc_status_enum.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/data/repository/upload_repository.dart';
import 'package:personal_project/data/repository/user_video_paging_repository.dart';
import 'package:personal_project/domain/model/chat_data_models.dart';
import 'package:personal_project/domain/model/game_fav_modal.dart';
import 'package:personal_project/domain/model/play_single_data.dart';
import 'package:personal_project/domain/model/profile_data_model.dart';
import 'package:personal_project/domain/model/user.dart';
import 'package:personal_project/domain/model/video_model.dart';
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';
import 'package:personal_project/domain/reporsitory/user_repository.dart';
import 'package:personal_project/domain/services/firebase/firebase_service.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/router/app_router.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:personal_project/presentation/shared_components/expandable_text.dart';
import 'package:personal_project/presentation/shared_components/keep_alive_page.dart';
import 'package:personal_project/presentation/shared_components/not_authenticated_page.dart';
import 'package:personal_project/presentation/ui/add_details/bloc/upload_bloc.dart';
import 'package:personal_project/presentation/ui/auth/auth.dart';
import 'package:personal_project/presentation/ui/auth/bloc/auth_bloc.dart';
import 'package:personal_project/presentation/ui/edit_profile/cubit/game_fav_cubit.dart';
import 'package:personal_project/presentation/ui/profile/bloc/user_video_paging_bloc.dart';
import 'package:personal_project/presentation/ui/profile/cubit/follow_cubit.dart';
import 'package:personal_project/presentation/ui/profile/cubit/profile_cubit.dart';
import 'package:personal_project/presentation/ui/profile/cubit/refresh_profile_cubit.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:personal_project/presentation/ui/profile/video_list/video_list_notifier.dart';
import 'package:personal_project/presentation/ui/uploading/uploading_page.dart';
import 'package:personal_project/utils/number_format.dart';
import 'package:provider/provider.dart';
import 'package:solar_icons/solar_icons.dart';

import '../../../../utils/debug_mode_print.dart';

class ProfilePageMobile extends StatefulWidget {
  final ProfilePayload? payload;
  const ProfilePageMobile({super.key, this.payload});

  @override
  State<ProfilePageMobile> createState() => _ProfilePageMobileState();
}

class _ProfilePageMobileState extends State<ProfilePageMobile> {
  List<GameFav> gameFavs = [];
  String userBio = '';
  bool isToEditProfile = false;
  bool isToMenu = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state.status == AuthStatus.authenticated ||
                !(GoRouterState.of(context).pathParameters['username'] ==
                    'login')) {
              return BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state.status == AuthStatus.authenticated) {
                    context.go(APP_PAGE.forYou.toPath);
                  }
                },
                child: StreamBuilder<User>(
                    // initialData: widget.userDaata,
                    stream: userRepository.userDataStreamByUsername(
                        GoRouterState.of(context).pathParameters['username']!),
                    builder:
                        (BuildContext context, AsyncSnapshot<User> snapshot) {
                      debugModePrint(
                          'pathParams ${GoRouterState.of(context).pathParameters['username']!}');
                      User? userData = snapshot.data;
                      debugModePrint('connectionstate ${snapshot.connectionState}');
                      if (snapshot.hasError) {
                        if (snapshot.error is TimeoutException) {
                          Scaffold(
                              appBar: AppBar(
                                leading: BackButton(
                                  onPressed: () {
                                    Provider.of<AppRouter>(context,
                                            listen: false)
                                        .onBackButtonPressed(context);
                                  },
                                ),
                              ),
                              body: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text('Request Timeout'),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {});
                                      },
                                      icon:
                                          const Icon(SolarIconsOutline.refresh),
                                    )
                                  ],
                                ),
                              ));
                        }
                        return Scaffold(
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
                                decoration: const BoxDecoration(),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(snapshot.error.toString()),
                                    const Icon(SolarIconsBold.sadCircle)
                                  ],
                                ),
                              ),
                            ));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return Scaffold(
                        appBar: AppBar(
                          backgroundColor: Colors.transparent,
                          surfaceTintColor: Colors.transparent,
                          scrolledUnderElevation: 0,
                          elevation: 0,
                          automaticallyImplyLeading: false,
                          leading: _leading(context, user: userData!),
                          title: _buildTitle(userData.userName!),
                          actions: <Widget>[
                            ListenableBuilder(
                              listenable: UploadRepository.instance,
                              builder: (context, child) {
                                debugModePrint(
                                    'uploading ${UploadRepository.instance.isUploading}');
                                if (!UploadRepository.instance.isUploading) {
                                  return const SizedBox(
                                    width: 0,
                                    height: 0,
                                  );
                                }
                                return child!;
                              },
                              child: IconButton(
                                alignment: Alignment.center,
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => const Dialog(
                                      backgroundColor: Colors.transparent,
                                      surfaceTintColor: Colors.transparent,
                                      child: Center(
                                        child: SizedBox(
                                          width: 300,
                                          height: 150,
                                          child: UploadingPage(),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                icon: Container(
                                  alignment: Alignment.center,
                                  width: 40,
                                  height: 40,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      const Icon(
                                          SolarIconsBold.uploadMinimalistic),
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Container(
                                            width: 4,
                                            height: 4,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                color: Colors.red),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                return _isShowMenuBtn(authRepository, userData)
                                    ? IconButton(
                                        onPressed: () {
                                          if (isToMenu) {
                                            isToMenu = false;
                                            context.go(
                                              APP_PAGE.menu.toPath,
                                            );
                                          }
                                          isToMenu = true;
                                        },
                                        icon: const Icon(Icons.menu))
                                    : Container();
                              },
                            )
                          ],
                        ),
                        body: GestureDetector(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                          },
                          child: BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, authState) {
                              debugModePrint(authState.toString());

                              return _profileBody(size, context, authState,
                                  authRepository, userData);
                            },
                          ),
                        ),
                      );
                    }),
              );
            } else {
              return Scaffold(
                  appBar: AppBar(
                    automaticallyImplyLeading: false,
                    title: Text(LocaleKeys.label_profile.tr()),
                    actions: [
                      IconButton(
                          onPressed: () {
                            if (isToMenu) {
                              isToMenu = false;
                              context.go(
                                APP_PAGE.menu.toPath,
                              );
                            }
                            isToMenu = true;
                          },
                          icon: const Icon(Icons.menu))
                    ],
                  ),
                  body: const NotAuthenticatedPage());
            }
          },
        );
      }),
    );
  }

  Widget? _leading(BuildContext context, {required User user}) {
    final AppRouter appRouter = Provider.of(context, listen: false);
    if (firebaseAuth.currentUser?.uid == user.id) {
      return null;
    }
    return BackButton(
      onPressed: () {
        appRouter.onBackButtonPressed(context);
      },
    );
  }

  Text _buildTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }

  SizedBox _profileBody(Size size, BuildContext context, AuthState authState,
      AuthRepository authRepository, User userData) {
    final ThemeData theme = Theme.of(context);
    final userRepository = RepositoryProvider.of<UserRepository>(context);
    return SizedBox(
        child: DefaultTabController(
            length: 2,
            child: RefreshIndicator(
                onRefresh: () => Future.sync(() {
                      setState(() {});
                      BlocProvider.of<RefreshProfileCubit>(context)
                          .refreshProfile();
                    }),
                child: _mobileView(userData, authRepository, userRepository,
                    theme, authState))));
  }

  Widget _mobileView(User userData, AuthRepository authRepository,
      UserRepository userRepository, ThemeData theme, AuthState authState) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: ExtendedNestedScrollView(
        onlyOneScrollInBody: true,
        pinnedHeaderSliverHeightBuilder: () => 55,
        controller: ScrollController(),
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              topSectionView(userData),
              _buildUserName(userData),
              SizedBox(
                height: Dimens.DIMENS_8,
              ),
              bioSectionView(uid: userData.id),
              SizedBox(
                height: Dimens.DIMENS_6,
              ),
              gameFavView(userData.id),
              SizedBox(
                height: Dimens.DIMENS_8,
              ),
              if ((userData.id) == authRepository.currentUser?.uid)
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  SizedBox(
                    width: Dimens.DIMENS_12,
                  ),
                  Expanded(
                    flex: 2,
                    child: Material(
                      color: Theme.of(context).colorScheme.tertiary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => toEditProfile(context),
                        child: Container(
                          height: Dimens.DIMENS_32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            LocaleKeys.label_edit_profile.tr(),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // SizedBox(
                  //   width: Dimens.DIMENS_6,
                  // ),
                  // Expanded(
                  //   child: Container(
                  //       height: Dimens.DIMENS_32,
                  //       decoration: BoxDecoration(
                  //           color: theme.colorScheme.tertiary,
                  //           borderRadius:
                  //               BorderRadius.circular(8)),
                  //       child: Icon(
                  //         BootstrapIcons.person_add,
                  //         size: Dimens.DIMENS_20,
                  //       )),
                  // ),
                  SizedBox(
                    width: Dimens.DIMENS_12,
                  ),
                ])
              else
                Row(
                  children: [
                    SizedBox(
                      width: Dimens.DIMENS_12,
                    ),
                    FutureBuilder<bool>(
                        future: userRepository.isFollowing(userData.id),
                        builder: (context, AsyncSnapshot<bool> snapshot) {
                          bool? isFollowing = snapshot.data;
                          if (!snapshot.hasData) {
                            return Expanded(
                              child: Container(
                                height: Dimens.DIMENS_32,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.tertiary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: SizedBox(
                                    width: Dimens.DIMENS_18,
                                    height: Dimens.DIMENS_18,
                                    child: CircularProgressIndicator(
                                      color: COLOR_white_fff5f5f5,
                                    )),
                              ),
                            );
                          }

                          return BlocBuilder<FollowCubit, FollowState>(
                            builder: (context, state) {
                              debugModePrint('follow state $state');
                              if (state.status == BlocStatus.following) {
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
                                      borderRadius: BorderRadius.circular(8)),
                                  color: isFollowing!
                                      ? theme.colorScheme.tertiary
                                      : theme.colorScheme.onTertiary,
                                  child: InkWell(
                                    onTap: () {
                                      if (isFollowing! &&
                                          authState.status ==
                                              AuthStatus.authenticated) {
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
                                                    child: Text(LocaleKeys
                                                        .label_cancel
                                                        .tr()),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      BlocProvider.of<
                                                                  FollowCubit>(
                                                              context)
                                                          .followButtonHandle(
                                                              currentUserUid:
                                                                  authRepository
                                                                      .currentUser!
                                                                      .uid,
                                                              uid: userData.id,
                                                              stateFromDatabase:
                                                                  isFollowing!);
                                                      context.pop();
                                                    },
                                                    child: Text(LocaleKeys
                                                        .label_oke
                                                        .tr()),
                                                  )
                                                ],
                                              );
                                            });
                                      } else if (!isFollowing! &&
                                          authState.status ==
                                              AuthStatus.authenticated) {
                                        BlocProvider.of<FollowCubit>(context)
                                            .followButtonHandle(
                                                currentUserUid: authRepository
                                                    .currentUser!.uid,
                                                uid: userData.id,
                                                stateFromDatabase:
                                                    isFollowing!);
                                      } else {
                                        showAuthBottomSheetFunc(context);
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      height: Dimens.DIMENS_32,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: Text(
                                        isFollowing!
                                            ? LocaleKeys.label_following.tr()
                                            : LocaleKeys.label_follow.tr(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: theme.colorScheme.onSurface),
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
                      child: Material(
                        color: theme.colorScheme.tertiary,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () async {
                            if (authState.status == AuthStatus.authenticated) {
                              User user = await userRepository
                                  .getOtherUserData(userData.id);
                              types.User otherUser = types.User(
                                  id: userData.id,
                                  createdAt: user.createdAt!
                                          .toDate()
                                          .millisecondsSinceEpoch ~/
                                      1000,
                                  firstName: user.userName);
                              if (!mounted) return;

                              // final navigator = Navigator.of(context);
                              final room = await FirebaseChatCore.instance
                                  .createRoom(otherUser);

                              if (!mounted) return;
                              context.go(
                                APP_PAGE.chat.toPath,
                                extra: ChatData(
                                  room: room,
                                  userName: user.userName!,
                                  avatar: user.photo!,
                                  name: user.name,
                                ),
                              );
                            } else {
                              showAuthBottomSheetFunc(context);
                            }
                          },
                          child: Container(
                            height: Dimens.DIMENS_32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              LocaleKeys.label_message.tr(),
                              textAlign: TextAlign.center,
                            ),
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
          _tabbar(),
        ],
        body: _tabView(userData),
      ),
    );
  }

  TabBarView _tabView(User userData) {
    return TabBarView(
      children: [
        // Content for Tab 1
        KeepAlivePage(
          child: VideoListView(
            uid: userData.id,
            from: From.user,
          ),
        ),
        // Content for Tab 2
        KeepAlivePage(
          child: VideoListView(
            uid: userData.id,
            from: From.likes,
          ),
        ),
      ],
    );
  }

  SliverAppBar _tabbar() {
    return SliverAppBar(
      toolbarHeight: 0,
      floating: false,
      pinned: true,
      elevation: 0,
      bottom: TabBar(
        onTap: (value) {
          From from = From.user;
          switch (value) {
            case 0:
              from = From.user;
              break;
            case 1:
              from = From.likes;
              break;
            default:
              from = From.user;
              break;
          }
          ProfileVideoListVotifier.instance.changeVideoFrom(from);
        },
        overlayColor: WidgetStatePropertyAll<Color>(
            Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorWeight: 2,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(
            icon: Icon(SolarIconsBold.videoLibrary),
          ),
          Tab(
            icon: Icon(SolarIconsBold.heart),
          ),
        ],
      ),
    );
  }


  bool _isShowMenuBtn(AuthRepository authRepository, User userData) =>
      authRepository.currentUser?.uid == userData.id;

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
      context.go(
        APP_PAGE.menu.toPath + APP_PAGE.editProfile.toPath,
      );
    }
    isToEditProfile = false;
  }

  Theme gameFavView(String uid) {
    UserRepository repository = RepositoryProvider.of<UserRepository>(context);
    return Theme(
      data: Theme.of(context).copyWith(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimens.DIMENS_12),
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            side: BorderSide.none,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            avatar: CircleAvatar(
                              radius: 8,
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              backgroundImage: CachedNetworkImageProvider(
                                games[index].gameImage!,
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
                                        side: BorderSide.none,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(50)),
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: VisualDensity.compact,
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
                              : items.length < 3
                                  ? items
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
                                                side: BorderSide.none,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50)),
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                visualDensity:
                                                    VisualDensity.compact,
                                                label: Icon(
                                                  Icons.more_horiz,
                                                  size: Dimens.DIMENS_12,
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

  FutureBuilder bioSectionView({required String uid}) {
    final repository = RepositoryProvider.of<UserRepository>(context);
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
          return Padding(
            padding: EdgeInsets.only(left: Dimens.DIMENS_12),
            child: ExpandableText(text: userBio),
          );
        });
  }

  /// username,photo ,follwers,folowing,likes
  Row topSectionView(User userData) {
    final repository = RepositoryProvider.of<UserRepository>(context);
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
              BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
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

                return CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  radius: 35,
                  backgroundImage: CachedNetworkImageProvider(
                    userData.photo!,
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
                                imageUrl: userData.photo!,
                                errorWidget: (_, __, ___) => Container(
                                  width: 300,
                                  height: 300,
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                                fit: BoxFit.contain,
                              ),
                            );
                          });
                    },
                  ),
                );
              }),
            ],
          ),
        ),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (_, state) {
            return FutureBuilder<int>(
                initialData: 0,
                future: repository.getFollowerCount(userData.id),
                builder: (context, AsyncSnapshot<int> snapshot) {
                  int? follwers = snapshot.data;
                  String followerCount =
                      numberFormat(context.locale, follwers!);
                  return Expanded(
                    child: InkWell(
                      splashColor: Colors.transparent,
                      overlayColor: const WidgetStatePropertyAll<Color>(
                        Colors.transparent,
                      ),
                      onTap: () => _toFollowingNFollowers(
                          context, userData, APP_PAGE.followers.toPath),
                      child: Column(
                        children: [
                          Text(
                            followerCount,
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
                initialData: 0,
                future: repository.getFollowingCount(userData.id),
                builder: (_, AsyncSnapshot<int> snapshot) {
                  int following = snapshot.data!;
                  String followingCount =
                      numberFormat(context.locale, following);
                  return Expanded(
                    child: InkWell(
                      splashColor: Colors.transparent,
                      overlayColor: const WidgetStatePropertyAll<Color>(
                        Colors.transparent,
                      ),
                      onTap: () => _toFollowingNFollowers(
                          context, userData, APP_PAGE.following.toPath),
                      child: Column(
                        children: [
                          Text(
                            followingCount,
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
                initialData: 0,
                future: repository.getLikesCount(userData.id),
                builder: (context, AsyncSnapshot<int> snapshot) {
                  int likes = snapshot.data!;
                  String likeCount = numberFormat(context.locale, likes);
                  return Expanded(
                    child: Column(
                      children: [
                        Text(
                          likeCount,
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

  void _toFollowingNFollowers(BuildContext context, User userData, String tab) {
    // String profileRoute =
    //     GoRouter.of(context).routeInformationProvider.value.uri.path;
    if (!isToEditProfile && mounted) {
      isToEditProfile = true;

      context.go(
        '$tab/${userData.userName}',
      );
    }
    isToEditProfile = false;
    // AppRouter appRouter = Provider.of<AppRouter>(context, listen: false);
    // appRouter.routeHistory.add(
    //   profileRoute + APP_PAGE.followingNFonllowers.toPath,
    // );
  }

  Padding _buildUserName(User userData) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimens.DIMENS_12),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return Text(
            userData.userName!,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
    final AuthRepository authRepository =
        RepositoryProvider.of<AuthRepository>(context);
    return RepositoryProvider(
      create: (context) => UserVideoPagingRepository(),
      child: BlocProvider(
        create: (context) => UserVideoPagingBloc(
            RepositoryProvider.of<UserVideoPagingRepository>(context))
          ..add(InitUserVideoPaging(uid: uid, from: from)),
        child: BlocBuilder<UserVideoPagingBloc, UserVideoPagingState>(
          builder: (_, state) {
            if (state.status == BlocStatus.initialized) {
              return BlocListener<RefreshProfileCubit, RefreshProfileState>(
                listener: (context, refreshState) {
                  if (refreshState.status == RefreshStatus.refresh) {
                    RepositoryProvider.of<UserVideoPagingRepository>(context)
                        .clearLikeVideo();
                    RepositoryProvider.of<UserVideoPagingRepository>(context)
                        .clearUserVideo();
                    state.controller!.refresh();
                  }
                },
                child: BlocListener<UploadBloc, UploadState>(
                  listener: (context, uploadState) {
                    if (uploadState is VideoDeleted ||
                        uploadState is VideoUploaded) {
                      if (from == From.user) {
                        RepositoryProvider.of<UserVideoPagingRepository>(
                                context)
                            .clearUserVideo();
                        state.controller!.refresh();
                      }
                    }
                  },
                  child: SingleChildScrollView(
                    child: PagedGridView<int, String>(
                      pagingController: state.controller!,
                      padding: const EdgeInsets.only(top: 2),
                      scrollController: ScrollController(),
                      shrinkWrap: true,
                      builderDelegate: PagedChildBuilderDelegate(
                        noItemsFoundIndicatorBuilder: (context) => Container(
                          alignment: Alignment.center,
                          height: Dimens.DIMENS_250,
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
                                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                                  late Video video;

                                  if (!snapshot.hasData) {
                                    return Container(
                                      color: Colors.black,
                                    );
                                  }
                                  if (snapshot.data!.exists) {
                                    video = Video.fromSnap(snapshot.data!);
                                  } else {
                                    return Container(
                                      color: Colors.black,
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.all(Dimens.DIMENS_18),
                                      child: Text(
                                        LocaleKeys
                                            .message_video_not_available_or_deleted
                                            .tr(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall,
                                      ),
                                    );
                                  }
                                  return Container(
                                    color: COLOR_black,
                                    child: GestureDetector(
                                      onTap: () {
                                        context.go(
                                          '${APP_PAGE.videoItem.toPath}/${video.id}',
                                          extra: PlaySingleData(
                                            index: index,
                                            videoData: video,
                                            isForLogedUserVideo:
                                                from == From.user &&
                                                    uid ==
                                                        authRepository
                                                            .currentUser?.uid,
                                          ),
                                        );
                                      },
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          CachedNetworkImage(
                                              fit: BoxFit.cover,
                                              errorWidget: (_, __, ___) =>
                                                  Container(),
                                              imageUrl: video.thumnail),
                                          Align(
                                            alignment: Alignment.bottomLeft,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    '${numberFormat(context.locale, video.viewsCount)} ',
                                                    style: TextStyle(
                                                        color:
                                                            COLOR_white_fff5f5f5),
                                                  ),
                                                  Text(
                                                    LocaleKeys.label_views.tr(),
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
                  ),
                ),
              );
            }
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
