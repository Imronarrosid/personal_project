import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/domain/reporsitory/camera_repository.dart';
import 'package:personal_project/domain/services/app/app_service.dart';
import 'package:personal_project/domain/services/auth/auth_service.dart';
import 'package:personal_project/firebase_options.dart';
import 'package:personal_project/presentation/l10n/l10n.dart';
import 'package:personal_project/presentation/router/app_router.dart';
import 'package:personal_project/presentation/ui/home/home.dart';
import 'package:personal_project/presentation/ui/upload/bloc/camera_bloc.dart';
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
    cameras = await availableCameras();
    await appService.onAppStart();
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
        return BlocProvider<CameraBloc>(
          create: (context) => CameraBloc(),
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            title: "Gametok",
            routeInformationProvider: goRouter.routeInformationProvider,
            routeInformationParser: goRouter.routeInformationParser,
            routerDelegate: goRouter.routerDelegate,
          ),
        );
      }),
    );
  }
}
