import 'package:cynk/screens/chat/chat_screen.dart';
import 'package:cynk/screens/contacts/contacts_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String userId = 'ye8ypcPLibccsgl5WQYzh1ywpC73';
    // final String userId = context.read();

    return Scaffold(
        appBar: AppBar(
          title: Text('Contacts'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: BlocProvider(
          create: (context) => ContactsCubit(
            dataSource: context.read(),
          )..loadContacts(userId),
          child: BlocBuilder<ContactsCubit, ContactsState>(
            builder: (context, state) {
              return switch (state) {
                ContactsLoading() =>
                  const Center(child: CircularProgressIndicator()),
                ContactsLoaded(:final contacts) => ListView.builder(
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      return UserTile(user: contact);
                    },
                  ),
                ContactsError(:final error) => Center(child: Text(error)),
              };
            },
          ),
        ));
  }
}
