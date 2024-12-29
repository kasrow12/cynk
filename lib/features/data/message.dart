class Message {
  final String message;
  final DateTime time;
  final String sender = "";

  final bool isSentByUser;

  const Message({
    required this.message,
    required this.time,
    required this.isSentByUser,
    // required this.sender,
  });
}
