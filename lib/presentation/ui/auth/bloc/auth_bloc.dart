import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:personal_project/domain/model/user.dart';
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this.authRepository)
      : super(authRepository.currentUser != null
            ? Authenticated()
            : NotAuthenticated()) {
    on<LogInWithGoogle>((event, emit) async {
      try {
        authRepository.logInWithGoogle();
      } catch (e) {
        debugPrint(e.toString());
      }

      bool isGoogleUserNotEmpty = await authRepository.isGoogleUserNotEmpty;
      debugPrint('isGooleUserIsempty $isGoogleUserNotEmpty');
      if (isGoogleUserNotEmpty) {
        emit(LoginProcessing());
      }
      bool isAuthenticated = await authRepository.isAuthenticated;
      debugPrint('isAuthenticated $isAuthenticated');
      if (isAuthenticated) {
        emit(Authenticated());
      }
    });
  }
  final AuthRepository authRepository;
}
