import 'package:cached_network_image/cached_network_image.dart';
import 'package:cynk/features/auth/auth_cubit.dart';
import 'package:cynk/features/chats/classes/chat.dart';
import 'package:cynk/features/chats/cubits/chats_cubit.dart';
import 'package:cynk/features/widgets.dart';
import 'package:cynk/main.dart';
import 'package:cynk/routes/routes.dart';
import 'package:cynk/utils/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.chats),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => App.changeLocale(context),
          ),
        ],
      ),
      body: BlocBuilder<ChatsCubit, ChatsState>(
        builder: (context, state) {
          return switch (state) {
            ChatsLoading() => const Center(child: CircularProgressIndicator()),
            ChatsEmpty() => Center(
                child: Text(AppLocalizations.of(context)!.noChats),
              ),
            ChatsError(:final error) => Center(child: Text(error)),
            ChatsLoaded(:final chats) => ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  return ChatEntry(
                    chat: chat,
                    onTap: () =>
                        ChatRoute(chatId: chat.id).push<ChatRoute>(context),
                  );
                },
              ),
          };
        },
      ),
      drawer: Drawer(
        shape: const Border(),
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Center(
                child: Text(
                  'Cynk',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.profile),
              leading: const Icon(Icons.person),
              onTap: () {
                Navigator.pop(context);
                OwnProfileRoute().push<OwnProfileRoute>(context);
              },
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.contacts),
              leading: const Icon(Icons.people),
              onTap: () {
                Navigator.pop(context);
                ContactsRoute().push<ContactsRoute>(context);
              },
            ),
            ListTile(
              title: Text(
                AppLocalizations.of(context)!.logout,
                style: const TextStyle(color: Colors.red),
              ),
              leading: const Icon(Icons.logout, color: Colors.red),
              onTap: () => context.read<AuthCubit>().signOut(),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatEntry extends StatelessWidget {
  const ChatEntry({
    super.key,
    required this.chat,
    required this.onTap,
  });

  final Chat chat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: CachedNetworkImageProvider(
            switch (chat) {
              PrivateChat(:final otherUser) => otherUser.photoUrl,
              GroupChat(:final photoUrl) => photoUrl,
            },
          ),
        ),
        title: TrimmedText(
          text: switch (chat) {
            PrivateChat(:final otherUser) => otherUser.name,
            GroupChat(:final name) => name,
          },
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle:
            // user name + last message
            switch (chat) {
          PrivateChat(:final otherUser) => TrimmedText(
              text: (chat.lastMessage.sender == otherUser.id
                      ? ''
                      : AppLocalizations.of(context)!.sentByYou) +
                  chat.lastMessage.message.replaceAll('\n', ''),
            ),
          GroupChat(:final members) => TrimmedText(
              text:
                  '${members.firstWhere((member) => member.id == chat.lastMessage.sender).name}: ${chat.lastMessage.message.replaceAll('\n', '')}',
            ),
        },
        trailing: Text(
          formatDate(chat.lastMessage.date),
          style: const TextStyle(fontSize: 13),
        ),
      ),
    );
  }
}
