import 'package:bloc/bloc.dart';
import 'package:cynk/features/data/cynk_user.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileLoading());

  void loadProfile() {
    emit(ProfileLoaded(
        user: CynkUser(
      id: '1',
      name: 'John Doe',
      email: 'sdafsd',
      photoUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9e/Random_Turtle.jpg/2560px-Random_Turtle.jpg',
      lastSeen: DateTime.now(),
    )));
  }
}

sealed class ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  ProfileLoaded({
    required this.user,
  });

  final CynkUser user;
}

class ProfileError extends ProfileState {
  ProfileError(this.error);

  final String error;
}
