import 'package:cynk/features/chats/classes/message.dart';

class ChatDisplay {
  ChatDisplay({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.lastMessage,
  });

  final String id;
  final String name;
  final String photoUrl;
  final Message lastMessage;
}
