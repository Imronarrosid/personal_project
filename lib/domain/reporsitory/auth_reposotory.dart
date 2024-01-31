import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:personal_project/domain/model/user.dart';
import 'package:personal_project/domain/services/firebase/firebase_service.dart';
import 'package:personal_project/domain/usecase/auth_usecase_type.dart';
import 'package:personal_project/utils/generate_string.dart';

class LogInWithGoogleFailure implements Exception {
  /// {@macro log_in_with_google_failure}
  const LogInWithGoogleFailure([
    this.message = 'An unknown exception occurred.',
  ]);

  /// Create an authentication message
  /// from a firebase authentication exception code.
  factory LogInWithGoogleFailure.fromCode(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return const LogInWithGoogleFailure(
          'Account exists with different credentials.',
        );
      case 'invalid-credential':
        return const LogInWithGoogleFailure(
          'The credential received is malformed or has expired.',
        );
      case 'operation-not-allowed':
        return const LogInWithGoogleFailure(
          'Operation is not allowed.  Please contact support.',
        );
      case 'user-disabled':
        return const LogInWithGoogleFailure(
          'This user has been disabled. Please contact support for help.',
        );
      case 'user-not-found':
        return const LogInWithGoogleFailure(
          'Email is not found, please create an account.',
        );
      case 'wrong-password':
        return const LogInWithGoogleFailure(
          'Incorrect password, please try again.',
        );
      case 'invalid-verification-code':
        return const LogInWithGoogleFailure(
          'The credential verification code received is invalid.',
        );
      case 'invalid-verification-id':
        return const LogInWithGoogleFailure(
          'The credential verification ID received is invalid.',
        );
      case 'network-request-failed':
        return const LogInWithGoogleFailure(
          'Network error',
        );
      default:
        return const LogInWithGoogleFailure();
    }
  }

  /// The associated error message.
  final String message;
}

class AuthRepository implements AuthUseCaseType {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  static final Completer<bool> _googleUserCompleter = Completer<bool>();
  static final Completer<bool> _createUserCompleter = Completer<bool>();
  static final Completer<bool> _authCompleter = Completer<bool>();
  static final Completer<bool> _isUserFirstLogin = Completer<bool>();

  Future<bool> get isGoogleUserNotEmpty => _googleUserCompleter.future;
  Future<bool> get isAuthenticated => _authCompleter.future;
  Future<bool> get isUserCreated => _createUserCompleter.future;
  Future<bool> get isUserFirstLogin => _isUserFirstLogin.future;

  /// Return [User] data created on firebase firestore
  ///
  /// Need to assign on log in.
  User? _createdUser;

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

  /// Return [User] data created on firebase firestore
  User? get createdUser => _createdUser;

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
    final String userName = _createUserName(user.name!);
    if (!doc.exists) {
      _isUserFirstLogin.complete(true);
      await firestore.collection('users').doc(user.id).set({
        'uid': user.id,
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'name': user.name,
        'userName': userName,
        'photoUrl': user.photo,
        'lastSeen': FieldValue.serverTimestamp(),
        'metadata': user.metadata,
        'role': user.role?.toShortString(),
        'nameUpdatedAt': FieldValue.serverTimestamp(),
        'userNameUpdatedAt': FieldValue.serverTimestamp()
      });
      await _storeUserName(userName);
      await _storeAvatar(user.photo!);
    } else {
      _isUserFirstLogin.complete(false);
    }
  }

  Future<void> _storeAvatar(String downloaUrl) async {
    await firebaseFirestore
        .collection('avatars')
        .doc(firebaseAuth.currentUser!.uid)
        .set({'avatar': downloaUrl});
  }

  Future<void> _storeUserName(String userName) async {
    await firebaseFirestore
        .collection('userNames')
        .doc(currentUser!.uid)
        .set({'userName': userName});
  }

  String _createUserName(String userName) {
    return '${userName.replaceAll(RegExp(r"\s\b|\b\s"), "")}_${generateRandomString(10)}';
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

        firebase_auth.User? user = currentUser;

        if (user != null) {
          _authCompleter.complete(true);
          User newUser =
              User(id: user.uid, name: user.displayName, email: user.email, photo: user.photoURL);

          // Store user data to firebase if [user.uid] not exist.

          await _createUser(newUser);

          listenForDocumentCreation(user.uid);
        } else {
          _authCompleter.complete(false);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
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

  Future<User> getUserData(String uid) async {
    DocumentSnapshot docs = await firebaseFirestore.collection('users').doc(uid).get();
    return User.fromSnap(docs);
  }

  Future<bool> isAdmin(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> doc =
        await firebaseFirestore.collection('users').doc(uid).get();

    var data = doc.data();
    if (data!.containsKey('role') && data['role'] == 'admin') {
      return true;
    }

    return false;
  }

  Future<void> addGameFav(String gameTitle, File image) async {
    Reference ref = firebaseStorage.ref().child('gameFavorites').child('Pict $gameTitle');
    UploadTask uploadTask = ref.putFile(image);
    TaskSnapshot snapshot = await uploadTask;
    String gameImage = await snapshot.ref.getDownloadURL();
    await firebaseFirestore
        .collection('gameFavorites')
        .doc(gameTitle)
        .set({'title': gameTitle, 'icon': gameImage});
  }

  void listenForDocumentCreation(String uid) {
    // Replace 'your_collection' and 'your_document_id' with your actual collection and document ID
    DocumentReference documentReference = FirebaseFirestore.instance.collection('users').doc(uid);

    // Create a real-time listener
    StreamSubscription? subscription;
    subscription = documentReference.snapshots().listen((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        print('qwerty Document created or modified!');
        // Do something with the document data if needed
        print('qwerty Document data: ${snapshot.data()}');

        _createdUser = User.fromSnap(snapshot);

        // Perform cleanup and stop listening
        if (_createdUser != null) {
          _createUserCompleter.complete(true);
          subscription!.cancel();
        }
      } else {
        print('qwerty Document does not exist yet...');
      }
    }, onError: (error) {
      print('Error listening for document changes: $error');
    });
  }
}

extension on firebase_auth.User {
  /// Maps a [firebase_auth.User] into a [User].
  User get toUser {
    return User(id: uid, email: email, userName: displayName, photo: photoURL);
  }
}

extension RoleToShortString on Role {
  /// Converts enum to the string equal to enum's name.
  String toShortString() => toString().split('.').last;
}
