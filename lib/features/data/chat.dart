import 'package:Cynk/features/data/message.dart';
import 'package:Cynk/features/data/user.dart';

class Chat {
  const Chat({
    required this.user,
    required this.name,
    required this.messages,
  });

  final User user;
  final String name;
  final List<Message> messages;
}
