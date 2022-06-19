import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../features/authentication/models/user_params.dart';
import '../services/base/failure.dart';

class AuthenticationRepository {
  AuthenticationRepository({
    required this.firebaseAuth,
    required this.firebaseFunctions,
    required this.googleSignIn,
  });

  final FirebaseAuth firebaseAuth;
  final FirebaseFunctions firebaseFunctions;
  final GoogleSignIn googleSignIn;

  User? get currentUser => firebaseAuth.currentUser;

  Future<void> register({required UserParams params}) async {
    try {
      final UserCredential _userCredential =
          await firebaseAuth.createUserWithEmailAndPassword(
        email: params.emailAddress,
        password: params.password,
      );

      // I'm not creating a new user on firestore and using this instead
      // because all I have to store is full name and the firebase auth user
      // object is faster to access
      _userCredential.user!.updateDisplayName(params.fullName);

      await _userCredential.user!.sendEmailVerification();
    } on FirebaseAuthException catch (ex) {
      throw Failure(ex.message ?? 'Something went wrong!');
    }
  }

  Future<void> login({
    required String emailAddress,
    required String password,
  }) async {
    try {
      final UserCredential _userCredential =
          await firebaseAuth.signInWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );

      if (!_userCredential.user!.emailVerified) {
        await firebaseAuth.signOut();
        throw Failure('Email is not verified');
      }
    } on FirebaseAuthException catch (ex) {
      throw Failure(ex.message ?? 'Something went wrong!');
    }
  }

  Future<User?> loginWithGoogle() async {
    final googleSignInAccount = await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final googleSignInAuth = await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuth.accessToken,
        idToken: googleSignInAuth.idToken,
      );

      try {
        final UserCredential _userCredential =
            await firebaseAuth.signInWithCredential(credential);

        return _userCredential.user;
      } on FirebaseAuthException catch (ex) {
        throw Failure(ex.message ?? 'Something went wrong!');
      }
    }
  }

  Future<void> resetPassword(String emailAddress) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: emailAddress);
    } on FirebaseAuthException catch (ex) {
      throw Failure(ex.message ?? 'Something went wrong!');
    }
  }

  Future<void> updateUser({required String fullName}) async {
    try {
      await currentUser?.updateDisplayName(fullName);
    } on FirebaseAuthException catch (ex) {
      throw Failure(ex.message ?? 'Something went wrong!');
    }
  }

  Future<void> updateEmail({
    required String newEmailAddress,
    required String password,
  }) async {
    try {
      final AuthCredential authCredential = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: password,
      );

      await currentUser?.reauthenticateWithCredential(authCredential);

      await currentUser?.updateEmail(newEmailAddress);

      await currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (ex) {
      throw Failure(ex.message ?? 'Something went wrong!');
    }
  }

  Future<void> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final AuthCredential authCredential = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: oldPassword,
      );

      await currentUser?.reauthenticateWithCredential(authCredential);

      await currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (ex) {
      throw Failure(ex.message ?? 'Something went wrong!');
    }
  }

  Future<String> deleteUser() async {
    try {
      final HttpsCallable callable = firebaseFunctions.httpsCallable(
        'deleteUserAccount',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 10)),
      );

      final result = await callable();

      logout();

      return result.data;
    } on FirebaseFunctionsException catch (ex) {
      throw Failure(ex.message ?? 'Something went wrong!');
    }
  }

  Future<void> logout() async {
    if (!kIsWeb) {
      await googleSignIn.signOut();
    }
    await firebaseAuth.signOut();
  }
}

final authenticationRepository = Provider(
  (ref) => AuthenticationRepository(
    firebaseAuth: FirebaseAuth.instance,
    firebaseFunctions: FirebaseFunctions.instance,
    googleSignIn: GoogleSignIn(),
  ),
);
