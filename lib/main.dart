import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:week6/data/user.dart';
import 'package:week6/pl_messages.dart';

void main() {
  runApp(const CynkApp());
}

class CynkApp extends StatelessWidget {
  const CynkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cynk',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChatPage(
        user: User(
          id: 'aaaa',
          name: 'Kacper Szafrański',
          photoUrl: 'https://avatars.githubusercontent.com/u/37282077?v=4',
          lastSeen: DateTime.now().subtract(Duration(minutes: 120)),
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
        flexibleSpace: ChatAppBar(user: user),
      ),
      body: Column(
        children: [
          // List of messages
          Expanded(
            child: ListView.builder(
              reverse: true, // Show the most recent message at the bottom
              itemCount: 20, // Replace with the actual message count
              itemBuilder: (context, index) {
                // Example message bubble
                final isSentByUser = index % 2 == 0; // Alternate sender
                return Align(
                  alignment: isSentByUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSentByUser ? Colors.blue[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      isSentByUser
                          ? 'Message sent by me'
                          : 'Message received from John',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
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
                      hintText: 'Type a message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
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
                  color: Colors.blue,
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

class ChatAppBar extends StatelessWidget {
  const ChatAppBar({required this.user, super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    timeago.setLocaleMessages(
      'pl',
      PlMessages(),
    ); // Add french messages

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              // back
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  print('Back button pressed');
                },
              ),
              const SizedBox(width: 4),
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
              const Spacer(),
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
        ),
      ],
    );
  }
}
