import 'package:cynk/features/auth/current_user.dart';
import 'package:cynk/features/chats/cubits/messages_cubit.dart';
import 'package:cynk/features/data/chat.dart';
import 'package:cynk/features/data/firestore_data_source.dart';
import 'package:cynk/features/chats/cubits/chat_cubit.dart';
import 'package:cynk/features/data/cynk_user.dart';
import 'package:cynk/features/auth/auth_cubit.dart';
import 'package:cynk/screens/chat/date_separator.dart';
import 'package:cynk/screens/chat/message_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatScreen extends StatelessWidget {
  ChatScreen({
    required this.chatId,
    super.key,
  });

  final String chatId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit(
        dataSource: context.read(),
        userId: context.read<CurrentUser>().id,
        chatId: chatId,
      )..openChat(),
      child: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          return switch (state) {
            ChatLoading() => const Center(child: CircularProgressIndicator()),
            ChatLoaded(:final userId, :final chat) => ChatScreenContent(
                userId: userId,
                chat: chat,
              ),
            ChatError(:final error) => Text(error.toString()),
          };
        },
      ),
    );
  }
}

class ChatScreenContent extends StatelessWidget {
  ChatScreenContent({
    required this.userId,
    required this.chat,
    super.key,
  });

  final String userId;
  final Chat chat;

  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: const Color.fromARGB(255, 36, 36, 36),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: switch (chat) {
          PrivateChat(:final otherUser) => UserItem(user: otherUser),
          GroupChat(:final name, :final photoUrl, :final members) => GroupItem(
              name: name,
              photoUrl: photoUrl,
              count: members.length,
            ),
        },
        actions: [
          PopupMenuButton<void Function()>(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: () => context.read<AuthCubit>().signOut(),
                  child: const Text('Logout'),
                ),
                PopupMenuItem(
                  value: () {
                    debugPrint('Item 2 hit');
                  },
                  child: const Text('Item 2'),
                ),
              ];
            },
            onSelected: (fn) => fn(),
          ),
        ],
      ),
      body: Column(
        children: [
          // List of messages
          Expanded(
            child: ChatMessages(
              chatId: chat.id,
              userId: userId,
            ),
          ),

          // Input box
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    // TODO: shift-enter doesnt work on web
                    // keyboardType: TextInputType.multiline,
                    // maxLines: null,

                    decoration: InputDecoration(
                      hintText: 'Message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                    ),
                    controller: _messageController,
                    onSubmitted: (value) {
                      context
                          .read<FirestoreDataSource>()
                          .sendMessage(chat.id, userId, value);
                      _messageController.clear();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    context
                        .read<FirestoreDataSource>()
                        .sendMessage(chat.id, userId, _messageController.text);
                    _messageController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CynkTile extends StatelessWidget {
  const CynkTile({
    super.key,
    required this.photoUrl,
    required this.name,
    required this.subtitle,
  });

  final String photoUrl;
  final String name;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(photoUrl),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                height: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class UserItem extends StatelessWidget {
  const UserItem({
    super.key,
    required this.user,
  });

  final CynkUser user;

  @override
  Widget build(BuildContext context) {
    return CynkTile(
      photoUrl: user.photoUrl,
      name: user.name,
      subtitle: 'widziano ${timeago.format(user.lastSeen, locale: 'pl')}',
    );
  }
}

class GroupItem extends StatelessWidget {
  const GroupItem({
    super.key,
    required this.name,
    required this.photoUrl,
    required this.count,
  });

  final String name;
  final String photoUrl;
  final int count;

  @override
  Widget build(BuildContext context) {
    return CynkTile(
      photoUrl: photoUrl,
      name: name,
      subtitle: '$count members',
    );
  }
}

class ChatMessages extends StatelessWidget {
  const ChatMessages({
    super.key,
    required this.chatId,
    required this.userId,
  });

  final String chatId;
  final String userId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MessagesCubit(
        dataSource: context.read(),
        chatId: chatId,
        userId: userId,
      )..loadMessages(),
      child: BlocBuilder<MessagesCubit, MessagesState>(
          builder: (context, state) => switch (state) {
                MessagesLoading() =>
                  const Center(child: CircularProgressIndicator()),
                MessagesLoaded(:final messages) => ListView.separated(
                    reverse: true,
                    // shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount:
                        messages.length + 1, // +1 for the first message date
                    itemBuilder: (context, index) {
                      // Allows for the date separator before the first message
                      if (index >= messages.length) {
                        return const SizedBox(height: 0);
                      }

                      return MessageTile(message: messages[index]);
                    },
                    separatorBuilder: (context, index) {
                      if (index + 1 >= messages.length) {
                        return DateSeparator(date: messages[index].time);
                      }

                      final current = messages[index];
                      final prev = messages[index + 1];

                      // Show date separator if the previous message was sent on a different day
                      if (prev.time.year != current.time.year ||
                          prev.time.month != current.time.month ||
                          prev.time.day != current.time.day) {
                        return DateSeparator(date: current.time);
                      }

                      if (prev.isSentByUser == current.isSentByUser &&
                          current.time.difference(prev.time).inMinutes < 10) {
                        return const SizedBox(height: 3);
                      } else {
                        return const SizedBox(height: 8);
                      }
                    },
                  ),
                MessagesError(:final error) => Text(error.toString()),
              }),
    );
  }
}
