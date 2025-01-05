import 'dart:async';

import 'package:cynk/features/auth/auth_service.dart';
import 'package:cynk/features/data/cynk_user.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required this.authService}) : super(SignedOutState()) {
    _authStateSubscription =
        authService.isSignedInStream.listen((isSignedIn) async {
      if (isSignedIn) {
        await fetchUser();
      } else {
        emit(SignedOutState());
      }
    });
  }

  final AuthService authService;
  StreamSubscription<bool>? _authStateSubscription;

  Future<void> fetchUser() async {
    final user = authService.currentUser;

    if (user == null) {
      emit(SignedOutState());
      return;
    }

    try {
      final cynkUser = await authService.fetchUser(user.uid);

      emit(SignedInState(user: cynkUser));
    } catch (e) {
      emit(SignedOutState(error: 'Error: $e'));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(SigningInState());

    try {
      final result = await authService.signInWithGoogle();

      switch (result) {
        case SignInResult.success:
          await fetchUser();
          break;
        case SignInResult.networkError:
          emit(SignedOutState(error: 'Network error'));
          break;
        case SignInResult.userNotFound:
        case SignInResult.wrongPassword:
        case SignInResult.invalidEmail:
          emit(SignedOutState(error: 'Other error'));
          break;
      }
    } catch (e) {
      emit(SignedOutState(error: 'Error: $e'));
    }
  }

  Future<void> signInWithEmail(
      {required String email, required String password}) async {
    emit(SigningInState());

    try {
      final result = await authService.signInWithEmail(
        email: email,
        password: password,
      );

      switch (result) {
        case SignInResult.success:
          await fetchUser();
          break;
        case SignInResult.invalidEmail:
          emit(SignedOutState(error: 'Invalid email'));
          break;
        case SignInResult.userNotFound:
          emit(SignedOutState(error: 'User not found'));
          break;
        case SignInResult.wrongPassword:
          emit(SignedOutState(error: 'Wrong password'));
          break;
        case SignInResult.networkError:
          emit(SignedOutState(error: 'Network error'));
          break;
      }
    } catch (e) {
      emit(SignedOutState(error: 'Error: $e'));
    }
  }

  Future<void> signUpWithEmail(
      {required String email, required String password}) async {
    emit(SigningInState());

    try {
      final result = await authService.signUpWithEmail(
        email: email,
        password: password,
      );

      switch (result) {
        case SignUpResult.success:
          await fetchUser();
          break;
        case SignUpResult.emailAlreadyInUse:
          emit(SignedOutState(error: 'Email already in use'));
          break;
        case SignUpResult.networkError:
          emit(SignedOutState(error: 'Network error'));
          break;
      }
    } catch (e) {
      emit(SignedOutState(error: 'Error: $e'));
    }
  }

  Future<void> signOut() async {
    await authService.signOut();

    emit(SignedOutState());
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}

sealed class AuthState extends Equatable {}

class SignedInState extends AuthState {
  SignedInState({required this.user});

  final CynkUser user;

  @override
  List<Object> get props => [user];
}

class SigningInState extends AuthState {
  @override
  List<Object> get props => [];
}

class SignedOutState extends AuthState {
  SignedOutState({this.error});

  final String? error;

  @override
  List<Object?> get props => [error];
}
