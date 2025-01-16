import 'dart:async';

import 'package:cynk/features/data/cynk_user.dart';
import 'package:cynk/features/data/firestore_data_source.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContactsCubit extends Cubit<ContactsState> {
  ContactsCubit({
    required this.dataSource,
    required this.userId,
  }) : super(ContactsLoading());

  final FirestoreDataSource dataSource;
  StreamSubscription<List<String>>? _contactsSubscription;
  final String userId;

  void loadContacts() {
    _contactsSubscription?.cancel();
    emit(ContactsLoading());
    print(userId);

    _contactsSubscription = dataSource.getContactsStream(userId).listen(
      (contacts) {
        dataSource.fetchUsers(contacts).then((users) {
          final contacts = users.values.toList();
          emit(ContactsLoaded(
            allContacts: contacts,
            filteredContacts: contacts,
          ));
        });
      },
      onError: (error) => emit(ContactsError(error.toString())),
    );
  }

  @override
  Future<void> close() {
    _contactsSubscription?.cancel();
    return super.close();
  }

  Future<void> addContact(String contactId) {
    return dataSource.addContact(userId, contactId);
  }

  Future<void> removeContact(String contactId) {
    return dataSource.removeContact(userId, contactId);
  }

  void searchContacts(String query) {
    if (state is ContactsLoaded) {
      final contacts = (state as ContactsLoaded).allContacts;
      final filtered = contacts.where((contact) {
        return contact.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
      emit(ContactsLoaded(
        allContacts: contacts,
        filteredContacts: filtered,
      ));
    }
  }
}

sealed class ContactsState {}

class ContactsLoading extends ContactsState {}

class ContactsLoaded extends ContactsState {
  ContactsLoaded({required this.allContacts, required this.filteredContacts});

  final List<CynkUser> allContacts;
  final List<CynkUser> filteredContacts;
}

class ContactsError extends ContactsState {
  ContactsError(this.error);

  final String error;
}
