import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_project/domain/model/user.dart';
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';
import 'package:personal_project/utils/check_network.dart';
import 'package:restart_app/restart_app.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this.authRepository)
      : super(const AuthState(status: AuthStatus.initial)) {
    on<InitAuth>((event, emit) async {
      emit(const AuthState(status: AuthStatus.loading));
      if (authRepository.currentUser != null) {
        String uid = authRepository.currentUser!.uid;
        User user = await authRepository.getUserData(uid);
        emit(AuthState(status: AuthStatus.authenticated, user: user));
      } else if (authRepository.currentUser == null) {
        emit(const AuthState(status: AuthStatus.notAuthenticated));
      }
    });
    on<LogInWithGoogle>((event, emit) async {
      try {
        authRepository.logInWithGoogle();
        bool isGoogleUserNotEmpty = await authRepository.isGoogleUserNotEmpty;
        debugPrint('isGooleUserIsempty $isGoogleUserNotEmpty');
        if (isGoogleUserNotEmpty) {
          emit(const AuthState(status: AuthStatus.loading, isNotiFy: true));
        }
        bool isAuthenticated = await authRepository.isAuthenticated;
        debugPrint('qwerty isAuthenticated $isAuthenticated');

        bool isUserCreated = await authRepository.isUserCreated;
        debugPrint('qwerty isusrcrtd $isUserCreated');
        bool isUserFirstLogin = await authRepository.isUserFirstLogin;
        debugPrint('qwerty isusrcrtdFIRST $isUserFirstLogin');

        if (isAuthenticated && isUserCreated) {
          // User user =
          //     await authRepository.getUserData(authRepository.currentUser!.uid);
          emit(AuthState(
              status: AuthStatus.authenticated,
              user: authRepository.createdUser!,
              isNotiFy: true,
              isUserFirstLogin: isUserFirstLogin));
        }
      } on LogInWithGoogleFailure catch (e) {
        debugPrint('Error$e');
        emit(AuthState(status: AuthStatus.error, error: e.toString()));
      } catch (_) {}
    });
    on<LogOut>((event, emit) async {
      await authRepository.logOut();
      Restart.restartApp();
      emit(const AuthState(status: AuthStatus.notAuthenticated));
    });
  }
  final AuthRepository authRepository;
}
