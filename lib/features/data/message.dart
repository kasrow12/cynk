class Message {
  final String id;
  final String message;
  final DateTime time;
  final String sender;

  final bool isSentByUser;

  const Message({
    required this.id,
    required this.message,
    required this.time,
    required this.isSentByUser,
    required this.sender,
  });

  static Message fromDocument(
      {required String id,
      required Map<String, dynamic> doc,
      required String userId}) {
    return Message(
      id: id,
      message: doc['text'],
      time: doc['date'].toDate(),
      sender: doc['sender'],
      isSentByUser: doc['sender'] == userId,
    );
  }
}
