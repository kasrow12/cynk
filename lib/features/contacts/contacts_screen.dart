import 'package:cynk/features/contacts/contact_tile.dart';
import 'package:cynk/features/contacts/contacts_cubit.dart';
import 'package:cynk/features/data/cynk_user.dart';
import 'package:cynk/routes/routes.dart';
import 'package:cynk/utils/private_chat_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.contacts)),
      body: BlocBuilder<ContactsCubit, ContactsState>(
        builder: (context, state) {
          return switch (state) {
            ContactsLoading() =>
              const Center(child: CircularProgressIndicator()),
            ContactsEmpty() =>
              Center(child: Text(AppLocalizations.of(context)!.noContacts)),
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
          shape: const CircleBorder(),
          tooltip: AppLocalizations.of(context)!.addContact,
          child: const Icon(Icons.add),
          onPressed: () => showDialog<void>(
            context: context,
            builder: (dialogContext) {
              final controller = TextEditingController();
              return AlertDialog(
                title: Text(AppLocalizations.of(context)!.addContact),
                content: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.email,
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
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(context)!.contactAdded,
                              ),
                            ),
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
                    child: Text(AppLocalizations.of(context)!.add),
                  ),
                ],
              );
            },
          ),
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
                      title: Text(AppLocalizations.of(context)!.removeContact),
                      content: Text(
                        AppLocalizations.of(context)!.removeContactConfirmation,
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
                                  SnackBar(
                                    content: Text(
                                      AppLocalizations.of(context)!
                                          .contactRemoved,
                                    ),
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
                          child: Text(
                            AppLocalizations.of(context)!.yes,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                          },
                          child: Text(AppLocalizations.of(context)!.no),
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
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.searchContacts,
          prefixIcon: const Icon(Icons.search),
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
