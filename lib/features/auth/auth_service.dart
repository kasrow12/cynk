import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum AuthResult {
  success,
  invalidEmail,
  userNotFound,
  wrongPassword,
  networkError,
  popupClosedByUser,
  weakPassword,
  emailAlreadyInUse,
}

class AuthService {
  const AuthService({required this.firebase});

  final FirebaseAuth firebase;

  User? get currentUser => firebase.currentUser;

  bool get isSignedIn => currentUser != null;

  Stream<bool> get isSignedInStream =>
      firebase.authStateChanges().map((user) => user != null);

  Future<void> signOut() => firebase.signOut();

  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await firebase.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return AuthResult.success;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return AuthResult.invalidEmail;
        case 'user-not-found':
          return AuthResult.userNotFound;
        case 'wrong-password':
          return AuthResult.wrongPassword;
        default:
          return AuthResult.networkError;
      }
    }
  }

  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await firebase.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return AuthResult.success;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return AuthResult.emailAlreadyInUse;
        case 'weak-password':
          return AuthResult.weakPassword;
        case 'invalid-email':
          return AuthResult.invalidEmail;
        default:
          return AuthResult.networkError;
      }
    }
  }

  Future<AuthResult> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn(
        clientId:
            '410051796583-knb1m6u2jdt4h979skrtu7892a38foac.apps.googleusercontent.com',
      ).signIn();

      final googleAuth = await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      await firebase.signInWithCredential(credential);

      return AuthResult.success;
    } catch (err) {
      if (err.toString() == 'popup_closed') {
        return AuthResult.popupClosedByUser;
      }
      return AuthResult.networkError;
    }
  }
}
