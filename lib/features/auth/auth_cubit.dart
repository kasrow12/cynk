import 'dart:async';

import 'package:cynk/features/auth/auth_service.dart';
import 'package:cynk/features/data/firestore_data_source.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required this.authService, required this.dataSource})
      : super(authService.stateFromAuth) {
    _authStateSubscription = authService.isSignedInStream.listen((isSignedIn) {
      emit(authService.stateFromAuth);
    });
  }

  final AuthService authService;
  final FirestoreDataSource dataSource;
  StreamSubscription<bool>? _authStateSubscription;

  Future<void> signInWithGoogle() async {
    emit(SigningInState());

    try {
      final result = await authService.signInWithGoogle();

      switch (result) {
        case AuthResult.success:
          emit(authService.stateFromAuth);
        case AuthResult.networkError:
          emit(SignedOutState(error: 'Network error'));
        case AuthResult.popupClosedByUser:
          emit(SignedOutState(error: 'Popup closed by user'));
        case _:
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
        case AuthResult.success:
          emit(authService.stateFromAuth);
        case AuthResult.invalidEmail:
          emit(SignedOutState(error: 'Invalid email'));
        case AuthResult.userNotFound:
          emit(SignedOutState(error: 'User not found'));
        case AuthResult.wrongPassword:
          emit(SignedOutState(error: 'Wrong password'));
        case AuthResult.networkError:
          emit(SignedOutState(error: 'Network error'));
        case _:
          emit(SignedOutState(error: 'Other error'));
      }
    } catch (err) {
      emit(SignedOutState(error: 'Error: $err'));
    }
  }

  Future<void> createAccount({
    required String email,
    required String username,
    required XFile? photo,
  }) async {
    try {
      return dataSource.createAccount(
        userId: authService.currentUser!.uid,
        email: email,
        username: username,
        photo: photo,
      );
    } catch (err) {
      emit(SigningUpScreenState(error: 'Error: $err'));
    }
    emit(authService.stateFromAuth);
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required XFile? photo,
  }) async {
    emit(SingingUpState());

    try {
      final result = await authService.signUpWithEmail(
        email: email,
        password: password,
      );

      switch (result) {
        case AuthResult.success:
          await createAccount(
            email: email,
            username: username,
            photo: photo,
          );
        case AuthResult.emailAlreadyInUse:
          emit(SigningUpScreenState(error: 'Email already in use'));
        case AuthResult.networkError:
          emit(SigningUpScreenState(error: 'Network error'));
        case AuthResult.weakPassword:
          emit(SigningUpScreenState(error: 'Weak password'));
        case AuthResult.invalidEmail:
          emit(SigningUpScreenState(error: 'Invalid email'));
        case _:
          emit(SigningUpScreenState(error: 'Other error'));
      }
    } catch (err) {
      emit(SigningUpScreenState(error: 'Error: $err'));
    }
  }

  Future<void> moveToSignUp() async {
    emit(SigningUpScreenState());
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

sealed class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SignedInState extends AuthState {
  SignedInState({required this.userId});

  final String userId;

  @override
  List<Object?> get props => [userId];
}

class SigningInState extends AuthState {}

class SignedOutState extends AuthState {
  SignedOutState({this.error});

  final String? error;

  @override
  List<Object?> get props => [error];
}

class SigningUpScreenState extends AuthState {
  SigningUpScreenState({this.error});

  final String? error;

  @override
  List<Object?> get props => [error];
}

class SingingUpState extends AuthState {}
