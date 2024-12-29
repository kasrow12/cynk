import 'package:Cynk/features/data/chat.dart';
import 'package:Cynk/features/data/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreDataSource {
  FirestoreDataSource({required this.db, required this.auth});

  final FirebaseFirestore db;
  final FirebaseAuth auth;

  Future<List<Message>> getChat(String chatId) async {
    final chat = await db.collection('chats').doc(chatId).get();

    final msgs = await chat.reference
        .collection('messages')
        .get()
        .then((value) => value.docs)
        .then((value) => value
            .map((doc) => Message(
                  message: doc['text'],
                  time: doc['date'].toDate(),
                  isSentByUser: doc['sender'] == chatId,
                ))
            .toList());

    return msgs;
  }

  Future<void> sendMessage(String userId, String message) async {
    final chat = await db
        .collection('chats')
        .where('users', arrayContains: userId)
        .get()
        .then((value) => value.docs);

    final chatRef = chat[0].reference.collection('messages');

    await chatRef.add({
      'text': message,
      'date': DateTime.now(),
      'sender': userId,
    });
  }

  // List<Message> getChat(String userId) {
  //   final chat = db
  //       .collection('chats')
  //       .where('users', arrayContains: userId)
  //       .get()
  //       .then((value) => value.docs);

  //   // print createdat
  //   // print(chat.docs[0].data()['createdBy']);

  //   // final messages = chat.docs[0].reference.collection('messages').get();
  //   // final messages =

  //   final msgs = chat
  //       .then((value) => value[0].reference.collection('messages').get())
  //       .then((value) => value.docs)
  //       .then((value) => value
  //           .map((doc) => Message(
  //                 message: doc['text'],
  //                 time: doc['date'].toDate(),
  //                 isSentByUser: doc['sender'] == userId,
  //               ))
  //           .toList());

  //   return msgs;
  // return Chat(
  //   user: User(
  //     id: userId,
  //     name: user['name'],
  //     photoUrl: user['photoUrl'],
  //     lastSeen: user['lastSeen'],
  //   ),
  //   messages: messages.docs
  //       .map((doc) => Message(
  //             message: doc['message'],
  //             time: doc['time'].toDate(),
  //             isSentByUser: doc['sender'] == userId,
  //           ))
  //       .toList(),
  // );
  // }
}
