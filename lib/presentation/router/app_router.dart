import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_project/data/repository/chat_repository.dart';
import 'package:personal_project/data/repository/vide_from_categories.dart';
import 'package:personal_project/domain/model/add_details_model.dart';
import 'package:personal_project/domain/model/category_model.dart';
import 'package:personal_project/domain/model/chat_data_models.dart';
import 'package:personal_project/domain/model/chat_payload_model.dart';
import 'package:personal_project/domain/model/following_n_followers_data_model.dart';
import 'package:personal_project/domain/model/game_fav_modal.dart';
import 'package:personal_project/domain/model/play_single_data.dart';
import 'package:personal_project/domain/model/profile_data_model.dart';
import 'package:personal_project/domain/model/user.dart';
import 'package:personal_project/domain/model/video_from_game_data_model.dart';
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';
import 'package:personal_project/domain/reporsitory/user_repository.dart';
import 'package:personal_project/domain/services/app/app_service.dart';
import 'package:personal_project/domain/services/firebase/firebase_service.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/responsive/dimension.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:personal_project/presentation/shared_components/handel_back_button.dart';
import 'package:personal_project/presentation/shared_components/not_authenticated_page.dart';
import 'package:personal_project/presentation/ui/add_details/add_details_page.dart';
import 'package:personal_project/presentation/ui/add_details/select_game/select_game_page.dart';
import 'package:personal_project/presentation/ui/add_user_name/add_user_name_page.dart';
import 'package:personal_project/presentation/ui/chat/chat_page.dart';
import 'package:personal_project/presentation/ui/dummy/dummy.dart';
import 'package:personal_project/presentation/ui/edit_profile/edit_page/edit_game_fav_page.dart';
import 'package:personal_project/presentation/ui/followings_n_followers/followings_n_followers.dart';
import 'package:personal_project/presentation/ui/language/language_page.dart';
import 'package:personal_project/presentation/ui/mabar/mabar_page.dart';
import 'package:personal_project/presentation/ui/menu/responsive/menu_page_mobile.dart';
import 'package:personal_project/presentation/ui/message/message.dart';
import 'package:personal_project/presentation/ui/play_single_video/play_single.dart';
import 'package:personal_project/presentation/ui/profile_pict_preview/profile_pict_preview.dart';
import 'package:personal_project/presentation/ui/edit_profile/edit_profile.dart';
import 'package:personal_project/presentation/ui/home/home.dart';
import 'package:personal_project/presentation/ui/onboarding/onboarding.dart';
import 'package:personal_project/presentation/ui/profile/profile.dart';
import 'package:personal_project/presentation/ui/menu/menu_page.dart';
import 'package:personal_project/presentation/ui/search/search.dart';
import 'package:personal_project/presentation/ui/search_room/search_room_page.dart';
import 'package:personal_project/presentation/ui/select_cover/select_cover_page.dart';
import 'package:personal_project/presentation/ui/storage/storage_page.dart';
import 'package:personal_project/presentation/ui/ugf/ugf_page.dart';
import 'package:personal_project/presentation/ui/upload/drop_zon.dart';
import 'package:personal_project/presentation/ui/upload/upload.dart';
import 'package:personal_project/presentation/ui/video/video.dart';
import 'package:personal_project/presentation/ui/video_editor/video_editor_page.dart';
import 'package:personal_project/presentation/ui/video_from_categories/video_from_categories.dart';
import 'package:personal_project/presentation/ui/video_from_game/video_from_game_page.dart';
import 'package:personal_project/presentation/ui/video_preview/video_previe_page.dart';
import 'package:solar_icons/solar_icons.dart';

import '../shared_components/keep_alive_page.dart';
import '../ui/chat/chat.dart';
import '../ui/chat/chat_test/chat_test.dart';
import '../ui/edit_profile/cubit/edit_user_name_cubit.dart';
import '../ui/home/navbar_notifier/navbar_notifier.dart';
import '../ui/message/responsive/message_desktop.dart';

class AppRouter {
  late final AppService appService;
  int _pageIndex = 0;
  GoRouter get router => _goRouter;

  static final List<String> _routeHistory = [];

  List<String> get routeHistory => [..._routeHistory];

