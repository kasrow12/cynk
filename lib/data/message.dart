import 'package:Cynk/data/user.dart';

class Message {
  final String message;
  final DateTime time;
  final bool isSentByUser;

  const Message({
    required this.message,
    required this.time,
    required this.isSentByUser,
  });
}
