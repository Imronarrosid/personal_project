import 'package:personal_project/domain/model/user.dart';

abstract class UserUseCaseType {
  /// Retrieve user data by UID
  Future<Map<String, dynamic>> getUserData(String uid);

  Future<void> followUser({required String currentUserUid, required String uid});

  Future<List<String>> getUserVideoThumnails(String uid);
}