  AppRouter(this.appService);
  final _rootNavigatorKey = GlobalKey<NavigatorState>();
  final _shellNavigatorKey = GlobalKey<NavigatorState>();

  void onBackButtonPressed(BuildContext context) {
    if (_routeHistory.length > 1) {
      if (_routeHistory[_routeHistory.length - 2].contains('/upload') &&
          _routeHistory[_routeHistory.length - 3].contains('/upload')) {
        context.go(_routeHistory[_routeHistory.length - 4]);
        _routeHistory.removeRange(
            _routeHistory.length - 3, _routeHistory.length - 1);
      }
      context.go(_routeHistory[_routeHistory.length - 2]);
      _routeHistory.removeLast();
    }
  }

  late final GoRouter _goRouter = GoRouter(
      refreshListenable: appService,
      routerNeglect: true,
      debugLogDiagnostics: true,
      initialLocation: appService.onboarding
          ? APP_PAGE.forYou.toPath
          : APP_PAGE.onBoarding.toPath,
      redirect: (context, state) {
        if (state.fullPath == APP_PAGE.home.toPath) {
          return APP_PAGE.forYou.toPath;
        }
        return null;
      },
      routes: [
        GoRoute(
          path: APP_PAGE.home.toPath,
          redirect: (context, state) => APP_PAGE.forYou.toPath,
        ),
        StatefulShellRoute.indexedStack(
          restorationScopeId: 'app',
          builder: (context, state, child) {
            manageRoute(context);

            return HomePage(pageIndex: _pageIndex, child: child);
          },

          branches: [
            // GoRoute(
            //   path: APP_PAGE.home.toPath,
            //   name: APP_PAGE.home.toName,
            //   builder: (context, state) => HomePage(
            //     key: UniqueKey(),
            //   ),
            // ),
            // // GoRoute(
            // //   path: APP_PAGE.splash.toPath,
            // //   name: APP_PAGE.splash.toName,
            // //   builder: (context, state) => const SplashPage(),
            // // ),
            // // GoRoute(
            // //   path: APP_PAGE.login.toPath,
            // //   name: APP_PAGE.login.toName,
            // //   builder: (context, state) => const LogInPage(),
            // // ),
            StatefulShellBranch(restorationScopeId: 'route', routes: [
              GoRoute(
                path: APP_PAGE.search.toPath,
                name: APP_PAGE.search.toName,
                builder: (context, state) {
                  return const SearchPage();
                },
              ),
              GoRoute(
                  path: '${APP_PAGE.category.toPath}/:category',
                  name: APP_PAGE.category.toName,
                  pageBuilder: (context, state) {
                    return MaterialPage(
                      child: VideoFromCategories(
                        key: ValueKey(state.pathParameters['category']),
                        category: state.pathParameters['category'] ?? '',
                      ),
                    );
                  }),
              GoRoute(
                  path: '/@:username',
                  // builder: (context, state) {
                  //   ProfilePayload data = state.extra as ProfilePayload;
                  //   return ProfilePage(
                  //     payload: data,
                  //   );
                  // },
                  pageBuilder: (context, state) {
                    String? usrename = state.pathParameters['username'];

                    return CustomTransitionPage(
                      key: state.pageKey,
                      child: KeepAlivePage(
                        key: state.pageKey,
                        child:
                            BlocBuilder<EditUserNameCubit, EditUserNameState>(
                          builder: (context, editUserNameState) {
                            return ProfilePage(
                              key: state.pageKey,
                              userName: editUserNameState.status ==
                                      EditUserNameStatus.success
                                  ? editUserNameState.newUserName!
                                  : usrename!,
                            );
                          },
                        ),
                      ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) =>
                              SlideTransition(
                                  position: animation.drive(
                                    Tween<Offset>(
                                      begin: const Offset(0.75, 0),
                                      end: Offset.zero,
                                    ).chain(
                                      CurveTween(curve: Curves.ease),
                                    ),
                                  ),
                                  child: child),
                    );
                  },
                  routes: [
                    GoRoute(
                      path: APP_PAGE.search.toPath.replaceAll('/', ''),
                      // name: APP_PAGE.search.toName,
                      builder: (context, state) {
                        return const SearchPage();
                      },
                    ),
                  ]),
            ]),
            // StatefulShellBranch(routes: [
            //   GoRoute(
            //     path: APP_PAGE.upload.toPath,
            //     name: APP_PAGE.upload.toName,
            //     pageBuilder: (context, state) {
            //       final List<CameraDescription> camera =
            //           state.extra as List<CameraDescription>;
            //       return MaterialPage(
            //           child: UploadPage(
            //         cameras: camera,
            //       ));
            //     },
            //   ),
            // ]),
            StatefulShellBranch(restorationScopeId: 'app', routes: [
              GoRoute(
                  path: APP_PAGE.videoPreview.toPath,
                  name: APP_PAGE.videoPreview.toName,
                  pageBuilder: (context, state) {
                    File previewData = state.extra as File;
                    return MaterialPage(
                        child: VideoPreviewPage(
                      previewData: previewData,
                    ));
                  }),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: APP_PAGE.forYou.toPath,
                name: APP_PAGE.forYou.toName,
                pageBuilder: (context, state) {
                  return const NoTransitionPage(child: VideoPage());
                },
              ),
              GoRoute(
                  path: APP_PAGE.lobby.toPath,
                  name: APP_PAGE.lobby.toName,
                  pageBuilder: (context, state) {
                    return const NoTransitionPage(child: ChatTest());
                  }),
              GoRoute(
                path: '/dm/:username',
                onExit: (context, state) async {
                  context
                      .read<NavbarNotifier>()
                      .chnageNavbarState(NavbarState.show);

                  context.read<ChatRepository>().setChatPayload = null;
                  context.read<ChatRepository>().messagesLists.clear();
                  return true;
                },
                pageBuilder: (context, state) {
                  final ChatPayload? data = state.extra as ChatPayload? ??
                      context.read<ChatRepository>().chatPayload;
                  if (data != null) {
                    context.read<ChatRepository>().setChatPayload = data;
                  }
                  return NoTransitionPage(
                    child: ChatScreen(
                      data: data!,
                      key: ValueKey(state.pathParameters['username']),
                    ),
                  );
                },
              ),
              GoRoute(
                path: APP_PAGE.upload.toPath,
                builder: (_, __) {
                  return const DropZonePage();
                },
                routes: [
                  GoRoute(
                      path: APP_PAGE.videoEditor.toPath.replaceAll('/', ''),
                      name: APP_PAGE.videoEditor.toName,
                      pageBuilder: (context, state) {
                        XFile? file = state.extra as XFile?;
                        return MaterialPage(
                            child: VideoEditor(
                          file: file,
                        ));
                      }),
                  GoRoute(
                      path: APP_PAGE.addDetails.toPath.replaceAll('/', ''),
                      redirect: (context, state) {
                        if (state.fullPath ==
                                APP_PAGE.upload.toPath +
                                    APP_PAGE.addDetails.toPath &&
                            state.extra == null) {
                          return APP_PAGE.upload.toPath +
                              APP_PAGE.videoEditor.toPath;
                        }
                        return null;
                      },
                      pageBuilder: (context, state) {
                        AddDetails data = state.extra as AddDetails;
                        return MaterialPage(
                          child: AddDetailsPage(
                            data: data,
                          ),
                        );
                      }),
                ],
              ),
              GoRoute(
                path: APP_PAGE.onBoarding.toPath,
                name: APP_PAGE.onBoarding.toName,
                builder: (context, state) => const OnBoardingPage(),
              ),
              GoRoute(
                path: APP_PAGE.addGameFav.toPath,
                name: APP_PAGE.addGameFav.toName,
                builder: (context, state) => const UGFPage(),
              ),
              GoRoute(
                  path: APP_PAGE.editGameFav.toPath,
                  name: APP_PAGE.editGameFav.toName,
                  builder: (context, state) {
                    List<GameFav> games = state.extra as List<GameFav>;
                    return EditGameFavPage(
                      gameFav: games,
                    );
                  }),
              GoRoute(
                  path: APP_PAGE.addUserName.toPath,
                  name: APP_PAGE.addUserName.toName,
                  builder: (context, state) {
                    String userName = state.extra as String;
                    return AddUserNamePage(
                      userName: userName,
                    );
                  }),
              GoRoute(
                path: APP_PAGE.editProfile.toPath,
                name: APP_PAGE.editProfile.toName,
                redirect: (context, state) {
                  if (firebaseAuth.currentUser == null) {
                    return APP_PAGE.forYou.toPath;
                  }
                  return null;
                },
                builder: (context, state) {
                  return const EditProfile();
                },
              ),
              GoRoute(
                  path: '${APP_PAGE.following.toPath}/:username',
                  name: APP_PAGE.following.toName,
                  builder: (context, state) {
                    return FollowingsNFollowers(
                      key: state.pageKey,
                      userName:
                          GoRouterState.of(context).pathParameters['username']!,
                      tab: 'following',
                    );
                  }),
              GoRoute(
                  path: '${APP_PAGE.followers.toPath}/:username',
                  name: APP_PAGE.followers.toName,
                  builder: (context, state) {
                    return FollowingsNFollowers(
                      key: state.pageKey,
                      userName:
                          GoRouterState.of(context).pathParameters['username']!,
                      tab: 'followers',
                    );
                  }),
              // GoRoute(
              //   path: APP_PAGE.chat.toPath,
              //   redirect: (context, state) {
              //     final ChatData? data = state.extra as ChatData?;
              //     if (data == null) {
              //       return APP_PAGE.message.toPath;
              //     }
              //     return null;
              //   },
              //   pageBuilder: (context, state) {
              //     final ChatData? data = state.extra as ChatData?;
              //     return CustomTransitionPage(
              //       child: ChatPage(data: data!),
              //       transitionsBuilder:
              //           (context, animation, secondaryAnimation, child) =>
              //               SlideTransition(
              //                   position: animation.drive(
              //                     Tween<Offset>(
              //                       begin: const Offset(0.75, 0),
              //                       end: Offset.zero,
              //                     ).chain(
              //                       CurveTween(curve: Curves.ease),
              //                     ),
              //                   ),
              //                   child: child),
              //     );
              //   },
              //   builder: (context, state) {
              //     final ChatData data = state.extra as ChatData;
              //     return ChatPage(
              //       data: data,
              //     );
              //   },
              // ),
              GoRoute(
                path: APP_PAGE.cropImage.toPath,
                name: APP_PAGE.cropImage.toName,
                builder: (context, state) {
                  XFile profileData = state.extra as XFile;
                  return PrevewProfilePictPage(imageFile: profileData);
                },
              ),
              GoRoute(
                path: APP_PAGE.cachesPage.toPath,
                name: APP_PAGE.cachesPage.toName,
                pageBuilder: (context, state) => CustomTransitionPage(
                  child: const CachesPage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          SlideTransition(
                              position: animation.drive(
                                Tween<Offset>(
                                  begin: const Offset(0.75, 0),
                                  end: Offset.zero,
                                ).chain(
                                  CurveTween(curve: Curves.ease),
                                ),
                              ),
                              child: child),
                ),
                builder: (context, state) {
                  return const CachesPage();
                },
              ),
              GoRoute(
                path: APP_PAGE.searchRoom.toPath,
                name: APP_PAGE.searchRoom.toName,
                pageBuilder: (context, state) {
                  return CustomTransitionPage(
                    child: const SearchRoomPage(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) =>
                            SlideTransition(
                                position: animation.drive(
                                  Tween<Offset>(
                                    begin: const Offset(0.75, 0),
                                    end: Offset.zero,
                                  ).chain(
                                    CurveTween(curve: Curves.ease),
                                  ),
                                ),
                                child: child),
                  );
                },
                builder: (context, state) {
                  return const SearchRoomPage();
                },
              ),
              GoRoute(
                path: '${APP_PAGE.videoItem.toPath}/:postId',
                name: APP_PAGE.videoItem.toName,
                pageBuilder: (context, state) {
                  final PlaySingleData? extra = state.extra as PlaySingleData?;
                  return CustomTransitionPage(
                    child: PlaySingleVideoPage(
                        key: ValueKey(state.pathParameters['postId']),
                        data: extra),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) =>
                            SlideTransition(
                                position: animation.drive(
                                  Tween<Offset>(
                                    begin: const Offset(0.75, 0),
                                    end: Offset.zero,
                                  ).chain(
                                    CurveTween(curve: Curves.ease),
                                  ),
                                ),
                                child: child),
                  );
                },
              ),
              GoRoute(
                path: APP_PAGE.videoFromGame.toPath,
                name: APP_PAGE.videoFromGame.toName,
                pageBuilder: (context, state) {
                  final VideoFromGameData data =
                      state.extra as VideoFromGameData;
                  return CustomTransitionPage(
                    child: VideoFromGamePage(data: data),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) =>
                            SlideTransition(
                                position: animation.drive(
                                  Tween<Offset>(
                                    begin: const Offset(0.75, 0),
                                    end: Offset.zero,
                                  ).chain(
                                    CurveTween(curve: Curves.ease),
                                  ),
                                ),
                                child: child),
                  );
                },
                builder: (context, state) {
                  final VideoFromGameData data =
                      state.extra as VideoFromGameData;
                  return VideoFromGamePage(
                    data: data,
                  );
                },
              ),
              GoRoute(
                path: APP_PAGE.selectGame.toPath,
                name: APP_PAGE.selectGame.toName,
                pageBuilder: (context, state) {
                  return CustomTransitionPage(
                    child: const SelectGamePage(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) =>
                            SlideTransition(
                                position: animation.drive(
                                  Tween<Offset>(
                                    begin: const Offset(0.75, 0),
                                    end: Offset.zero,
                                  ).chain(
                                    CurveTween(curve: Curves.ease),
                                  ),
                                ),
                                child: child),
                  );
                },
                builder: (context, state) {
                  return const SelectGamePage();
                },
              ),
              GoRoute(
                  path: APP_PAGE.menu.toPath,
                  name: APP_PAGE.menu.toName,
                  redirect: (context, state) {
                    if (state.uri.path == '/settings') {
                      if (MediaQuery.of(context).size.width > mobileWidth) {
                        if (firebaseAuth.currentUser != null) {
                          return '${APP_PAGE.menu.toPath}${APP_PAGE.editProfile.toPath}';
                        }
                        return '${APP_PAGE.menu.toPath}${APP_PAGE.login.toPath}';
                      }
                      return APP_PAGE.menu.toPath;
                    }
                    return null;
                  },
                  pageBuilder: (context, state) {
                    return const NoTransitionPage(
                      child: MenuPageMobile(),
                    );
                  },
                  // pageBuilder: (context, state) {
                  //   return CustomTransitionPage(
                  //     child: const MenuPage(),
                  //     transitionsBuilder:
                  //         (context, animation, secondaryAnimation, child) =>
                  //             SlideTransition(
                  //                 position: animation.drive(
                  //                   Tween<Offset>(
                  //                     begin: const Offset(0.75, 0),
                  //                     end: Offset.zero,
                  //                   ).chain(
                  //                     CurveTween(curve: Curves.ease),
                  //                   ),
                  //                 ),
                  //                 child: child),
                  //   );
                  // },
                  // builder: (context, state) {
                  //   return const MenuPage();
                  // },
                  routes: [
                    ShellRoute(
                        pageBuilder: (context, state, child) {
                          String routeName = GoRouter.of(context)
                              .routeInformationProvider
                              .value
                              .uri
                              .path;
                          int menuIndex = 0;
                          if (routeName == '/settings/login') {
                            menuIndex = 0;
                          } else if (routeName == '/settings/language') {
                            menuIndex = 1;
                          } else if (routeName == '/settings/caches') {
                            menuIndex = 2;
                          }
                          debugPrint(menuIndex.toString() + routeName);
                          return NoTransitionPage(
                            child: MenuPage(index: menuIndex, child: child),
                          );
                        },
                        routes: [
                          GoRoute(
                            redirect: (context, state) {
                              return null;
                            },
                            path:
                                APP_PAGE.editProfile.toPath.replaceAll('/', ''),
                            // name: APP_PAGE.editProfile.toName,
                            builder: (context, state) {
                              return const EditProfile();
                            },
                          ),
                          GoRoute(
                            path: 'language',
                            pageBuilder: (context, state) {
                              return const NoTransitionPage(
                                  child: LanguagePage());
                            },
                          ),
                          GoRoute(
                            path: 'caches',
                            pageBuilder: (context, state) {
                              return const NoTransitionPage(
                                  child: CachesPage());
                            },
                          ),
                          GoRoute(
                            path: 'login',
                            pageBuilder: (context, state) {
                              return NoTransitionPage(
                                child: HandleBackButton(
                                  child: Scaffold(
                                      appBar: AppBar(
                                        title:
                                            Text(LocaleKeys.label_login.tr()),
                                      ),
                                      body: const NotAuthenticatedPage()),
                                ),
                              );
                            },
                          ),
                        ])
                  ]),
              // GoRoute(
              //     path: APP_PAGE.upload.toPath,
              //     name: APP_PAGE.upload.toName,
              //     redirect: (context, state) {
              //       if (state.fullPath == '/upload') {
              //         return '${APP_PAGE.menu.toPath}${APP_PAGE.login.toPath}';
              //       }
              //       return null;
              //     },
              //     pageBuilder: (context, state) {
              //       return NoTransitionPage(child: Container());
              //     },
              //     routes: [
              //       ShellRoute(
              //           pageBuilder: (context, state, child) {
              //             String routeName = GoRouter.of(context)
              //                 .routeInformationProvider
              //                 .value
              //                 .uri
              //                 .path;
              //             int menuIndex = 0;
              //             if (routeName == '/settings/login') {
              //               menuIndex = 0;
              //             } else if (routeName == '/settings/language') {
              //               menuIndex = 1;
              //             } else if (routeName == '/settings/caches') {
              //               menuIndex = 2;
              //             }
              //             debugPrint(menuIndex.toString() + routeName);
              //             return NoTransitionPage(
              //               child: MenuPage(index: menuIndex, child: child),
              //             );
              //           },
              //           routes: [
              //             GoRoute(
              //               path: 'video-editor',
              //               pageBuilder: (context, state) {
              //                 return const NoTransitionPage(
              //                     child: LanguagePage());
              //               },
              //             ),
              //             GoRoute(
              //               path: 'caches',
              //               pageBuilder: (context, state) {
              //                 return const NoTransitionPage(
              //                     child: CachesPage());
              //               },
              //             ),
              //             GoRoute(
              //               path: 'login',
              //               pageBuilder: (context, state) {
              //                 return const NoTransitionPage(
              //                   child: NotAuthenticatedPage(),
              //                 );
              //               },
              //             ),
              //           ])
              //     ]),
              GoRoute(
                path: APP_PAGE.languagePage.toPath,
                name: APP_PAGE.languagePage.toName,
                pageBuilder: (context, state) {
                  return CustomTransitionPage(
                    child: const LanguagePage(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) =>
                            SlideTransition(
                                position: animation.drive(
                                  Tween<Offset>(
                                    begin: const Offset(0.75, 0),
                                    end: Offset.zero,
                                  ).chain(
                                    CurveTween(curve: Curves.ease),
                                  ),
                                ),
                                child: child),
                  );
                },
                builder: (context, state) {
                  return const LanguagePage();
                },
              ),
              GoRoute(
                path: APP_PAGE.selectCover.toPath,
                name: APP_PAGE.selectCover.toName,
                builder: (context, state) {
                  XFile data = state.extra as XFile;
                  return SelectCover(
                    file: data,
                  );
                },
              ),
              GoRoute(
                path: APP_PAGE.profile.toPath,
                name: APP_PAGE.profile.toName,
                pageBuilder: (context, state) => NoTransitionPage(
                  child: Scaffold(
                      appBar: AppBar(
                        title: Text(LocaleKeys.title_profile.tr()),
                      ),
                      body: const NotAuthenticatedPage()),
                ),
              ),
            ]),
            StatefulShellBranch(routes: [
              _messageRoute(),
            ]),
            StatefulShellBranch(
                navigatorKey: GlobalKey<NavigatorState>(),
                routes: [
                  GoRoute(
                    path: '/dummy',
                    builder: (context, state) => Container(),
                  ),
                ]),
          ],
          // errorBuilder: (context, state) => ErrorPage(error: state.error.toString()),
        ),
      ]);

  GoRoute _messageRoute() {
    return GoRoute(
        path: APP_PAGE.message.toPath,
        name: APP_PAGE.message.toName,
        redirect: (context, state) {
          if (state.uri.path ==
                  APP_PAGE.message.toPath + APP_PAGE.chat.toPath ||
              state.uri.path == APP_PAGE.message.toPath) {
            if (MediaQuery.of(context).size.width < mobileWidth) {
              return APP_PAGE.message.toPath;
            } else if (MediaQuery.of(context).size.width < mediumWidth) {
              return APP_PAGE.message.toPath;
            } else if (MediaQuery.of(context).size.width > mediumWidth) {
              return APP_PAGE.message.toPath + APP_PAGE.chat.toPath;
            }
          }
          // if (state.uri.path == APP_PAGE.message.toPath) {
          //   if (MediaQuery.of(context).size.width > mobileWidth) {
          //     return APP_PAGE.message.toPath + APP_PAGE.chat.toPath;
          //   } else {
          //     return APP_PAGE.message.toPath;
          //   }
          // }
          return null;
        },
        pageBuilder: (context, state) {
          return const NoTransitionPage(child: MessagePage());
        },
        routes: [
          ShellRoute(
              builder: (context, state, child) {
                return MessageDesktop(
                  child: child,
                );
              },
              routes: [
                GoRoute(
                  path: APP_PAGE.chat.toPath.replaceAll('/', ''),
                  pageBuilder: (context, state) => NoTransitionPage(
                    child: Scaffold(
                      body: Container(
                        alignment: Alignment.center,
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(SolarIconsOutline.chatRoundDots),
                            SizedBox(
                              width: 12,
                            ),
                            Text('Kirim pesan')
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                GoRoute(
                  path: ':username',
                  redirect: (context, state) {
                    final ChatPayload? data = state.extra as ChatPayload?;
                    if (data == null &&
                        context.read<ChatRepository>().chatPayload == null) {
                      return APP_PAGE.message.toPath + APP_PAGE.chat.toPath;
                    }
                    return null;
                  },
                  onExit: (context, state) async {
                    context.read<ChatRepository>().setChatPayload = null;

                    return true;
                  },
                  pageBuilder: (context, state) {
                    final ChatPayload? data = state.extra as ChatPayload?;
                    if (data != null) {
                      context.read<ChatRepository>().setChatPayload = data;
                    }
                    return CustomTransitionPage(
                      child: ChatScreen(
                        data: context.read<ChatRepository>().chatPayload!,
                        key: ValueKey(state.pathParameters['username']),
                      ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) =>
                              SlideTransition(
                                  position: animation.drive(
                                    Tween<Offset>(
                                      begin: const Offset(0.75, 0),
                                      end: Offset.zero,
                                    ).chain(
                                      CurveTween(curve: Curves.ease),
                                    ),
                                  ),
                                  child: child),
                    );
                  },
                ),
              ]),
        ]);
  }

  void manageRoute(BuildContext context) {
    final String routeName =
        GoRouter.of(context).routeInformationProvider.value.uri.path;

    LocationNotifier.instance.setCurrentLocation(routeName);

    if (_routeHistory.isEmpty) {
      _routeHistory.add(
        routeName,
      );
    }
    if (_routeHistory.isNotEmpty && _routeHistory.last != routeName) {
      _routeHistory.add(
        routeName,
      );
    }
    if (_routeHistory.contains(APP_PAGE.onBoarding.toPath)) {
      _routeHistory.remove(APP_PAGE.onBoarding.toPath);
    }
    debugPrint('rout history ${_routeHistory.length}');
    debugPrint('rout history ${_routeHistory.toString()}');

    if (APP_PAGE.forYou.toPath == routeName) {
      _pageIndex = 0;
    } else if (APP_PAGE.search.toPath == routeName) {
      _pageIndex = 1;
    } else if (routeName.contains(APP_PAGE.message.toPath)) {
      _pageIndex = 2;
    } else if (routeName == '/profile' ||
        (context.read<AuthRepository>().currentUserData != null &&
            routeName.contains(
                '/@${context.read<AuthRepository>().currentUserData?.userName}'))) {
      _pageIndex = 3;
    } else if (routeName.contains(APP_PAGE.upload.toPath)) {
      _pageIndex = 4;
    } else if (routeName.contains(APP_PAGE.lobby.toPath)) {
      _pageIndex = 5;
    }
  }
}

class LocationNotifier extends ChangeNotifier {
  static LocationNotifier instance = LocationNotifier();
  String? _currenLocation;
  String? get currentLocation => _currenLocation;

  setCurrentLocation(String? location) {
    _currenLocation = location;
    notifyListeners();
  }
}
