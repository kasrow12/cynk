import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  const Message({
    required this.id,
    required this.message,
    required this.date,
    required this.isSentByUser,
    required this.sender,
    this.photoUrl = '',
  });

  factory Message.fromDocument({
    required String id,
    required Map<String, dynamic> doc,
    required String userId,
  }) {
    return Message(
      id: id,
      message: doc['text'] as String,
      date: (doc['date'] as Timestamp).toDate(),
      sender: doc['sender'] as String,
      isSentByUser: doc['sender'] == userId,
      photoUrl: doc['photoUrl'] as String?,
    );
  }

  final String id;
  final String message;
  final DateTime date;
  final String sender;
  final bool isSentByUser;
  final String? photoUrl;
}
