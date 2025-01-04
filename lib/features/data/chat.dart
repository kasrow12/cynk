import 'package:cynk/features/data/message.dart';

class Chat {
  const Chat({
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
