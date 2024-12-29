import 'package:cynk/features/auth/auth_service.dart';
import 'package:cynk/features/data/firestore_data_source.dart';
import 'package:cynk/features/data/message.dart';
import 'package:cynk/features/data/messages_cubit.dart';
import 'package:cynk/features/data/user.dart';
import 'package:cynk/features/auth/auth_cubit.dart';
import 'package:cynk/screens/chat/date_separator.dart';
import 'package:cynk/screens/chat/message_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatScreen extends StatelessWidget {
  ChatScreen({
    required this.user,
    required this.chatId,
    super.key,
  });

  final User user;
  final String chatId;

  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MessagesCubit(
        dataSource: context.read(),
      )..loadMessages(chatId),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[400],
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              print('Back button pressed');
            },
          ),
          title: Row(
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
                    'widziano ${timeago.format(user.lastSeen, locale: 'pl')}',
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
                      context.read<FirestoreDataSource>().getChat(
                          context.read<AuthService>().currentUser!.uid);
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
                            .sendMessage('akrv170TpAgrEO4cvo35VZg76i42', value);
                        _messageController.clear();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: Colors.black,
                    onPressed: () {
                      context.read<FirestoreDataSource>().sendMessage(
                          'akrv170TpAgrEO4cvo35VZg76i42',
                          _messageController.text);
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
            current.time.difference(prev.time).inMinutes < 5) {
          return const SizedBox(height: 3);
        } else {
          return const SizedBox(height: 8);
        }

        return Text(index.toString());
      },
    );
  }
}
