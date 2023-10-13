part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

final class Authenticated extends AuthState {}

final class NotAuthenticated extends AuthState {}

final class LoginProcessing extends AuthState {}
final class LoginFailed extends AuthState {}
final class NoInternet extends AuthState {}

final class AuthError extends AuthState {
  final String error;
  const AuthError(this.error);

  @override
  List<Object> get props => [error];
}
