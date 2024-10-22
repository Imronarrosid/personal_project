import 'dart:async';
import 'dart:io';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart' as localization;
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:personal_project/config/bloc_status_enum.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/data/repository/user_video_paging_repository.dart';
import 'package:personal_project/domain/model/chat_data_models.dart';
import 'package:personal_project/domain/model/following_n_followers_data_model.dart';
import 'package:personal_project/domain/model/game_fav_modal.dart';
import 'package:personal_project/domain/model/play_single_data.dart';
import 'package:personal_project/domain/model/profile_data_model.dart';
import 'package:personal_project/domain/model/user.dart';
import 'package:personal_project/domain/model/video_model.dart';
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';
import 'package:personal_project/domain/reporsitory/user_repository.dart';
import 'package:personal_project/domain/reporsitory/video_repository.dart';
import 'package:personal_project/domain/services/firebase/firebase_service.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:personal_project/presentation/shared_components/expandable_text.dart';
import 'package:personal_project/presentation/shared_components/keep_alive_page.dart';
import 'package:personal_project/presentation/shared_components/not_authenticated_page.dart';
import 'package:personal_project/presentation/ui/add_details/bloc/upload_bloc.dart';
import 'package:personal_project/presentation/ui/auth/auth.dart';
import 'package:personal_project/presentation/ui/auth/bloc/auth_bloc.dart';
import 'package:personal_project/presentation/ui/edit_profile/cubit/edit_bio_cubit.dart';
import 'package:personal_project/presentation/ui/edit_profile/cubit/edit_name_cubit.dart';
import 'package:personal_project/presentation/ui/edit_profile/cubit/edit_user_name_cubit.dart';
import 'package:personal_project/presentation/ui/edit_profile/cubit/game_fav_cubit.dart';
import 'package:personal_project/presentation/ui/followings_n_followers/dialog/following_dialog.dart';
import 'package:personal_project/presentation/ui/followings_n_followers/followings_n_followers.dart';
import 'package:personal_project/presentation/ui/profile/bloc/user_video_paging_bloc.dart';
import 'package:personal_project/presentation/ui/profile/cubit/follow_cubit.dart';
import 'package:personal_project/presentation/ui/profile/cubit/profile_cubit.dart';
import 'package:personal_project/presentation/ui/profile/cubit/refresh_profile_cubit.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:personal_project/utils/number_format.dart';
import 'package:provider/provider.dart';
import 'package:solar_icons/solar_icons.dart';

import '../../../router/app_router.dart';
import '../../../shared_components/container_with_max_width.dart';

class ProfilePageDesktop extends StatefulWidget {
  /// [userDaata] need to required if
  ///
  /// to serve other user info
  ///
  /// other user mean is [ProfilePageDesktop] that not in [HomePage]
  final User? userDaata;
  final String? userName;

  const ProfilePageDesktop({
    super.key,
    this.userDaata,
    required this.userName,
  });

  @override
  State<ProfilePageDesktop> createState() => _ProfilePageDesktopState();
}

