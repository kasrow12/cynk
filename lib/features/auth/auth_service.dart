import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum SignInResult {
  success,
  invalidEmail,
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
        case 'invalid-email':
          return SignInResult.invalidEmail;
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

  Future<SignInResult> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn(
      clientId:
          "410051796583-knb1m6u2jdt4h979skrtu7892a38foac.apps.googleusercontent.com",
    ).signIn();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    final user = await firebase.signInWithCredential(credential);

    if (user.additionalUserInfo?.isNewUser == true) {
      print("new user");
    } else {
      print("old user");
    }

    return SignInResult.success;
  }
}
