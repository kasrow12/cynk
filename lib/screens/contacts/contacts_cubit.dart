import 'dart:async';

import 'package:cynk/features/data/cynk_user.dart';
import 'package:cynk/features/data/firestore_data_source.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContactsCubit extends Cubit<ContactsState> {
  ContactsCubit({
    required this.dataSource,
  }) : super(ContactsLoading());

  final FirestoreDataSource dataSource;
  StreamSubscription<List<CynkUser>>? _contactsSubscription;

  void loadContacts(String userId) {
    _contactsSubscription?.cancel();
    emit(ContactsLoading());
    print(userId);

    _contactsSubscription =
        dataSource.getContactsStream(userId).listen((contacts) {
      emit(ContactsLoaded(contacts));
    }, onError: (error) => emit(ContactsError(error.toString())));
  }

  @override
  Future<void> close() {
    _contactsSubscription?.cancel();
    return super.close();
  }
}

sealed class ContactsState {}

class ContactsLoading extends ContactsState {}

class ContactsLoaded extends ContactsState {
  ContactsLoaded(this.contacts);

  final List<CynkUser> contacts;
}

class ContactsError extends ContactsState {
  ContactsError(this.error);

  final String error;
}