class _ProfilePageDesktopState extends State<ProfilePageDesktop>
    with SingleTickerProviderStateMixin {
  List<GameFav> gameFavs = [];
  String userBio = '';
  bool isToEditProfile = false;
  bool isToMenu = true;
  late final TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userDaata != null) {}
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
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          String path =
              GoRouter.of(context).routeInformationProvider.value.uri.path;
          debugPrint(
              'url ${GoRouter.of(context).routeInformationProvider.value.uri.path}');
          if (path == '/profile/login') {
            return _notAuthenticatedView(context, authRepository);
          }
          return StreamBuilder<User>(
              // initialData: widget.userDaata,
              stream: userRepository.userDataStreamByUsername(
                  GoRouterState.of(context).pathParameters['username']!),
              builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
                debugPrint(
                    'pathParams ${GoRouterState.of(context).pathParameters['username']!}');
                User? userData = snapshot.data;
                if (snapshot.hasError) {
                  if (snapshot.error is TimeoutException) {
                    ContainerWidthMaxWidth(
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
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text('Request Timeout'),
                                IconButton(
                                  onPressed: () {
                                    setState(() {});
                                  },
                                  icon: const Icon(SolarIconsOutline.refresh),
                                )
                              ],
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
                              Provider.of<AppRouter>(context, listen: false)
                                  .onBackButtonPressed(context);
                            },
                          ),
                        ),
                        body: Center(
                          child: Container(
                            width: Dimens.DIMENS_105,
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
                                Text(
                                  snapshot.error.toString(),
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

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                debugPrint('userData ${userData!.userName}');
                return ContainerWidthMaxWidth(
                  maxWidth: 940,
                  child: Scaffold(
                    appBar: AppBar(
                      automaticallyImplyLeading: false,
                      backgroundColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      scrolledUnderElevation: 0,
                      elevation: 0,
                      title: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          userData.name ?? LocaleKeys.title_profile.tr(),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),
                    body: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimens.DIMENS_34,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                        },
                        child: BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, authState) {
                            debugPrint(authState.toString());

                            // return Text(userData.userName!);

                            return _profileBody(
                                size, context, authState, authRepository,
                                userData: userData!);

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
                    ),
                  ),
                );
              });
        },
      ),
    );
  }

  Scaffold _notAuthenticatedView(
      BuildContext context, AuthRepository authRepository) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          elevation: 0,
          title: Text(
            LocaleKeys.title_profile.tr() + " desktop",
            style: Theme.of(context).textTheme.titleLarge,

            // return _buildTitle(title);
          ),
          actions: <Widget>[
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return _isShowMenuBtn(authRepository, state)
                    ? IconButton(
                        onPressed: () {
                          if (isToMenu) {
                            isToMenu = false;
                            context.go(
                              '${APP_PAGE.menu.toPath}${APP_PAGE.login.toPath}',
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
        body: const NotAuthenticatedPage());
  }

  BlocBuilder<EditNameCubit, EditNameState> _buildTitle(String? title) {
    return BlocBuilder<EditNameCubit, EditNameState>(
      builder: (context, state) {
        if (state.status == EditNameStatus.nameEditSuccess &&
            widget.userDaata == null) {
          title = state.name;
        }
        return Text(
          title ?? LocaleKeys.title_profile.tr(),
          style: Theme.of(context).textTheme.titleLarge,
        );
      },
    );
  }

  RefreshIndicator _profileBody(
    Size size,
    BuildContext context,
    AuthState authState,
    AuthRepository authRepository, {
    required User userData,
  }) {
    final ThemeData theme = Theme.of(context);
    final userRepository = RepositoryProvider.of<UserRepository>(context);
    return RefreshIndicator(
      // notificationPredicate: (notification) {
      //   // with NestedScrollView local(depth == 2) OverscrollNotification are not sent
      //   if (notification is OverscrollNotification || Platform.isIOS) {
      //     return notification.depth == 2;
      //   }
      //   return notification.depth == 0;
      // },
      onRefresh: () => Future.sync(() {
        setState(() {});
        BlocProvider.of<RefreshProfileCubit>(context).refreshProfile();
      }),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ExtendedNestedScrollView(
          onlyOneScrollInBody: true,
          pinnedHeaderSliverHeightBuilder: () => 55,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            topSectionView(authState, userData),

            SliverToBoxAdapter(
              child: SizedBox(
                height: Dimens.DIMENS_8,
              ),
            ),
            // if ((userData.id) == authRepository.currentUser?.uid)
            //   _editProfileBtn(context)
            // else
            //   _followBtn(userRepository, userData, theme, authState,
            //       authRepository, context),
            SliverToBoxAdapter(
              child: SizedBox(
                height: Dimens.DIMENS_8,
              ),
            ),
            _tabBar(context),
          ],
          body: tabBarView(userData),
        ),
      ),
    );

    // AppBar(
    //   toolbarHeight: 0,
    //   floating: false,
    //   pinned: true,
    //   elevation: 0,
    //   bottom: TabBar(
    //     overlayColor: MaterialStatePropertyAll<Color>(
    //         Theme.of(context)
    //             .colorScheme
    //             .onSurface
    //             .withOpacity(0.3)),
    //     indicatorSize: TabBarIndicatorSize.tab,
    //     indicatorWeight: 2,
    //     tabs: const [
    //       Tab(
    //         icon: Icon(BootstrapIcons.camera_video),
    //       ),
    //       Tab(
    //         icon: Icon(BootstrapIcons.heart),
    //       ),
    //     ],
    //   ),
    // ),
  }

  Container tabBarView(User userData) {
    return Container(
      child: TabBarView(
        controller: _tabController,
        children: [
          // Content for Tab 1
          KeepAlivePage(
            child: VideoListView(
              uid: widget.userDaata?.id ?? userData.id,
              from: From.user,
            ),
          ),

          // Content for Tab 2
          KeepAlivePage(
            child: VideoListView(
              uid: widget.userDaata?.id ?? userData.id,
              from: From.likes,
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _tabBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      toolbarHeight: 0.0,
      shape: Border(
        top: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            width: 1.3),
      ),
      bottom: TabBar(
        controller: _tabController,
        overlayColor: MaterialStatePropertyAll<Color>(
            Theme.of(context).colorScheme.onSurface.withOpacity(0.12)),
        indicatorSize: TabBarIndicatorSize.label,
        indicatorWeight: 2,
        labelColor: Theme.of(context).colorScheme.onSurface,
        indicator: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface, // Color of the indicator
              width: 1.5, // Thickness of the indicator
            ),
          ),
        ),
        tabAlignment: TabAlignment.center,
        tabs: [
          Tab(
            child: Row(
              children: [
                Icon(
                  SolarIconsBold.videoLibrary,
                  size: Dimens.DIMENS_16,
                ),
                SizedBox(
                  width: Dimens.DIMENS_3,
                ),
                Text(
                  LocaleKeys.title_video.tr().toUpperCase(),
                  style: TextStyle(fontSize: 12),
                )
              ],
            ),
          ),
          Tab(
            child: Row(
              children: [
                Icon(
                  SolarIconsBold.heart,
                  size: Dimens.DIMENS_16,
                ),
                SizedBox(
                  width: Dimens.DIMENS_3,
                ),
                Text(
                  LocaleKeys.label_likes.tr().toUpperCase(),
                  style: TextStyle(fontSize: 12),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Row _followBtn(
      UserRepository userRepository,
      User userData,
      ThemeData theme,
      AuthState authState,
      AuthRepository authRepository,
      BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: FutureBuilder<bool>(
              future: userRepository.isFollowing(userData.id),
              builder: (context, AsyncSnapshot<bool> snapshot) {
                bool? isFollowing = snapshot.data;
                if (!snapshot.hasData) {
                  return Container(
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
                      ),
                    ),
                  );
                }

                return BlocBuilder<FollowCubit, FollowState>(
                  builder: (context, state) {
                    debugPrint('follow state $state');
                    if (state.status == BlocStatus.following) {
                      isFollowing = true;
                    } else if (state.status == BlocStatus.notFollowing) {
                      isFollowing = false;
                    } else {
                      isFollowing = isFollowing;
                    }

                    return Material(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      color: isFollowing!
                          ? theme.colorScheme.tertiary
                          : theme.colorScheme.onTertiary,
                      child: InkWell(
                        onTap: () {
                          if (isFollowing! &&
                              authState.status == AuthStatus.authenticated) {
                            showDialog(
                                context: context,
                                builder: (_) {
                                  return AlertDialog(
                                    title:
                                        Text(LocaleKeys.message_unfollow.tr()),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          context.pop();
                                        },
                                        child:
                                            Text(LocaleKeys.label_cancel.tr()),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          BlocProvider.of<FollowCubit>(context)
                                              .followButtonHandle(
                                                  currentUserUid: authRepository
                                                      .currentUser!.uid,
                                                  uid: widget.userDaata?.id ??
                                                      authState.user!.id,
                                                  stateFromDatabase:
                                                      isFollowing!);
                                          context.pop();
                                        },
                                        child: Text(LocaleKeys.label_oke.tr()),
                                      )
                                    ],
                                  );
                                });
                          } else if (!isFollowing! &&
                              authState.status == AuthStatus.authenticated) {
                            BlocProvider.of<FollowCubit>(context)
                                .followButtonHandle(
                                    currentUserUid:
                                        authRepository.currentUser!.uid,
                                    uid: userData.id,
                                    stateFromDatabase: isFollowing!);
                          } else {
                            showAuthBottomSheetFunc(context);
                          }
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: Dimens.DIMENS_30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(5)),
                          child: Text(
                            isFollowing!
                                ? LocaleKeys.label_following.tr()
                                : LocaleKeys.label_follow.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: theme.colorScheme.secondary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
        ),
        SizedBox(
          width: Dimens.DIMENS_6,
        ),
        Material(
          color: theme.colorScheme.tertiary,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () async {
              if (authState.status == AuthStatus.authenticated) {
                User user = await userRepository
                    .getOtherUserData(widget.userDaata?.id ?? userData.id);
                types.User otherUser = types.User(
                    id: user.id,
                    createdAt:
                        user.createdAt!.toDate().millisecondsSinceEpoch ~/ 1000,
                    firstName: user.userName);
                if (!mounted) return;

                // final navigator = Navigator.of(context);
                final room =
                    await FirebaseChatCore.instance.createRoom(otherUser);

                if (!context.mounted) return;
                context.go(
                  '${APP_PAGE.message.toPath}/${user.userName}',
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
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimens.DIMENS_15),
                child: Text(
                  LocaleKeys.label_message.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: Dimens.DIMENS_12,
        ),
      ],
    );
  }

  Row _editProfileBtn(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: Dimens.DIMENS_12,
        ),
        Expanded(
          flex: 2,
          child: Material(
            color: Theme.of(context).colorScheme.tertiary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: Dimens.DIMENS_12,
        ),
      ],
    );
  }

  bool _isShowMenuBtn(AuthRepository authRepository, AuthState authState) =>
      authRepository.currentUser?.uid == widget.userDaata?.id ||
      widget.userDaata == null;

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
      context.go('${APP_PAGE.menu.toPath}${APP_PAGE.editProfile.toPath}');
    }
    isToEditProfile = false;
  }

  Theme gameFavView(String uid) {
    UserRepository repository = RepositoryProvider.of<UserRepository>(context);
    return Theme(
      data: Theme.of(context).copyWith(
        useMaterial3: false,
      ),
      child: SizedBox(
        width: 400,
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
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                      label: Text(
                                        LocaleKeys.label_see_less
                                            .tr()
                                            .replaceAll('.', ''),
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ),
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
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                visualDensity:
                                                    VisualDensity.compact,
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

  Widget bioSectionView({required String uid}) {
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
                  return BlocBuilder<ProfileCubit, ProfileState>(
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
                      return ExpandableText(text: bio!);
                      return LayoutBuilder(builder: (context, constraints) {
                        String text = bio!;
                        final textPainter = TextPainter(
                          text: TextSpan(
                            text: text,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w400),
                          ),
                          textDirection: TextDirection.ltr,
                        );
                        textPainter.layout(maxWidth: 300);
                        final lines = (textPainter.size.height /
                                textPainter.preferredLineHeight)
                            .ceil();

                        debugPrint('text is overflow  ${lines > 5}');

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bio!,
                              overflow: TextOverflow.ellipsis,
                              maxLines: maxLines,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.8),
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
                            SizedBox(
                              height: Dimens.DIMENS_5,
                            )
                          ],
                        );
                      });
                    },
                  );
                },
              );
            });
      },
    );
  }

  /// username,photo ,follwers,folowing,likes
  SliverToBoxAdapter topSectionView(
    AuthState authState,
    User userData,
  ) {
    final repository = RepositoryProvider.of<UserRepository>(context);
    final authRepository = RepositoryProvider.of<AuthRepository>(context);
    final userRepository = RepositoryProvider.of<UserRepository>(context);
    debugPrint("current user uid ${authRepository.currentUser?.uid}");
    return SliverToBoxAdapter(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: Dimens.DIMENS_12,
          ),
          Container(
            alignment: Alignment.center,
            width: 260,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamBuilder<String>(
                  stream: repository.getAvatar(userData.id),
                  builder: (context, snapshot) {
                    String? avatar = snapshot.data;
                    if (!snapshot.hasData || snapshot.hasError) {
                      return CircleAvatar(
                        backgroundColor: COLOR_grey,
                        radius: 70,
                      );
                    }
                    return CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                      radius: 70,
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
                                    errorWidget: (_, __, ___) => Container(
                                      width: 300,
                                      height: 300,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                    ),
                                  ),
                                );
                              });
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    userData.userName!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  SizedBox(
                    width: Dimens.DIMENS_20,
                  ),
                  if ((userData.id) == firebaseAuth.currentUser?.uid)
                    SizedBox(
                        width: 140, height: 34, child: _editProfileBtn(context))
                  // SizedBox(width: 200,height: 20, child: Text('edit'))
                  else
                    _followBtn(userRepository, userData, Theme.of(context),
                        authState, authRepository, context),
                ],
              ),
              SizedBox(
                height: Dimens.DIMENS_18,
              ),
              Row(
                children: [
                  _followerCountView(repository, userData),
                  const SizedBox(
                    width: 30,
                  ),
                  _follwoingCountView(repository, userData),
                  const SizedBox(
                    width: 30,
                  ),
                  _likesCountView(repository, userData),
                ],
              ),
              SizedBox(
                height: Dimens.DIMENS_12,
              ),
              _buildUserName(
                  userData.userName ?? LocaleKeys.label_user_name.tr()),
              bioSectionView(uid: userData.id),
              SizedBox(
                height: Dimens.DIMENS_6,
              ),
              gameFavView(userData.id),
            ],
          ),
          SizedBox(
            width: Dimens.DIMENS_12,
          ),
        ],
      ),
    );
  }

  BlocBuilder<AuthBloc, AuthState> _likesCountView(
      UserRepository repository, User userData) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (_, state) {
        return FutureBuilder<int>(
            initialData: 0,
            future:
                repository.getLikesCount(widget.userDaata?.id ?? userData.id),
            builder: (context, AsyncSnapshot<int> snapshot) {
              int likes = snapshot.data!;
              String likeCount = numberFormat(context.locale, likes);
              return Row(
                children: [
                  Text(
                    likeCount,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(
                    width: Dimens.DIMENS_3,
                  ),
                  Text(
                    LocaleKeys.label_likes.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w100,
                      color:
                          Theme.of(context).colorScheme.onSurface.withOpacity(
                                0.8,
                              ),
                    ),
                  ),
                ],
              );
            });
      },
    );
  }

  BlocBuilder<AuthBloc, AuthState> _follwoingCountView(
      UserRepository repository, User userData) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return FutureBuilder<int>(
            initialData: 0,
            future: repository
                .getFollowingCount(widget.userDaata?.id ?? userData.id),
            builder: (_, AsyncSnapshot<int> snapshot) {
              int following = snapshot.data!;
              String followingCount = numberFormat(context.locale, following);
              return InkWell(
                splashColor: Colors.transparent,
                overlayColor: const MaterialStatePropertyAll<Color>(
                  Colors.transparent,
                ),
                onTap: () {
                  showFollowDialog(
                    context,
                    userName: userData.userName!,
                    initialIndex: 1,
                  );
                },
                child: Row(
                  children: [
                    Text(
                      followingCount,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    SizedBox(
                      width: Dimens.DIMENS_3,
                    ),
                    Text(
                      LocaleKeys.label_following.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w100,
                        color:
                            Theme.of(context).colorScheme.onSurface.withOpacity(
                                  0.75,
                                ),
                      ),
                    ),
                  ],
                ),
              );
            });
      },
    );
  }

  BlocBuilder<AuthBloc, AuthState> _followerCountView(
      UserRepository repository, User userData) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return FutureBuilder<int>(
            initialData: 0,
            future: repository
                .getFollowerCount(widget.userDaata?.id ?? userData.id),
            builder: (context, AsyncSnapshot<int> snapshot) {
              int? follwers = snapshot.data;
              String followerCount = numberFormat(context.locale, follwers!);
              return InkWell(
                splashColor: Colors.transparent,
                overlayColor: const MaterialStatePropertyAll<Color>(
                  Colors.transparent,
                ),
                onTap: () {
                  showFollowDialog(context,
                      userName: userData.userName!, initialIndex: 0);
                  // context.push(APP_PAGE.followingNFonllowers.toPath,
                  //     extra: FollowingNFollowersData(
                  //         initialIndex: 0,
                  //         userName: widget.userDaata?.userName ??
                  //             userData.userName!,
                  //         uid: widget.userDaata?.id ?? userData.id));
                },
                child: Row(
                  children: [
                    Text(
                      followerCount,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    SizedBox(
                      width: Dimens.DIMENS_3,
                    ),
                    Text(
                      LocaleKeys.label_followers.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w100,
                        color:
                            Theme.of(context).colorScheme.onSurface.withOpacity(
                                  0.75,
                                ),
                      ),
                    ),
                  ],
                ),
              );
            });
      },
    );
  }

  void _showFollowDialog(
    BuildContext context, {
    required User userData,
    required int initialIndex,
  }) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          width: 800,
          child: FollowingsNFollowers(
            tab: initialIndex == 0 ? 'followers' : 'following',
            userName: userData.userName!,
          ),
        ),
      ),
    );
  }

  Widget _buildUserName(String userName) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return BlocBuilder<EditUserNameCubit, EditUserNameState>(
          builder: (context, state) {
            if (state.status == EditUserNameStatus.success &&
                widget.userDaata == null) {
              return Text(
                '@$userName',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              );
            }
            return Text(
              userName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            );
          },
        );
      },
    );
  }
}

class VideoListView extends StatelessWidget {
  final String uid;
  final From from;
  const VideoListView({
    super.key,
    required this.uid,
    required this.from,
  });

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
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context)
                        .copyWith(scrollbars: false),
                    child: PagedGridView<int, String>(
                      pagingController: state.controller!,
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(top: 4),
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
                          return SizedBox(
                            width: 300,
                            height: 400,
                            child: AspectRatio(
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
                                          padding:
                                              EdgeInsets.all(Dimens.DIMENS_18),
                                          child: Text(
                                            LocaleKeys
                                                .message_video_not_available_or_deleted
                                                .tr(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall,
                                          ));
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
                            ),
                          );
                        },
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: 9 / 16,
                        crossAxisCount: 3,
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
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
