import 'package:cynk/features/contacts/contact_tile.dart';
import 'package:cynk/features/contacts/contacts_cubit.dart';
import 'package:cynk/features/data/cynk_user.dart';
import 'package:cynk/routes/routes.dart';
import 'package:cynk/utils/private_chat_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contacts')),
      body: BlocBuilder<ContactsCubit, ContactsState>(
        builder: (context, state) {
          return switch (state) {
            ContactsLoading() =>
              const Center(child: CircularProgressIndicator()),
            ContactsEmpty() =>
              const Center(child: Text('No contacts, add some')),
            ContactsError(:final error) => Center(child: Text(error)),
            ContactsLoaded(:final userId, :final filteredContacts) =>
              _ContactsScreen(
                userId: userId,
                filteredContacts: filteredContacts,
              ),
          };
        },
      ),
      floatingActionButton: BlocBuilder<ContactsCubit, ContactsState>(
        builder: (context, _) => FloatingActionButton(
          onPressed: () => showDialog<void>(
            context: context,
            builder: (dialogContext) {
              final controller = TextEditingController();
              return AlertDialog(
                title: const Text('Add Contact'),
                content: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Enter contact email',
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      Navigator.of(dialogContext).pop();
                      try {
                        await context
                            .read<ContactsCubit>()
                            .addContact(controller.text);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Contact added')),
                          );
                        }
                      } catch (err) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(err.toString())),
                          );
                        }
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          ),
          shape: const CircleBorder(),
          tooltip: 'Add Contact',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _ContactsScreen extends StatelessWidget {
  const _ContactsScreen({
    required this.userId,
    required this.filteredContacts,
  });

  final String userId;
  final List<CynkUser> filteredContacts;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          sliver: SliverPersistentHeader(
            pinned: true,
            delegate: _SearchBarDelegate(
              onChanged: (value) =>
                  context.read<ContactsCubit>().searchContacts(value),
            ),
          ),
        ),
        SliverList.builder(
          itemCount: filteredContacts.length,
          itemBuilder: (context, index) {
            final contact = filteredContacts[index];
            return ContactTile(
              user: contact,
              onTap: () => ChatRoute(
                chatId: getPrivateChatId(userId, contact.id),
              ).push<ChatRoute>(context),
              onRemove: () async {
                await showDialog<void>(
                  context: context,
                  builder: (dialogContext) {
                    return AlertDialog(
                      title: const Text('Remove Contact'),
                      content: const Text(
                        'Are you sure you want to remove this contact?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            Navigator.of(dialogContext).pop();
                            try {
                              await context
                                  .read<ContactsCubit>()
                                  .removeContact(contact.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Contact removed'),
                                  ),
                                );
                              }
                            } catch (err) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(err.toString()),
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text(
                            'Yes',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                          },
                          child: const Text('No'),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  _SearchBarDelegate({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Search Contacts',
          prefixIcon: Icon(Icons.search),
        ),
        onChanged: onChanged,
      ),
    );
  }

  @override
  double get maxExtent => 60;

  @override
  double get minExtent => 60;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
