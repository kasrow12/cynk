import 'package:Cynk/data/message.dart';
import 'package:Cynk/data/user.dart';
import 'package:Cynk/pl_messages.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

List<Message> aaaamessages() {
  return [
    Message(
      message: 'Hello!',
      time: DateTime.now()
          .subtract(Duration(days: 5))
          .subtract(Duration(hours: 3)),
      isSentByUser: true,
    ),
    Message(
      message:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec nec odio vitae libero.',
      time: DateTime.now()
          .subtract(Duration(days: 5))
          .subtract(Duration(hours: 3)),
      isSentByUser: false,
    ),
    Message(
      message: 'Hello!',
      time: DateTime.now()
          .subtract(Duration(days: 5))
          .subtract(Duration(minutes: 2)),
      isSentByUser: false,
    ),
    Message(
      message: 'Hello!',
      time: DateTime.now().subtract(Duration(days: 5)),
      isSentByUser: false,
    ),
    Message(
      message: 'Hello!',
      time: DateTime.now().subtract(Duration(days: 5)),
      isSentByUser: true,
    ),
    Message(
      message: 'How are you?',
      time: DateTime.now()
          .subtract(Duration(days: 4))
          .subtract(Duration(hours: 3)),
      isSentByUser: false,
    ),
    Message(
      message: 'Hiiiiiiiiiii!',
      time: DateTime.now().subtract(Duration(days: 4)),
      isSentByUser: true,
    ),
    Message(
      message: 'How are you2?',
      time: DateTime.now().subtract(Duration(minutes: 13)),
      isSentByUser: false,
    ),
    Message(
      message:
          'I\'m fine, thanks! How about you? How was your day? What did you do today? Maybe you want to tell me something interesting?',
      time: DateTime.now().subtract(Duration(minutes: 12)),
      isSentByUser: true,
    ),
    Message(
      message: 'What about you?',
      time: DateTime.now().subtract(Duration(minutes: 1)),
      isSentByUser: true,
    ),
    Message(
      message: 'What about you?',
      time: DateTime.now(),
      isSentByUser: true,
    ),
  ].reversed.toList();
}

void main() {
  timeago.setLocaleMessages('pl', PlMessages());
  runApp(const CynkApp());
}

class CynkApp extends StatelessWidget {
  const CynkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cynk',
      home: ChatPage(
        user: User(
          id: 'aaaa',
          name: 'Kacper Szafrański',
          photoUrl: 'https://avatars.githubusercontent.com/u/37282077?v=4',
          lastSeen: DateTime.now().subtract(Duration(minutes: 34)),
        ),
        messages: aaaamessages(),
      ),
    );
  }
}

class ChatPage extends StatelessWidget {
  const ChatPage({
    required this.user,
    required this.messages,
    super.key,
  });

  final User user;
  final List<Message> messages;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  value: () => debugPrint('Item 1 hit'),
                  child: const Text('Item 1'),
                ),
                PopupMenuItem(
                  value: () => debugPrint('Item 2 hit'),
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
            child: ListView.separated(
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
            ),
          ),

          // Input box
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
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
                  icon: const Icon(Icons.send),
                  color: Colors.black,
                  onPressed: () {
                    // Add send message logic here
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

class DateSeparator extends StatelessWidget {
  const DateSeparator({
    super.key,
    required this.date,
  });

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Text(
          DateFormat('d MMMM').format(date),
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  const MessageTile({
    super.key,
    required this.message,
  });

  final Message message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          message.isSentByUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: message.isSentByUser
            ? const EdgeInsets.only(left: 30)
            : const EdgeInsets.only(right: 30),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: message.isSentByUser ? Colors.green[300] : Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  message.message,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${message.time.hour.toString().padLeft(2, '0')}:${message.time.minute.toString().padLeft(2, '0')}',
                  // message.time.toString(),
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
