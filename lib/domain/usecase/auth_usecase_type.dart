abstract class AuthUseCaseType {
  /// Starts the Sign In with Google Flow.
  ///
  Future<void> logInWithGoogle();

  /// Signs out the current user which will emit
  /// [User.empty] from the [user] Stream.
  ///
  /// Throws a [LogOutFailure] if an exception occurs.
  Future<void> logOut();
}
