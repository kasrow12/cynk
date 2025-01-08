import 'package:cynk/features/data/cynk_user.dart';
import 'package:cynk/features/data/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreDataSource {
  FirestoreDataSource({required this.db});

  final FirebaseFirestore db;

  Stream<List<Message>> getChatStream(String chatId, String userId) {
    return db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Message(
                    message: doc['text'],
                    time: doc['date'].toDate(),
                    sender: doc['sender'],
                    isSentByUser: doc['sender'] == userId,
                  ))
              .toList(),
        );
  }

  Stream<List<CynkUser>> getContactsStream(String userId) {
    return db
        .collection('users')
        .doc(userId)
        .collection('contacts')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CynkUser.fromDocument(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> sendMessage(String chatId, String userId, String message) async {
    final date = DateTime.now();
    await db.collection('chats').doc(chatId).collection('messages').add({
      'sender': userId,
      'text': message,
      'date': date,
    });

    await db.collection('chats').doc(chatId).update({
      'lastMessage': {
        'sender': userId,
        'text': message,
        'date': date,
      },
    });
  }

  Future<Map<String, CynkUser>> fetchUsers(List<String> id) async {
    final users = await db
        .collection('users')
        .where(FieldPath.documentId, whereIn: id)
        .get();

    // return dictionary of uid: CynkUser
    return Map.fromEntries(users.docs.map(
      (doc) => MapEntry(doc.id, CynkUser.fromDocument(doc.id, doc.data())),
    ));

    // if (!userDoc.exists) {
    //   throw Exception('User not found');
    // }

    // return CynkUser.fromDocument(userDoc.id, userDoc.data()!);
  }

  // Future<List<Message>> getChat(String chatId) async {
  //   final chat = await db.collection('chats').doc(chatId).get();

  //   final msgs = await chat.reference
  //       .collection('messages')
  //       .orderBy('date', descending: true)
  //       .get()
  //       .then((value) => value.docs)
  //       .then((value) => value
  //           .map((doc) => Message(
  //                 message: doc['text'],
  //                 time: doc['date'].toDate(),
  //                 isSentByUser: true,
  //               ))
  //           .toList());

  //   return msgs;
  // }
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
