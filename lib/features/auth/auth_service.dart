import 'package:firebase_auth/firebase_auth.dart';

enum SignInResult {
  success,
  userNotFound,
  wrongPassword,
  networkError,
}

enum SignUpResult {
  success,
  emailAlreadyInUse,
  networkError,
}

class AuthService {
  const AuthService({required this.firebase});

  final FirebaseAuth firebase;

  User? get currentUser => firebase.currentUser;

  bool get isSignedIn => currentUser != null;

  Stream<bool> get isSignedInStream =>
      firebase.authStateChanges().map((user) => user != null);

  Future<void> signOut() => firebase.signOut();

  Future<SignInResult> signInWithEmail(
      {required String email, required String password}) async {
    try {
      await firebase.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return SignInResult.success;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return SignInResult.userNotFound;
        case 'wrong-password':
          return SignInResult.wrongPassword;
        default:
          return SignInResult.networkError;
      }
    }
  }

  Future<SignUpResult> signUpWithEmail(
      {required String email, required String password}) async {
    try {
      await firebase.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return SignUpResult.success;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return SignUpResult.emailAlreadyInUse;
        default:
          return SignUpResult.networkError;
      }
    }
  }
}
