part of 'auth_bloc.dart';

enum AuthStatus {
  initial,
  authenticated,
  notAuthenticated,
  loading,
  error,
}

extension AuthStatusX on AuthStatus {
  bool get isInitial => this == AuthStatus.initial;
  bool get isAuthenticated => this == AuthStatus.authenticated;
  bool get isNotAuthenticated => this == AuthStatus.notAuthenticated;
  bool get isLoading => this == AuthStatus.loading;
  bool get isError => this == AuthStatus.error;
}

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? error;
  final bool? isUserFirstLogin;
  final bool? isNotiFy;
  const AuthState({
    this.isUserFirstLogin = false,
    this.isNotiFy = false,
    this.error,
    this.user,
    required this.status,
  });

  @override
  List<Object?> get props => [status, user, isUserFirstLogin, isNotiFy];
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
