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
        await authRepository.logInWithGoogle().whenComplete(() {
          debugPrint('login completed');
          emit(Authenticated());
        });
      } catch (e) {
        debugPrint(e.toString());
      }

      if (authRepository.currentUser != null) {}
    });
  }
  final AuthRepository authRepository;
}
