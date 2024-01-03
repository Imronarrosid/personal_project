import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_project/domain/model/chat_data_models.dart';
import 'package:personal_project/domain/model/following_n_followers_data_model.dart';
import 'package:personal_project/domain/model/game_fav_modal.dart';
import 'package:personal_project/domain/model/preview_model.dart';
import 'package:personal_project/domain/model/profile_data_model.dart';
import 'package:personal_project/domain/model/video_from_game_data_model.dart';
import 'package:personal_project/domain/model/video_model.dart';
import 'package:personal_project/domain/reporsitory/search_repository.dart';
import 'package:personal_project/domain/reporsitory/video_repository.dart';
import 'package:personal_project/domain/services/app/app_service.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:personal_project/presentation/ui/add_details/add_details_page.dart';
import 'package:personal_project/presentation/ui/add_details/select_game/bloc/search_game_bloc.dart';
import 'package:personal_project/presentation/ui/add_details/select_game/cubit/select_game_cubit.dart';
import 'package:personal_project/presentation/ui/add_details/select_game/select_game_page.dart';
import 'package:personal_project/presentation/ui/add_user_name/add_user_name_page.dart';
import 'package:personal_project/presentation/ui/chat/chat_page.dart';
import 'package:personal_project/presentation/ui/edit_profile/edit_page/edit_game_fav_page.dart';
import 'package:personal_project/presentation/ui/followings_n_followers/followings_n_followers.dart';
import 'package:personal_project/presentation/ui/language/language_page.dart';
import 'package:personal_project/presentation/ui/play_single_video/play_single.dart';
import 'package:personal_project/presentation/ui/profile_pict_preview/profile_pict_preview.dart';
import 'package:personal_project/presentation/ui/edit_profile/edit_page/edit_name_page.dart';
import 'package:personal_project/presentation/ui/edit_profile/edit_profile.dart';
import 'package:personal_project/presentation/ui/home/home.dart';
import 'package:personal_project/presentation/ui/onboarding/onboarding.dart';
import 'package:personal_project/presentation/ui/profile/profile.dart';
import 'package:personal_project/presentation/ui/menu/menu_page.dart';
import 'package:personal_project/presentation/ui/storage/storage_page.dart';
import 'package:personal_project/presentation/ui/ugf/ugf_page.dart';
import 'package:personal_project/presentation/ui/upload/upload.dart';
import 'package:personal_project/presentation/ui/video/list_video/video_item.dart';
import 'package:personal_project/presentation/ui/video_editor/video_editor_page.dart';
import 'package:personal_project/presentation/ui/video_from_game/video_from_game_page.dart';
import 'package:personal_project/presentation/ui/video_preview/video_previe_page.dart';
import 'package:personal_project/utils/generate_string.dart';
import 'package:uuid/v1.dart';

class AppRouter {
  late final AppService appService;
  GoRouter get router => _goRouter;

  AppRouter(this.appService);

