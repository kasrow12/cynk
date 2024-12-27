import 'dart:async';

import 'package:Cynk/features/auth/auth_service.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required this.authService}) : super(authService.stateFromAuth) {
    _authStateSubscription = authService.isSignedInStream.listen((isSignedIn) {
      emit(authService.stateFromAuth);
    });
  }

  final AuthService authService;
  StreamSubscription<bool>? _authStateSubscription;

  Future<void> signInWithGoogle() async {
    emit(SigningInState());

    try {
      final result = await authService.signInWithGoogle();

      switch (result) {
        case SignInResult.success:
          emit(authService.stateFromAuth);
          break;
        case SignInResult.networkError:
          emit(SignedOutState(error: 'Network error'));
          break;
        case SignInResult.userNotFound:
        case SignInResult.wrongPassword:
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
          emit(authService.stateFromAuth);
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
          emit(authService.stateFromAuth);
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

extension on AuthService {
  AuthState get stateFromAuth =>
      isSignedIn ? SignedInState(user: currentUser!) : SignedOutState();
}

sealed class AuthState extends Equatable {}

class SignedInState extends AuthState {
  SignedInState({required this.user});

  final User user;

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
