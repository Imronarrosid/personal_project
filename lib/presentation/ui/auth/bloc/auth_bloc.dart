import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:personal_project/domain/model/user.dart' as model;
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';
import 'package:personal_project/utils/check_network.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this.authRepository)
      : super(authRepository.currentUser != null
            ? AuthState(
                status: AuthStatus.authenticated,
                uid: authRepository.currentUser!.uid)
            : const AuthState(status: AuthStatus.notAuthenticated)) {
    on<LogInWithGoogle>((event, emit) async {
      model.User user;
      try {
        authRepository.logInWithGoogle();
        bool isGoogleUserNotEmpty = await authRepository.isGoogleUserNotEmpty;
        debugPrint('isGooleUserIsempty $isGoogleUserNotEmpty');
        if (isGoogleUserNotEmpty) {
          emit(const AuthState(status: AuthStatus.loading));
        }
        bool isAuthenticated = await authRepository.isAuthenticated;
        debugPrint('isAuthenticated $isAuthenticated');
        if (isAuthenticated) {
          user = await authRepository
              .getVideoOwnerData(authRepository.currentUser!.uid);

          emit(AuthState(
              status: AuthStatus.authenticated,
              uid: authRepository.currentUser!.uid,
              name: user.name,
              userName: user.userName,
              photoURL: user.photo));
        } else {
          emit(const AuthState(status: AuthStatus.error));
        }
      } on LogInWithGoogleFailure catch (e) {
        debugPrint('Error$e');
        emit(AuthState(status: AuthStatus.error, error: e.toString()));
      } catch (_) {}
    });
  }
  final AuthRepository authRepository;
}
