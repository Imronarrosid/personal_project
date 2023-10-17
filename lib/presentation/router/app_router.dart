import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_project/domain/model/preview_model.dart';
import 'package:personal_project/domain/services/app/app_service.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:personal_project/presentation/ui/add_details/add_details_page.dart';
import 'package:personal_project/presentation/ui/home/home.dart';
import 'package:personal_project/presentation/ui/onboarding/onboarding.dart';
import 'package:personal_project/presentation/ui/upload/upload.dart';
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

      // GoRoute(
      //   path: APP_PAGE.error.toPath,
      //   name: APP_PAGE.error.toName,
      //   builder: (context, state) => ErrorPage(error: state.extra.toString()),
      // ),
    ],
    // errorBuilder: (context, state) => ErrorPage(error: state.error.toString()),
  );
}
