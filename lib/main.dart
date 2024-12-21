import 'package:Cynk/data/message.dart';
import 'package:Cynk/data/user.dart';
import 'package:Cynk/pl_messages.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

final List<Message> messages = [
  Message(
    message: 'Hello!',
    time: DateTime.now().subtract(Duration(minutes: 5)),
    isSentByUser: false,
  ),
  Message(
    message: 'Hi!',
    time: DateTime.now().subtract(Duration(minutes: 4)),
    isSentByUser: true,
  ),
  Message(
    message: 'How are you?',
    time: DateTime.now().subtract(Duration(minutes: 3)),
    isSentByUser: false,
  ),
  Message(
    message:
        'I\'m fine, thanks! How about you? How was your day? What did you do today? Maybe you want to tell me something interesting?',
    time: DateTime.now().subtract(Duration(minutes: 2)),
    isSentByUser: true,
  ),
  Message(
    message: 'What about you?',
    time: DateTime.now().subtract(Duration(minutes: 1)),
    isSentByUser: true,
  ),
];

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
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: ChatPage(
        user: User(
          id: 'aaaa',
          name: 'Kacper Szafrański',
          photoUrl: 'https://avatars.githubusercontent.com/u/37282077?v=4',
          lastSeen: DateTime.now().subtract(Duration(minutes: 34)),
        ),
      ),
    );
  }
}

class ChatPage extends StatelessWidget {
  const ChatPage({required this.user, super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[300],
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
              padding: const EdgeInsets.all(8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return MessageTile(message: messages[index]);
              },
              separatorBuilder: (context, index) {
                return const SizedBox(height: 10);
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
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
