import 'dart:async';

import 'package:cynk/features/auth/auth_service.dart';
import 'package:equatable/equatable.dart';
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
        case SignInResult.networkError:
          emit(SignedOutState(error: 'Network error'));
        case SignInResult.userNotFound:
        case SignInResult.wrongPassword:
        case SignInResult.invalidEmail:
          emit(SignedOutState(error: 'Other error'));
      }
    } catch (err) {
      emit(SignedOutState(error: 'Error: $err'));
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    emit(SigningInState());

    try {
      final result = await authService.signInWithEmail(
        email: email,
        password: password,
      );

      switch (result) {
        case SignInResult.success:
          emit(authService.stateFromAuth);
        case SignInResult.invalidEmail:
          emit(SignedOutState(error: 'Invalid email'));
        case SignInResult.userNotFound:
          emit(SignedOutState(error: 'User not found'));
        case SignInResult.wrongPassword:
          emit(SignedOutState(error: 'Wrong password'));
        case SignInResult.networkError:
          emit(SignedOutState(error: 'Network error'));
      }
    } catch (err) {
      emit(SignedOutState(error: 'Error: $err'));
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    emit(SigningInState());

    try {
      final result = await authService.signUpWithEmail(
        email: email,
        password: password,
      );

      switch (result) {
        case SignUpResult.success:
          emit(authService.stateFromAuth);
        case SignUpResult.emailAlreadyInUse:
          emit(SignedOutState(error: 'Email already in use'));
        case SignUpResult.networkError:
          emit(SignedOutState(error: 'Network error'));
      }
    } catch (err) {
      emit(SignedOutState(error: 'Error: $err'));
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
      isSignedIn ? SignedInState(userId: currentUser!.uid) : SignedOutState();
}

sealed class AuthState extends Equatable {}

class SignedInState extends AuthState {
  SignedInState({required this.userId});

  final String userId;

  @override
  List<Object> get props => [userId];
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
