import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cynk/features/data/cynk_user.dart';
import 'package:cynk/features/data/firestore_data_source.dart';
import 'package:image_picker/image_picker.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required this.dataSource,
    required this.userId,
    required this.isOwner,
  }) : super(ProfileLoading());

  final FirestoreDataSource dataSource;
  final String userId;
  final bool isOwner;
  StreamSubscription<CynkUser>? _profileSubscription;

  void loadProfile() {
    _profileSubscription = dataSource.getUserStream(userId).listen(
      (user) {
        emit(ProfileLoaded(user: user, isOwner: isOwner));
      },
      onError: (Object error) {
        emit(ProfileError(error.toString()));
      },
    );
  }

  Future<void> updateName(String name) {
    if (!isOwner) {
      return Future.error('Not the owner of this profile');
    }

    return dataSource.updateName(userId, name);
  }

  Future<void> updatePhoto(XFile image) {
    if (!isOwner) {
      return Future.error('Not the owner of this profile');
    }

    return dataSource.updatePhoto(userId, image);
  }

  @override
  Future<void> close() {
    _profileSubscription?.cancel();
    return super.close();
  }
}

sealed class ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  ProfileLoaded({
    required this.user,
    required this.isOwner,
  });

  final CynkUser user;
  final bool isOwner;
}

class ProfileError extends ProfileState {
  ProfileError(this.error);

  final String error;
}
