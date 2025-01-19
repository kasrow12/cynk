import 'package:cynk/features/auth/auth_cubit.dart';
import 'package:cynk/features/data/chat.dart';
import 'package:cynk/features/chats/cubits/chats_cubit.dart';
import 'package:cynk/features/data/cynk_user.dart';
import 'package:cynk/features/data/firestore_data_source.dart';
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
      body: BlocBuilder<ChatsCubit, ChatsState>(builder: (context, state) {
        return switch (state) {
          ChatsLoading() => const Center(child: CircularProgressIndicator()),
          ChatsLoaded(:final chats) => ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return ChatEntry(
                    chat: chat,
                    // onTap: () => context.go('/chat/${chat.id}', extra: user));
                    onTap: () => ChatRoute(chatId: chat.id).go(context));
              },
            ),
          ChatsError(:final error) => Center(child: Text(error)),
        };
      }),
      drawer: Drawer(
        shape: const Border(),
        child: ListView(
          children: [
            // const DrawerHeader(
            //   decoration: BoxDecoration(color: Colors.grey),
            //   child: Center(
            //     child: Text(
            //       'Cynk',
            //       style: TextStyle(
            //         color: Colors.white,
            //         fontSize: 24,
            //       ),
            //     ),
            //   ),
            // ),
            ListTile(
                title: const Text('Contacts'),
                onTap: () => ContactsRoute().go(context)),
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
  ChatEntry({
    super.key,
    required this.chat,
    required this.onTap,
  });

  final ChatDisplay chat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(chat.photoUrl),
        ),
        title: Text(
          chat.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(chat.lastMessage.message),
        trailing: Text(
          formatDate(chat.lastMessage.time),
          style: const TextStyle(fontSize: 13),
        ),
      ),
    );
  }
}
