import 'package:shared_preferences/shared_preferences.dart';

class LocalData {
  const LocalData(this._sharedPreferences);
  final SharedPreferences _sharedPreferences;

  LocalData._privateConstructor(this._sharedPreferences);

  static LocalData? _instance;

  static void init(SharedPreferences sharedPreferences) {
    if (_instance != null) {
      throw StateError('LocalData is already initialized');
    }

    _instance = LocalData._privateConstructor(sharedPreferences);
  }

  static LocalData get instance {
    if (_instance == null) {
      throw StateError('LocalData is not initialized');
    }

    return _instance!;
  }

  void storeAudioPath({required String id, required String path}) {
    _sharedPreferences.setString(id, path);
  }

  String? getAudioPath(String id) {
    return _sharedPreferences.getString(id);
  }
}
