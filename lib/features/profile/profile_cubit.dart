import 'package:bloc/bloc.dart';
import 'package:cynk/features/data/cynk_user.dart';
import 'package:cynk/features/data/firestore_data_source.dart';
import 'package:image_picker/image_picker.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required this.dataSource, required this.userId})
      : super(ProfileLoading());

  final FirestoreDataSource dataSource;
  final String userId;

  void loadProfile() {
    dataSource.getUserStream(userId).listen(
      (user) {
        emit(ProfileLoaded(user: user));
      },
      onError: (Object error) {
        emit(ProfileError(error.toString()));
      },
    );
  }

  Future<void> updateName(String name) {
    return dataSource.updateName(userId, name);
  }

  Future<void> updatePhoto(XFile image) {
    return dataSource.updatePhoto(userId, image);
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
