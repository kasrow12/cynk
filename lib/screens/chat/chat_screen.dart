import 'package:cynk/features/data/chat.dart';
import 'package:cynk/features/data/chats_cubit.dart';
import 'package:cynk/features/data/firestore_data_source.dart';
import 'package:cynk/features/data/message.dart';
import 'package:cynk/features/data/messages_cubit.dart';
import 'package:cynk/features/data/cynk_user.dart';
import 'package:cynk/features/auth/auth_cubit.dart';
import 'package:cynk/routes/routes.dart';
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
    return BlocBuilder<ChatsCubit, ChatsState>(builder: (context, state) {
      return switch (state) {
        ChatsLoading() => const Center(child: CircularProgressIndicator()),
        ChatsLoaded(:final userId, :final chats, :final users) =>
          ChatScreenContent(
            chatId: chatId,
            userId: userId,
            chats: chats,
            users: users,
          ),
        ChatsError(:final error) => Center(child: Text(error)),
      };
    });
  }
}

class ChatScreenContent extends StatelessWidget {
  ChatScreenContent({
    required this.chatId,
    required this.userId,
    required this.chats,
    required this.users,
    super.key,
  });

  final String chatId;
  final String userId;
  final List<Chat> chats;
  final Map<String, CynkUser> users;

  final TextEditingController _messageController = TextEditingController();
  // final FocusNode _messageFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final chat = chats.firstWhere((chat) => chat.id == chatId);

    return BlocProvider(
      create: (context) => MessagesCubit(
        dataSource: context.read(),
        userId: userId,
      )..openChat(chatId),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[400],
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: switch (chat) {
            PrivateChat(:final otherUser) => UserTile(user: otherUser),
            GroupChat(:final name, :final photoUrl, :final members) => Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(photoUrl),
                  ),
                  const SizedBox(width: 12),
                  Text(name),
                ],
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
              child: BlocBuilder<MessagesCubit, MessagesState>(
                  builder: (context, state) {
                return switch (state) {
                  MessagesLoading() => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  MessagesLoaded(:final messages) => ChatMessages(
                      messages: messages,
                    ),
                  MessagesError(:final error) => Center(
                      child: Text('Error: $error'),
                    ),
                };
              }),
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
                            .sendMessage(chatId, userId, value);
                        _messageController.clear();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: Colors.black,
                    onPressed: () {
                      context
                          .read<FirestoreDataSource>()
                          .sendMessage(chatId, userId, _messageController.text);
                      _messageController.clear();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserTile extends StatelessWidget {
  const UserTile({
    super.key,
    required this.user,
  });

  final CynkUser user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(user.photoUrl),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'widziano ${timeago.format(user.lastSeen, locale: 'pl')}', // TODO czy na pewno, intl
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

class ChatMessages extends StatelessWidget {
  const ChatMessages({
    super.key,
    required this.messages,
  });

  final List<Message> messages;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      reverse: true,
      // shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemCount: messages.length + 1, // +1 for the first message date
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

        return Text(index.toString());
      },
    );
  }
}
