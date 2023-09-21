import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/firebase_options.dart';
import 'package:personal_project/presentation/l10n/l10n.dart';
import 'package:personal_project/presentation/ui/home/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);

  runApp(EasyLocalization(
      supportedLocales: L10n.all,
      path: 'assets/strings/l10n',
      fallbackLocale: const Locale('id'),
      useFallbackTranslations: true,
      child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: COLOR_black_ff121212),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
