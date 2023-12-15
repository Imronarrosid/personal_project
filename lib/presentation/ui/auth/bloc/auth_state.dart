part of 'auth_bloc.dart';

enum AuthStatus {
  authenticated,
  notAuthenticated,
  loading,
  error,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final String? uid, name, userName, photoURL;
  final String? error;
  const AuthState({
    this.error,
    this.uid,
    this.name,
    this.userName,
    this.photoURL,
    required this.status,
  });

  @override
  List<Object?> get props => [status, uid, name, userName, photoURL];
}

// final class Authenticated extends AuthState {
//   final String uid;

//   const Authenticated({required this.uid});

//   @override
//   // TODO: implement props
//   List<Object> get props => [uid];
// }

// final class NotAuthenticated extends AuthState {}

// final class LoginProcessing extends AuthState {}

// final class LoginFailed extends AuthState {}

// final class NoInternet extends AuthState {}

// final class AuthError extends AuthState {
//   final String error;
//   const AuthError(this.error);

//   @override
//   List<Object> get props => [error];
// }
