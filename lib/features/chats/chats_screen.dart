import 'package:cynk/features/auth/auth_cubit.dart';
import 'package:cynk/features/chats/classes/chat.dart';
import 'package:cynk/features/chats/cubits/chats_cubit.dart';
import 'package:cynk/features/widgets.dart';
import 'package:cynk/routes/routes.dart';
import 'package:cynk/utils/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.grey[400],
        title: const Text('Chats'),
      ),
      body: BlocBuilder<ChatsCubit, ChatsState>(
        builder: (context, state) {
          return switch (state) {
            ChatsLoading() => const Center(child: CircularProgressIndicator()),
            ChatsLoaded(:final chats) => chats.isNotEmpty
                ? ListView.builder(
                    itemCount: chats.length,
                    itemBuilder: (context, index) {
                      final chat = chats[index];
                      return ChatEntry(
                        chat: chat,
                        onTap: () => ChatRoute(chatId: chat.id).go(context),
                      );
                    },
                  )
                : const Center(
                    child: Text(
                      'No chats yet, start a new one by tapping on Contacts',
                    ),
                  ),
            ChatsError(:final error) => Center(child: Text(error)),
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
              title: const Text('Contacts'),
              onTap: () => ContactsRoute().go(context),
            ),
            ListTile(
              title: const Text('Logout'),
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
          backgroundImage: NetworkImage(
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
              text: '${otherUser.name}: ${chat.lastMessage.message}',
            ),
          GroupChat(:final members) => TrimmedText(
              text:
                  '${members.firstWhere((member) => member.id == chat.lastMessage.sender).name}: ${chat.lastMessage.message}',
            ),
        },
        // TrimmedText(text: chat.lastMessage.message.replaceAll('\n', ' ')),
        trailing: Text(
          formatDate(chat.lastMessage.date),
          style: const TextStyle(fontSize: 13),
        ),
      ),
    );
  }
}
