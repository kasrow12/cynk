class Message {
  final String message;
  final DateTime time;
  final String sender;

  final bool isSentByUser;

  const Message({
    required this.message,
    required this.time,
    required this.isSentByUser,
    required this.sender,
  });

  static Message fromDocument(Map<String, dynamic> doc, String userId) {
    return Message(
      message: doc['text'],
      time: doc['date'].toDate(),
      sender: doc['sender'],
      isSentByUser: doc['sender'] == userId,
    );
  }
}
