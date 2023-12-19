part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class InitAuth extends AuthEvent {
  @override
  List<Object> get props => [super.props];
}

class LogInWithGoogle extends AuthEvent {
  @override
  List<Object> get props => [];
}

class LogOut extends AuthEvent {
  @override
  List<Object> get props => [super.props];
}
