import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:personal_project/domain/model/user.dart';
import 'package:personal_project/domain/usecase/auth_usecase_type.dart';

class AuthRepository implements AuthUseCaseType {
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  static final Completer<bool> _googleUserCompleter = Completer<bool>();
  Future<bool> isGoogleUserNotEmpty = _googleUserCompleter.future;


  static final Completer<bool> _authCompleter = Completer<bool>();
  Future<bool> isAuthenticated = _authCompleter.future;

  /// Whether or not the current environment is web
  /// Should only be overridden for testing purposes. Otherwise,
  /// defaults to [kIsWeb]
  @visibleForTesting
  bool isWeb = kIsWeb;

  /// User cache key.
  /// Should only be used for testing purposes.
  @visibleForTesting
  static const userCacheKey = '__user_cache_key__';

  /// Stream of [User] which will emit the current user when
  /// the authentication state changes.
  ///
  /// Emits [User.empty] if the user is not authenticated.
  Stream<User> get user {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      final user = firebaseUser == null ? User.empty : firebaseUser.toUser;
      // _cache.write(key: userCacheKey, value: user);
      return user;
    });
  }

  /// Returns the current user.
  firebase_auth.User? get currentUser {
    firebase_auth.User? user = firebase_auth.FirebaseAuth.instance.currentUser;
    return user;
  }

  // Creates a new user with the provided [email] and [password].
  //
  // Throws a [SignUpWithEmailAndPasswordFailure] if an exception occurs.
  // Future<void> signUp({required String email, required String password}) async {
  //   try {
  //     await _firebaseAuth.createUserWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //   } on firebase_auth.FirebaseAuthException catch (e) {
  //     throw SignUpWithEmailAndPasswordFailure.fromCode(e.code);
  //   } catch (_) {
  //     throw const SignUpWithEmailAndPasswordFailure();
  //   }
  // }

  /// Store user to firestore
  Future _createUser(User user) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    var doc = await firestore.collection('users').doc(user.id).get();
    if (!doc.exists) {
      firestore.collection('users').doc(user.id).set(user.toJson());
    }
  }

  @override
  Future<void> logInWithGoogle() async {
    try {
      late final firebase_auth.AuthCredential credential;
      if (isWeb) {
        final googleProvider = firebase_auth.GoogleAuthProvider();
        final userCredential = await _firebaseAuth.signInWithPopup(
          googleProvider,
        );
        credential = userCredential.credential!;
      }

      final googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        _googleUserCompleter.complete(true);

        final googleAuth = await googleUser.authentication;
        credential = firebase_auth.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await _firebaseAuth.signInWithCredential(credential);
        _authCompleter.complete(true);

        firebase_auth.User? user = currentUser;

        User newUser = User(
            id: user!.uid,
            userName: user.displayName,
            email: user.email,
            photo: user.photoURL);

        // Store user data to firebase if [user.uid] not exist.

        await _createUser(newUser);
      }
    } on PlatformException catch (e) {
      throw e.toString();
    }
  }

  /// Signs in with the provided [email] and [password].
  ///
  /// Throws a [LogInWithEmailAndPasswordFailure] if an exception occurs.
  // Future<void> logInWithEmailAndPassword({
  //   required String email,
  //   required String password,
  // }) async {
  //   try {
  //     await _firebaseAuth.signInWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //   } on firebase_auth.FirebaseAuthException catch (e) {
  //     throw LogInWithEmailAndPasswordFailure.fromCode(e.code);
  //   } catch (_) {
  //     throw const LogInWithEmailAndPasswordFailure();
  //   }
  // }

  @override
  Future<void> logOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint(e.toString());
    }
  }
}

extension on firebase_auth.User {
  /// Maps a [firebase_auth.User] into a [User].
  User get toUser {
    return User(id: uid, email: email, userName: displayName, photo: photoURL);
  }
}
