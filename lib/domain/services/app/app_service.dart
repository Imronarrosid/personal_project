import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:personal_project/presentation/l10n/locale_code.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: non_constant_identifier_names
String LOGIN_KEY = "5FD6G46SDF4GD64F1VG9SD68";
// ignore: non_constant_identifier_names
String ONBOARD_KEY = "GD2G82CG9G82VDFGVD22DVG";

class AppService with ChangeNotifier {
  late final SharedPreferences sharedPreferences;
  bool _loginState = false;
  bool _initialized = false;
  bool _onboarding = false;
  String _locale = LOCALE.id.code;

  AppService(this.sharedPreferences);

  bool get loginState => _loginState;
  bool get initialized => _initialized;
  bool get onboarding => _onboarding;
  String get getAppLocale => _locale;

  void setAppLocale(LOCALE locale) {
    String code = LOCALE.id.code;
    switch (locale) {
      case LOCALE.id:
        code = LOCALE.id.code;
        break;
      case LOCALE.en:
        code = LOCALE.en.code;
        break;
      default:
    }
    sharedPreferences.setString('locale', code);
    _locale = code;
  }

  set loginState(bool state) {
    sharedPreferences.setBool(LOGIN_KEY, state);
    _loginState = state;
    notifyListeners();
  }

  set initialized(bool value) {
    _initialized = value;
    notifyListeners();
  }

  /// if value is true onboarding not appear
  set onboarding(bool value) {
    sharedPreferences.setBool(ONBOARD_KEY, value);
    _onboarding = value;
    notifyListeners();
  }

  Future<void> onAppStart() async {
    _onboarding = sharedPreferences.getBool(ONBOARD_KEY) ?? false;
    _loginState = sharedPreferences.getBool(LOGIN_KEY) ?? false;
    _locale = sharedPreferences.getString('locale') ?? LOCALE.id.code;

    // This is just to demonstrate the splash screen is working.
    // In real-life applications, it is not recommended to interrupt the user experience by doing such things.
    await Future.delayed(const Duration(seconds: 2));

    _initialized = true;
    notifyListeners();
  }

  void saveSelectedGamefav(List<String> gameFav) {
    sharedPreferences.setStringList('gameFav', gameFav);
  }

  List<String> getAllSelectedGameFav() {
    return sharedPreferences.getStringList('gameFav') ?? <String>[];
  }
}
