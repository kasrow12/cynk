import 'package:cynk/features/chats/classes/chat.dart';
import 'package:cynk/features/chats/cubits/chats_cubit.dart';
import 'package:cynk/features/chats/cubits/messages_cubit.dart';
import 'package:cynk/features/chats/widgets/date_separator.dart';
import 'package:cynk/features/chats/widgets/message_tile.dart';
import 'package:cynk/features/widgets.dart';
import 'package:cynk/routes/routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';

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
          if (!state.chats.any((chat) => chat.id == chatId)) {
            // Chat not found
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
          ChatsEmpty() =>
            Center(child: Text(AppLocalizations.of(context)!.noChats)),
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
          _onSubmitted();
        }
        return KeyEventResult.handled;
      } else {
        return KeyEventResult.ignored;
      }
    },
  );

  bool _isUploading = false;
  bool _isPhotoMessage = false;

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

  Future<void> _onImageSelected() async {
    final messenger = ScaffoldMessenger.of(context);
    final cubit = context.read<MessagesCubit>();

    try {
      if (_isUploading || _isPhotoMessage) {
        return;
      }

      setState(() {
        _isPhotoMessage = true;
      });

      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) {
        setState(() {
          _isPhotoMessage = false;
        });
        return;
      }

      setState(() {
        _isUploading = true;
      });

      await cubit.sendImage(image);
    } on PlatformException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() {
        _isUploading = false;
        _isPhotoMessage = false;
      });
    }
  }

  Future<void> _onSubmitted() async {
    _focusNode.requestFocus();
    final message = _messageController.text.trim();
    final messenger = ScaffoldMessenger.of(context);
    if (message.isEmpty) {
      return;
    }
    try {
      await context.read<MessagesCubit>().sendMessage(message);
      _messageController.clear();
    } catch (err) {
      if (context.mounted) {
        messenger.showSnackBar(SnackBar(content: Text(err.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: switch (widget.chat) {
          PrivateChat(:final otherUser) => UserItem(
              user: otherUser,
              onTap: () => ProfileRoute(userId: otherUser.id)
                  .push<ProfileRoute>(context),
            ),
          GroupChat(:final name, :final photoUrl, :final members) => GroupItem(
              name: name,
              photoUrl: photoUrl,
              count: members.length,
            ),
        },
      ),
      body: Column(
        children: [
          // List of messages
          const Expanded(
            child: ChatMessages(),
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
                      hintText: AppLocalizations.of(context)!.message,
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
                const SizedBox(width: 6),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.photo),
                      onPressed: _isPhotoMessage ? null : _onImageSelected,
                      tooltip: AppLocalizations.of(context)!.sendPhoto,
                    ),
                    if (_isUploading)
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                if (kIsWeb) const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _onSubmitted,
                  tooltip: AppLocalizations.of(context)!.send,
                ),
              ],
            ),
          ),
        ],
      ),
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
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: messages.length + 1,
                // physics: const FixedExtentScrollPhysics(),
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
