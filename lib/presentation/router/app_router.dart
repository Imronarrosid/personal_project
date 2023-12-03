import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_project/domain/model/game_fav_modal.dart';
import 'package:personal_project/domain/model/preview_model.dart';
import 'package:personal_project/domain/model/profile_data_model.dart';
import 'package:personal_project/domain/model/video_model.dart';
import 'package:personal_project/domain/reporsitory/video_repository.dart';
import 'package:personal_project/domain/services/app/app_service.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:personal_project/presentation/ui/add_details/add_details_page.dart';
import 'package:personal_project/presentation/ui/caches/caches_page.dart';
import 'package:personal_project/presentation/ui/edit_profile/edit_page/edit_game_fav_page.dart';
import 'package:personal_project/presentation/ui/play_single_video/play_single.dart';
import 'package:personal_project/presentation/ui/profile_pict_preview/profile_pict_preview.dart';
import 'package:personal_project/presentation/ui/edit_profile/edit_page/edit_name_page.dart';
import 'package:personal_project/presentation/ui/edit_profile/edit_profile.dart';
import 'package:personal_project/presentation/ui/home/home.dart';
import 'package:personal_project/presentation/ui/onboarding/onboarding.dart';
import 'package:personal_project/presentation/ui/profile/profile.dart';
import 'package:personal_project/presentation/ui/menu/menu_page.dart';
import 'package:personal_project/presentation/ui/ugf/ugf_page.dart';
import 'package:personal_project/presentation/ui/upload/upload.dart';
import 'package:personal_project/presentation/ui/video/list_video/video_item.dart';
import 'package:personal_project/presentation/ui/video_editor/video_editor_page.dart';
import 'package:personal_project/presentation/ui/video_preview/video_previe_page.dart';

class AppRouter {
  late final AppService appService;
  GoRouter get router => _goRouter;

  AppRouter(this.appService);

  late final GoRouter _goRouter = GoRouter(
    refreshListenable: appService,
    routerNeglect: true,
    debugLogDiagnostics: true,
    initialLocation: appService.onboarding
        ? APP_PAGE.onBoarding.toPath
        : APP_PAGE.home.toPath,
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
            PreviewData previewData = state.extra as PreviewData;
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
            ));
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
        path: APP_PAGE.profile.toPath,
        name: APP_PAGE.profile.toName,
        builder: (context, state) {
          String uid = state.extra as String;
          return ProfilePage(uid: uid);
        },
      ),
      GoRoute(
        path: APP_PAGE.editProfile.toPath,
        name: APP_PAGE.editProfile.toName,
        builder: (context, state) {
          ProfileData profileData = state.extra as ProfileData;
          return EditProfile(data: profileData);
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
        builder: (context, state) {
          return const CachesPage();
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
        path: APP_PAGE.menu.toPath,
        name: APP_PAGE.menu.toName,
        pageBuilder: (context, state) {
          String? imageUrl = state.extra as String?;
          return CustomTransitionPage(
            child: MenuPage(
              accImageUrl: imageUrl,
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
        builder: (context, state) {
          String? imageUrl = state.extra as String?;
          return MenuPage(accImageUrl: imageUrl);
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
