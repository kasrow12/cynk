import 'package:cynk/features/chats/classes/chat.dart';
import 'package:cynk/features/chats/cubits/chats_cubit.dart';
import 'package:cynk/features/chats/cubits/messages_cubit.dart';
import 'package:cynk/features/data/cynk_user.dart';
import 'package:cynk/features/data/firestore_data_source.dart';
import 'package:cynk/features/widgets.dart';
import 'package:cynk/screens/chat/date_separator.dart';
import 'package:cynk/screens/chat/message_tile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatScreen extends StatelessWidget {
  const ChatScreen({
    required this.chatId,
    super.key,
  });

  final String chatId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatsCubit, ChatsState>(
      builder: (context, state) {
        if (state is ChatsLoaded) {
          // Chat not found
          if (!state.chats.any((chat) => chat.id == chatId)) {
            context.read<ChatsCubit>().createPrivateChat(chatId);
            return const Center(child: CircularProgressIndicator());
          }
        }

        return switch (state) {
          ChatsLoading() => const Center(child: CircularProgressIndicator()),
          ChatsLoaded(:final userId, :final chats) => ChatScreenContent(
              userId: userId,
              chat: chats.firstWhere((chat) => chat.id == chatId),
            ),
          ChatsError(:final error) => Center(child: Text(error)),
        };
      },
    );
  }
}

class ChatScreenContent extends StatefulWidget {
  const ChatScreenContent({
    required this.userId,
    required this.chat,
    super.key,
  });

  final String userId;
  final Chat chat;

  @override
  State<ChatScreenContent> createState() => _ChatScreenContentState();
}

class _ChatScreenContentState extends State<ChatScreenContent> {
  final TextEditingController _messageController = TextEditingController();
  late final _focusNode = FocusNode(
    // https://stackoverflow.com/questions/65224279/how-to-support-submission-on-enter-and-newline-on-shift-enter-in-a-textfie
    onKeyEvent: (node, evt) {
      if (!HardwareKeyboard.instance.isShiftPressed &&
          evt.logicalKey.keyLabel == 'Enter') {
        if (evt is KeyDownEvent) {
          _onSubmitted(_messageController.text);
        }
        return KeyEventResult.handled;
      } else {
        return KeyEventResult.ignored;
      }
    },
  );

  @override
  void initState() {
    super.initState();
    // Focus on web, dont focus on mobile, because the keyboard will pop up
    if (kIsWeb) {
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _onSubmitted(String text) {
    _focusNode.requestFocus();
    if (text.isEmpty) {
      return;
    }

    context.read<FirestoreDataSource>().sendMessage(
          chatId: widget.chat.id,
          userId: widget.userId,
          message: text.trim(),
        );
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: const Color.fromARGB(255, 36, 36, 36),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: switch (widget.chat) {
          PrivateChat(:final otherUser) => UserItem(user: otherUser),
          GroupChat(:final name, :final photoUrl, :final members) => GroupItem(
              name: name,
              photoUrl: photoUrl,
              count: members.length,
            ),
        },
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                const PopupMenuItem<void>(
                  child: Text('Item1'),
                ),
                const PopupMenuItem<void>(
                  child: Text('Item 2'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // List of messages
          Expanded(
            child: BlocProvider(
              create: (context) => MessagesCubit(
                dataSource: context.read(),
                chatId: widget.chat.id,
                userId: widget.userId,
              )..loadMessages(),
              child: const ChatMessages(),
            ),
          ),

          // Input box
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    focusNode: _focusNode,
                    controller: _messageController,
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
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.photo),
                  onPressed: () => _onSubmitted(_messageController.text),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _onSubmitted(_messageController.text),
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TrimmedText(
                text: name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              const SizedBox(height: 3),
              TrimmedText(
                text: subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1,
                ),
              ),
            ],
          ),
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

class ChatMessages extends StatefulWidget {
  const ChatMessages({
    super.key,
  });

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      context.read<MessagesCubit>().loadMoreMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessagesCubit, MessagesState>(
      builder: (context, state) => switch (state) {
        MessagesLoading() => const Center(child: CircularProgressIndicator()),
        MessagesLoaded(:final messages, :final isLoadingMore) => Stack(
            children: [
              ListView.separated(
                controller: _scrollController,
                reverse: true,
                // shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: messages.length + 1,
                // +1 for the first message date
                itemBuilder: (context, index) {
                  // Allows for the date separator before the first message
                  if (index >= messages.length) {
                    return const SizedBox(height: 0);
                  }

                  return MessageTile(
                    message: messages[index],
                    key: ValueKey(messages[index].id),
                  );
                },
                separatorBuilder: (context, index) {
                  if (index + 1 >= messages.length) {
                    return DateSeparator(date: messages[index].date);
                  }

                  final current = messages[index];
                  final prev = messages[index + 1];

                  // Show date separator if the previous message was sent on a different day
                  if (prev.date.year != current.date.year ||
                      prev.date.month != current.date.month ||
                      prev.date.day != current.date.day) {
                    return DateSeparator(date: current.date);
                  }

                  if (prev.isSentByUser == current.isSentByUser &&
                      current.date.difference(prev.date).inMinutes < 10) {
                    return const SizedBox(height: 3);
                  } else {
                    return const SizedBox(height: 8);
                  }
                },
              ),
              if (isLoadingMore)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(),
                ),
            ],
          ),
        MessagesError(:final error) => Text(error),
      },
    );
  }
}
