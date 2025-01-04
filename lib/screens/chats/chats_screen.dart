import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cynk/features/data/chat.dart';
import 'package:cynk/features/data/chats_cubit.dart';
import 'package:cynk/features/data/user.dart';
import 'package:cynk/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({required this.user, super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ChatsCubit(db: FirebaseFirestore.instance)..loadChats(user.id),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[400],
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
                      onTap: () =>
                          ChatRoute(chatId: chat.id, $extra: user).go(context));
                },
              ),
            ChatsError(:final error) => Center(child: Text(error)),
          };
        }),
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

  String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastWeek = today.subtract(const Duration(days: 6));

    if (date.isAfter(today)) {
      return DateFormat.Hm().format(date);
    }
    if (date.isAfter(lastWeek)) {
      return DateFormat.E().format(date);
    }

    return DateFormat('dd.MM').format(date);
  }

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