  late final GoRouter _goRouter = GoRouter(
    refreshListenable: appService,
    routerNeglect: true,
    debugLogDiagnostics: true,
    initialLocation: appService.onboarding
        ? APP_PAGE.home.toPath
        : APP_PAGE.onBoarding.toPath,
    routes: <GoRoute>[
      GoRoute(
          path: APP_PAGE.home.toPath,
          name: APP_PAGE.home.toName,
          builder: (context, state) => const HomePage(),
          routes: []),
      // GoRoute(
      //   path: APP_PAGE.splash.toPath,
      //   name: APP_PAGE.splash.toName,
      //   builder: (context, state) => const SplashPage(),
      // ),
      // GoRoute(
      //   path: APP_PAGE.login.toPath,
      //   name: APP_PAGE.login.toName,
      //   builder: (context, state) => const LogInPage(),
      // ),
      GoRoute(
        path: APP_PAGE.upload.toPath,
        name: APP_PAGE.upload.toName,
        pageBuilder: (context, state) {
          final List<CameraDescription> camera =
              state.extra as List<CameraDescription>;
          return MaterialPage(
              child: UploadPage(
            cameras: camera,
          ));
        },
      ),
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
      GoRoute(
          path: APP_PAGE.videoEditor.toPath,
          name: APP_PAGE.videoEditor.toName,
          pageBuilder: (context, state) {
            XFile file = state.extra as XFile;
            return MaterialPage(
                child: VideoEditor(
              file: file,
            ));
          }),
      GoRoute(
          path: APP_PAGE.addDetails.toPath,
          name: APP_PAGE.addDetails.toName,
          pageBuilder: (context, state) {
            File videoFile = state.extra as File;
            return MaterialPage(
              child: AddDetailsPage(
                videoFile: videoFile,
              ),
            );
          }),

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
          path: APP_PAGE.followingNFonllowers.toPath,
          name: APP_PAGE.followingNFonllowers.toName,
          builder: (context, state) {
            FollowingNFollowersData data =
                state.extra as FollowingNFollowersData;
            return FollowingsNFollowers(
              data: data,
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
        path: APP_PAGE.profile.toPath,
        name: APP_PAGE.profile.toName,
        builder: (context, state) {
          ProfilePayload data = state.extra as ProfilePayload;
          return ProfilePage(
            payload: data,
            isForOtherUser: true,
          );
        },
        pageBuilder: (context, state) {
          ProfilePayload data = state.extra as ProfilePayload;
          return CustomTransitionPage(
            child: ProfilePage(
              payload: data,
              isForOtherUser: true,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    SlideTransition(
                        position: animation.drive(
                          Tween<Offset>(
                            begin: Offset(0.75, 0),
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
        path: APP_PAGE.editProfile.toPath,
        name: APP_PAGE.editProfile.toName,
        builder: (context, state) {
          return const EditProfile();
        },
      ),
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
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
                  position: animation.drive(
                    Tween<Offset>(
                      begin: Offset(0.75, 0),
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
        path: APP_PAGE.chat.toPath,
        name: APP_PAGE.chat.toName,
        pageBuilder: (context, state) {
          final ChatData data = state.extra as ChatData;
          return CustomTransitionPage(
            child: ChatPage(data: data),
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
          final ChatData data = state.extra as ChatData;
          return ChatPage(
            data: data,
          );
        },
      ),
      GoRoute(
        path: APP_PAGE.videoItem.toPath,
        name: APP_PAGE.videoItem.toName,
        pageBuilder: (context, state) {
          Video videoData = state.extra as Video;
          return CustomTransitionPage(
            child: PlaySingleVideoPage(videoData: videoData),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    SlideTransition(
                        position: animation.drive(
                          Tween<Offset>(
                            begin: Offset(0.75, 0),
                            end: Offset.zero,
                          ).chain(
                            CurveTween(curve: Curves.ease),
                          ),
                        ),
                        child: child),
          );
        },
        builder: (context, state) {
          Video videoData = state.extra as Video;
          return PlaySingleVideoPage(videoData: videoData);
        },
      ),
      GoRoute(
        path: APP_PAGE.videoFromGame.toPath,
        name: APP_PAGE.videoFromGame.toName,
        pageBuilder: (context, state) {
          final VideoFromGameData data = state.extra as VideoFromGameData;
          return CustomTransitionPage(
            child: VideoFromGamePage(data: data),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    SlideTransition(
                        position: animation.drive(
                          Tween<Offset>(
                            begin: Offset(0.75, 0),
                            end: Offset.zero,
                          ).chain(
                            CurveTween(curve: Curves.ease),
                          ),
                        ),
                        child: child),
          );
        },
        builder: (context, state) {
          final VideoFromGameData data = state.extra as VideoFromGameData;
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
            child: SelectGamePage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    SlideTransition(
                        position: animation.drive(
                          Tween<Offset>(
                            begin: Offset(0.75, 0),
                            end: Offset.zero,
                          ).chain(
                            CurveTween(curve: Curves.ease),
                          ),
                        ),
                        child: child),
          );
        },
        builder: (context, state) {
          return SelectGamePage();
        },
      ),
      GoRoute(
        path: APP_PAGE.menu.toPath,
        name: APP_PAGE.menu.toName,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            child: const MenuPage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    SlideTransition(
                        position: animation.drive(
                          Tween<Offset>(
                            begin: Offset(0.75, 0),
                            end: Offset.zero,
                          ).chain(
                            CurveTween(curve: Curves.ease),
                          ),
                        ),
                        child: child),
          );
        },
        builder: (context, state) {
          return const MenuPage();
        },
      ),
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
                            begin: Offset(0.75, 0),
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
      // GoRoute(
      //   path: APP_PAGE.editName.toPath,
      //   name: APP_PAGE.editName.toName,
      //   builder: (context, state) {
      //     EditNameData data = state.extra as EditNameData;
      //     return EditName(
      //       data: data,
      //     );
      //   },
      // ),

      // GoRoute(
      //   path: APP_PAGE.error.toPath,
      //   name: APP_PAGE.error.toName,
      //   builder: (context, state) => ErrorPage(error: state.extra.toString()),
      // ),
    ],
    // errorBuilder: (context, state) => ErrorPage(error: state.error.toString()),
  );
}
