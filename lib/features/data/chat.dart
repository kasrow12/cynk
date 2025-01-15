import 'package:cynk/features/data/cynk_user.dart';
import 'package:cynk/features/data/message.dart';

sealed class Chat {
  const Chat({
    required this.id,
    required this.lastMessage,
  });

  final String id;
  final Message lastMessage;
}

class PrivateChat extends Chat {
  const PrivateChat({
    required super.id,
    required super.lastMessage,
    required this.otherUser,
  });

  final String otherUser;
}

class GroupChat extends Chat {
  const GroupChat({
    required super.id,
    required super.lastMessage,
    required this.name,
    required this.photoUrl,
    required this.members,
  });

  final String name;
  final String photoUrl;
  final List<String> members;
}
