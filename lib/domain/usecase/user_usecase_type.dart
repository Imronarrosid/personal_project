abstract class UserUseCaseType {
  // /// Retrieve user data by UID
  // Future<UserData> getUserData(String uid);

  Future<void> followUser(
      {required String currentUserUid, required String uid});

  Future<List<String>> getUserVideoThumnails(String uid);
}
