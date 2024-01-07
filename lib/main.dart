import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_project/config/theme.dart';
import 'package:personal_project/data/repository/chat_repository.dart';
import 'package:personal_project/data/repository/file_repository.dart';
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';
import 'package:personal_project/domain/reporsitory/user_repository.dart';
import 'package:personal_project/domain/reporsitory/video_repository.dart';
import 'package:personal_project/domain/services/app/app_service.dart';
import 'package:personal_project/domain/services/auth/auth_service.dart';
import 'package:personal_project/firebase_options.dart';
import 'package:personal_project/presentation/l10n/l10n.dart';
import 'package:personal_project/presentation/router/app_router.dart';
import 'package:personal_project/presentation/ui/add_details/bloc/upload_bloc.dart';
import 'package:personal_project/presentation/ui/add_details/select_game/cubit/select_game_cubit.dart';
import 'package:personal_project/presentation/ui/auth/bloc/auth_bloc.dart';
import 'package:personal_project/presentation/ui/edit_profile/cubit/edit_bio_cubit.dart';
import 'package:personal_project/presentation/ui/edit_profile/cubit/edit_name_cubit.dart';
import 'package:personal_project/presentation/ui/edit_profile/cubit/edit_profile_pict_cubit.dart';
import 'package:personal_project/presentation/ui/edit_profile/cubit/edit_user_name_cubit.dart';
import 'package:personal_project/presentation/ui/edit_profile/cubit/game_fav_cubit.dart';
import 'package:personal_project/presentation/ui/language/cubit/language_cubit.dart';
import 'package:personal_project/presentation/ui/upload/bloc/camera_bloc.dart';
import 'package:personal_project/presentation/ui/video_preview/bloc/video_preview_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();

  runApp(EasyLocalization(
      supportedLocales: L10n.all,
      path: 'assets/strings/l10n',
      fallbackLocale: const Locale('id'),
      useFallbackTranslations: true,
      child: MyApp(
        sharedPreferences: sharedPreferences,
      )));
}

class MyApp extends StatefulWidget {
  final SharedPreferences sharedPreferences;
  const MyApp({
    super.key,
    required this.sharedPreferences,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  late AppService appService;
  late AuthService authService;
  late List<CameraDescription> cameras;

  @override
  void initState() {
    appService = AppService(widget.sharedPreferences);
    authService = AuthService();
    onStartUp();
    super.initState();
  }

  void onStartUp() async {
    await appService.onAppStart();
    debugPrint('onboard:${appService.onboarding}');
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppService>(create: (_) => appService),
        Provider<AppRouter>(create: (_) => AppRouter(appService)),
        Provider<AuthService>(create: (_) => authService),
      ],
      child: Builder(builder: (context) {
        final GoRouter goRouter =
            Provider.of<AppRouter>(context, listen: false).router;

        return MultiRepositoryProvider(
          providers: [
            RepositoryProvider(
              create: (context) => AuthRepository(),
            ),
            RepositoryProvider(
              create: (context) => VideoRepository(),
            ),
            RepositoryProvider(
              create: (context) => FileRepository(),
            ),
            RepositoryProvider(
              create: (context) => UserRepository(),
            ),
            RepositoryProvider(
              create: (context) => ChatRepository(),
            )
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider<CameraBloc>(
                create: (context) => CameraBloc(),
              ),
              BlocProvider(
                create: (context) => VideoPreviewBloc(),
              ),
              BlocProvider(
                create: (context) {
                  final AuthRepository repo =
                      RepositoryProvider.of<AuthRepository>(context);

                  return AuthBloc(repo)..add(InitAuth());
                },
              ),
              BlocProvider(
                create: (context) => UploadBloc(
                  RepositoryProvider.of<VideoRepository>(context),
                ),
              ),
              BlocProvider(
                create: (context) {
                  final UserRepository userRepository =
                      RepositoryProvider.of<UserRepository>(context);
                  return EditNameCubit(userRepository);
                },
              ),
              BlocProvider(create: (context) {
                final UserRepository repository =
                    RepositoryProvider.of<UserRepository>(context);
                return EditBioCubit(repository);
              }),
              BlocProvider(create: (context) {
                final UserRepository userRepository =
                    RepositoryProvider.of<UserRepository>(context);
                return EditUserNameCubit(userRepository);
              }),
              BlocProvider(create: (context) {
                final UserRepository userRepository =
                    RepositoryProvider.of<UserRepository>(context);
                return EditProfilePictCubit(userRepository);
              }),
              BlocProvider(
                create: (context) {
                  final UserRepository userRepository =
                      RepositoryProvider.of<UserRepository>(context);
                  return GameFavCubit(userRepository);
                },
                child: Container(),
              ),
              BlocProvider(create: (_) => LanguageCubit()),
              BlocProvider(
                create: (context) => SelectGameCubit(),
              )
            ],
            child: MaterialApp.router(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.darkTheme,
              locale: context.locale,
              supportedLocales: context.supportedLocales,
              localizationsDelegates: context.localizationDelegates,
              title: "Gametok",
              routeInformationProvider: goRouter.routeInformationProvider,
              routeInformationParser: goRouter.routeInformationParser,
              routerDelegate: goRouter.routerDelegate,
            ),
          ),
        );
      }),
    );
  }
}
